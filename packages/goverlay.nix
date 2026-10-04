{ lib, goverlay, lazarus-qt6 }:
let
  # Removing rpath arguments leaves doubled/leading spaces in NIX_LDFLAGS.
  # makeBinaryWrapper rejects those empty segments; normalise the remaining
  # flags before Lazarus passes them to its wrapper.
  lazarus-fixed = lazarus-qt6.overrideAttrs (old: {
    postInstall = lib.replaceStrings
      [ "sed -re 's/-rpath [^ ]+//g'" ]
      [ "sed -re 's/-rpath [^ ]+//g; s/ +/ /g; s/^ //; s/ $//'" ]
      old.postInstall;
  });
in
goverlay.override { lazarus-qt6 = lazarus-fixed; }
