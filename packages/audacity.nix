{ audacity }:

audacity.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    # Qt 6.12's generated QML code and the extensions moc code both expose Type.
    # Compile these translation units separately to avoid leaking using directives.
    cat >> muse/framework/extensions/qml/Muse/Extensions/CMakeLists.txt <<'EOF'
    set_target_properties(muse_extensions_qml PROPERTIES UNITY_BUILD OFF)
    EOF
  '';
})
