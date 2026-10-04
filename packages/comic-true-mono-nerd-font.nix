{ lib, runCommand, fetchFromGitHub, python3, nerd-font-patcher }:

let
  source = fetchFromGitHub {
    owner = "CptIdea";
    repo = "ComicTrueMono";
    rev = "37aa347f703f89662455da08d6cb962a24526d3c";
    sha256 = "0gvsyzw9kib08ng98x56fxk0q2q1x55i96w9y70b7195w7qszkvg";
  };
  # Upstream's checked-in Bold Italic is stale and lacks Cyrillic. Derive it
  # from the complete Bold face with upstream's 12.7-degree italic transform.
  base = runCommand "comic-true-mono" {
    nativeBuildInputs = [ (python3.withPackages (p: [ p.fonttools ])) ];
  } ''
    mkdir -p "$out/share/fonts/truetype"
    for style in Regular Italic Bold; do
      cp ${source}/fonts/ttf/ComicTrueMono-$style.ttf "$out/share/fonts/truetype/"
    done
    python ${./comic-true-mono-bold-italic.py} "$out/share/fonts/truetype"
  '';
in
runCommand "comic-true-mono-nerd-font" {
  nativeBuildInputs = [ nerd-font-patcher ];
  meta = {
    description = "Comic True Mono with Cyrillic and monospaced Nerd Font icons";
    homepage = "https://github.com/CptIdea/ComicTrueMono";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
} ''
  mkdir -p "$out/share/fonts/truetype" "$out/share/licenses/comic-true-mono-nerd-font"
  jobs=()
  for style in Regular Italic Bold BoldItalic; do
    nerd-font-patcher --complete --mono --careful \
      --outputdir "$out/share/fonts/truetype" \
      ${base}/share/fonts/truetype/ComicTrueMono-$style.ttf > "$style.log" 2>&1 &
    jobs+=("$!")
  done
  failed=0
  for job in "''${jobs[@]}"; do
    wait "$job" || failed=1
  done
  if [ "$failed" -ne 0 ]; then
    cat *.log
    exit 1
  fi
  cp ${source}/OFL.txt ${source}/LICENSE "$out/share/licenses/comic-true-mono-nerd-font/"
''
