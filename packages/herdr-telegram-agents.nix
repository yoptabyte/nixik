{ lib, buildGoModule, fetchFromGitHub, makeWrapper, sqlite, python3, gitMinimal }:

buildGoModule rec {
  pname = "herdr-telegram-agents";
  version = "0.17.4";

  src = fetchFromGitHub {
    owner = "permgps";
    repo = "herdr-telegram-agents";
    rev = "ce05d6c659489681c8bb70ddaf641b963096e9ad";
    hash = "sha256-nRTQfx0PWIt30CtBmoVA/I40rgYwvxP4w+8wulqdgJI=";
  };

  patches = [
    ./herdr-telegram-full-replies.patch
    ./herdr-telegram-remote-diff.patch
    ./herdr-telegram-markdown-code.patch
  ];
  vendorHash = "sha256-BHHQlARGtvZiZ5BQqZYrz4gD3E0Xr/TybAD5LpSvX0M=";
  subPackages = [ "cmd/herdr-tg" ];
  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ gitMinimal ];
  env.CGO_ENABLED = 0;
  ldflags = [ "-s" "-w" "-X main.version=${version}-nix-full-replies.3" ];

  checkPhase = ''
    runHook preCheck
    go test ./internal/app -run '^Test(Outbound|InboundGit)'
    go test ./internal/domain
    go test -p 1 ./internal/adapters/telegram \
      ./internal/adapters/transcript ./internal/adapters/system ./internal/compose
    runHook postCheck
  '';

  postInstall = ''
    wrapProgram $out/bin/herdr-tg --prefix PATH : ${lib.makeBinPath [ sqlite gitMinimal ]}
    pluginRoot=$out/share/herdr/plugins/permgps.telegram-agents
    mkdir -p "$pluginRoot/bin"
    cp herdr-plugin.toml "$pluginRoot/"
    ln -s "$out/bin/herdr-tg" "$pluginRoot/bin/herdr-tg"
    substitute ${./herdr-agent-integrations.py} "$out/bin/herdr-agent-integrations" \
      --replace-fail '#!/usr/bin/env python3' '#!${python3}/bin/python3' \
      --replace-fail '@python3@' '${python3}'
    chmod +x "$out/bin/herdr-agent-integrations"
  '';

  passthru.pluginRoot = "share/herdr/plugins/permgps.telegram-agents";

  meta = {
    description = "Herdr Telegram bridge with complete session replies";
    homepage = "https://github.com/permgps/herdr-telegram-agents";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "herdr-tg";
  };
}
