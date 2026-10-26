{ godot_4, harfbuzz }:

godot_4.override {
  # Godot 4.7 requires harfbuzz-vector alongside the raster and ICU libraries.
  # Its nixpkgs recipe enables raster and Cairo, but leaves vector disabled.
  harfbuzz = harfbuzz.override { withVector = true; };
}
