{ config, lib, pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    apsw
    lxml
    pynacl
    requests
    pycryptodome
    isodate
    greenlet
    gevent
    psutil
    simplejson
  ]);

  acestream = pkgs.stdenv.mkDerivation {
    pname = "acestream-engine";
    version = "3.2.11";

    src = pkgs.fetchurl {
      url = "https://download.acestream.media/linux/acestream_3.2.11_ubuntu_22.04_x86_64_py3.10.tar.gz";
      # Hash from community Docker image (same version 3.2.11 ubuntu 22.04)
      # If build fails with hash mismatch, replace with the correct one from the error message
      sha256 = "9b6bbd76a55e5a434641afae3b9cf8e6154ce1cf392152ec3aed5ac265432b2e";
    };

    dontBuild = true;

    nativeBuildInputs = with pkgs; [ autoPatchelfHook makeWrapper ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      libxml2
      libxslt
      sqlite
      zlib
      openssl
      pythonEnv
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/acestream $out/bin

      # Extract the tarball
      tar xzf $src -C $out/opt/acestream

      # Auto-patch ELF binaries/libs
      chmod -R +w $out/opt/acestream
      find $out/opt/acestream -name "*.so" -exec chmod +x {} \;
      find $out/opt/acestream -type f -executable -exec chmod +x {} \;

      # Create wrapper that sets up the env and starts the engine
      makeWrapper $out/opt/acestream/start-engine $out/bin/acestream-engine \
        --prefix PATH : ${lib.makeBinPath [ pkgs.coreutils pkgs.gnused pkgs.gawk pythonEnv ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [
          stdenv.cc.cc.lib libxml2 libxslt sqlite zlib openssl
        ])} \
        --run "cd $out/opt/acestream" \
        --set PYTHONPATH "${pythonEnv}/${pkgs.python3.sitePackages}" \
        --set LIBCRYPTO_LIBRARY_DIR "${pkgs.openssl}/lib" \
        --set ACESTREAM_ROOT "$out/opt/acestream"

      # Also create a direct acestreamengine wrapper
      makeWrapper $out/opt/acestream/acestreamengine $out/bin/acestreamengine \
        --prefix PATH : ${lib.makeBinPath [ pkgs.coreutils pythonEnv ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [
          stdenv.cc.cc.lib libxml2 libxslt sqlite zlib openssl
        ])} \
        --run "cd $out/opt/acestream" \
        --set PYTHONPATH "${pythonEnv}/${pkgs.python3.sitePackages}" \
        --set ACESTREAM_ROOT "$out/opt/acestream"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Ace Stream Engine — P2P multimedia streaming platform";
      homepage = "https://acestream.org";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      maintainers = [ ];
    };
  };
in
{
  environment.systemPackages = [ acestream ];

  systemd.user.services.acestream = {
    description = "Ace Stream Engine";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${acestream}/bin/acestream-engine --client-console --http-port 6878";
      Restart = "on-failure";
      RestartSec = "10";
    };
  };
}
