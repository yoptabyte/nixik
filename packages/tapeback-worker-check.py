"""Check the packaged CLI's real worker without downloading a Whisper model."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import wave


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    model = root / "empty-model"
    model.mkdir()
    audio = root / "audio.wav"
    with wave.open(str(audio), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(16000)
        wav.writeframes(b"\0" * 16000 * 4)

    env = {
        key: value
        for key, value in os.environ.items()
        if key not in ("PYTHONPATH", "PYTHONHOME") and not key.startswith("TAPEBACK_")
    }
    env.update(
        TAPEBACK_VAULT_PATH=str(root / "vault"),
        TAPEBACK_STT_BACKEND="local",
        TAPEBACK_STT_MODEL=str(model),
        TAPEBACK_LANGUAGE="ru",
        TAPEBACK_DEVICE="cpu",
        TAPEBACK_ISOLATE_TRANSCRIPTION="true",
        TAPEBACK_RESUME_CACHE="false",
        TAPEBACK_RUN_LOG="false",
        TAPEBACK_GPU_TELEMETRY="false",
        TAPEBACK_GATE_MIC_SILENCE="false",
    )
    result = subprocess.run(
        [sys.argv[1], "process", str(audio), "--no-diarize", "--no-summarize"],
        cwd=root,
        env=env,
        capture_output=True,
        text=True,
        timeout=60,
    )
    output = result.stdout + result.stderr
    # Reaching CTranslate2's local model loader proves the child imported both
    # Tapeback and its ML dependencies. The empty directory prevents downloads.
    assert result.returncode != 0, output
    assert "No module named" not in output, output
    assert "isolated worker" in output, output
    assert "Unable to open file 'model.bin'" in output, output
    print("Packaged CLI worker imports succeeded without a build PYTHONPATH")
