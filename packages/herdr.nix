{ herdr }:
herdr.overrideAttrs (old: {
  # Use LLVM for Ghostty and GCC for compiler builtins to avoid the malformed
  # ELF unwind data and symbols produced by Zig 0.16's bundled runtime.
  patches = (old.patches or []) ++ [
    ./herdr-ghostty-llvm.patch
    ../modules/nixos/desktop/herdr-visual-block.patch
  ];
})
