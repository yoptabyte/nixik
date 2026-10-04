{ herdr }:
herdr.overrideAttrs (old: {
  # Use LLVM for Ghostty; Nixpkgs disables Zig's bundled runtimes on Linux.
  patches = (old.patches or []) ++ [
    ./herdr-ghostty-llvm.patch
    ../modules/nixos/desktop/herdr-visual-block.patch
  ];
})
