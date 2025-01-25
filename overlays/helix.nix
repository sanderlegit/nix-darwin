# https://nixos.wiki/wiki/Overlays#Rust_packages
final: prev: {
  helix = prev.helix.overrideAttrs (oldAttrs: rec{
    version = "master";

    src = prev.fetchFromGithub {
      owner = "helix-editor";
      repo = "helix";
      rev = "81708b70e685426716999e1278b7373292e797e9"; # Latest master commit
      hash = "";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      name = "helix-vendor.tar.gz";
      inherit src;
      outputHash = ""; # Will fail first time and give you the correct hash
    });
  });
}
