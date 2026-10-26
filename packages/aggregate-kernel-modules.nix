{ lib, aggregateModules, kernel }:

modules:
(aggregateModules modules).overrideAttrs (old:
  let
    marker = "# Merge the single‐module certificates for external modules.";
    kernelConfig = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/.config";
  in
  assert lib.assertMsg (lib.hasInfix marker old.postBuild)
    "Review the legacy CachyOS module aggregation workaround after updating nixpkgs";
  {
    postBuild = lib.replaceStrings [ marker ] [ ''
      # Older CachyOS builds have no kmodigest certificates. Only skip their
      # aggregation when the matching kernel explicitly disables module signing.
      if test "$kernelVersion" = ${lib.escapeShellArg kernel.modDirVersion} \
          && ! test -e modules.cer \
          && grep -qFx '# CONFIG_MODULE_SIG is not set' ${lib.escapeShellArg kernelConfig}; then
        echo "Legacy unsigned CachyOS kernel: module certificates are not required."
        exit 0
      fi

      ${marker}
    '' ] old.postBuild;
  })
