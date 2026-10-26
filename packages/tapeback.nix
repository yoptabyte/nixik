{ lib, python3Packages, fetchurl, makeWrapper, makeDesktopItem, copyDesktopItems, ffmpeg, pulseaudio }:

python3Packages.buildPythonApplication rec {
  pname = "tapeback";
  version = "0.10.1";
  pyproject = true;

  src = fetchurl {
    url = "https://github.com/yastcher/tapeback/releases/download/v${version}/tapeback-${version}.tar.gz";
    hash = "sha256-Jfv34egnGGFdiEuGjzh7awwCcDVpKIpiZDcGXHvxKLs=";
  };

  build-system = [ python3Packages.hatchling ];
  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  dependencies = with python3Packages; [
    faster-whisper
    av
    pydantic-settings
    click
    python-dotenv
    dbus-next
    anthropic
    openai
  ];

  pythonRelaxDeps = [
    # Nixpkgs patches faster-whisper for PyAV 19's removed metadata_errors argument.
    "av"
    # The provider uses the same messages API with the SDK shipped by nixpkgs.
    "anthropic"
  ];

  # PulseAudio's client utilities also work with the existing PipeWire server.
  postFixup = ''
    wrapProgram $out/bin/tapeback \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg pulseaudio ]} \
      --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:${python3Packages.makePythonPath dependencies}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "tapeback";
      desktopName = "Tapeback";
      comment = "Record and transcribe meetings";
      exec = "tapeback tray";
      icon = "audio-input-microphone";
      categories = [ "AudioVideo" "Recorder" ];
      terminal = false;
    })
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ffmpeg ];
  pytestFlags = [
    "-o" "addopts="
    "tests/test_settings.py"
    "tests/test_audio.py"
    "tests/test_recorder.py"
    "tests/test_transcriber.py"
    "tests/test_isolated.py"
    "tests/test_tray.py"
    "tests/test_llm.py"
  ];
  # Run the installed CLI without the build's PYTHONPATH: the worker is a fresh
  # interpreter and must inherit the application and its dependencies itself.
  postCheck = ''
    ${python3Packages.python.interpreter} ${./tapeback-worker-check.py} "$out/bin/tapeback"
  '';
  pythonImportsCheck = [ "tapeback.cli" "tapeback.tray" "faster_whisper" ];

  meta = {
    description = "Local meeting recorder with Whisper transcription and optional LLM summaries";
    homepage = "https://github.com/yastcher/tapeback";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "tapeback";
  };
}
