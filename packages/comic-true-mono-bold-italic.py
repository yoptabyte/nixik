"""Complete upstream's stale Bold Italic using its own slant and centering."""
from pathlib import Path
import math
import sys

from fontTools.ttLib import TTFont
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen

directory = Path(sys.argv[1])
font = TTFont(directory / "ComicTrueMono-Bold.ttf")
glyphs = font.getGlyphSet()
slant = math.tan(math.radians(12.7))
converted = {}
for name in font.getGlyphOrder():
    recording = DecomposingRecordingPen(glyphs)
    glyphs[name].draw(recording)
    bounds = BoundsPen(None)
    recording.replay(TransformPen(bounds, (1, 0, slant, 1, 0, 0)))
    width = font["hmtx"][name][0]
    offset = (width - bounds.bounds[0] - bounds.bounds[2]) / 2 if bounds.bounds else 0
    pen = TTGlyphPen(None)
    recording.replay(TransformPen(pen, (1, 0, slant, 1, offset, 0)))
    converted[name] = pen.glyph()
font["glyf"].glyphs = converted
for name, glyph in converted.items():
    glyph.recalcBounds(font["glyf"])
    font["hmtx"][name] = (font["hmtx"][name][0], getattr(glyph, "xMin", 0))
for table in ("fpgm", "prep", "cvt "):
    if table in font:
        del font[table]
for name_id, value in {2: "Bold Italic", 3: "ComicTrueMono-BoldItalic",
                       4: "Comic True Mono Bold Italic", 6: "ComicTrueMono-BoldItalic",
                       17: "Bold Italic"}.items():
    for platform, encoding, language in [(3, 1, 0x409), (1, 0, 0)]:
        font["name"].setName(value, name_id, platform, encoding, language)
font["head"].macStyle |= 3
font["OS/2"].fsSelection = (font["OS/2"].fsSelection & ~(1 << 6)) | 0x21
font["post"].italicAngle = -12.7
font.save(directory / "ComicTrueMono-BoldItalic.ttf")
