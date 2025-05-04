# https://nixos.wiki/wiki/Overlays
# if you don't know the hash, set:
#   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
# you will get an error similar to:
#          specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
#             got:    sha256-H3jFVK5G/BHBNfUto2TzblnfyV879olOgFbG9pfMtnQ=
# (which will refer to the first hash set to AAAA..., then replace and repeat)
# 
# https://nixos.org/manual/nixpkgs/stable/#fetchfromgithub

final: prev: {
  # --- Go Override ---
  go_1_24 = prev.go_1_24.overrideAttrs (old: {
    version = "1.24.2";
    src = final.fetchurl {
      url = "https://go.dev/dl/go1.24.2.darwin-arm64.tar.gz";
      sha256 = "b70f8b3c5b4ccb0ad4ffa5ee91cd38075df20fdbd953a1daedd47f50fbcff47a";
    };
  });

  # --- Lazygit Override using overrideAttrs ---
  lazygit = prev.lazygit.overrideAttrs (oldAttrs: {
    # Override the source
    src = prev.fetchFromGitHub {
      owner = "sanderlegit";
      repo = "lazygit";
      rev = "b7c8501a920482164d06bcd64719933e9501511a";
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-w/+ZO0MYbe7Jsm/mG7LNAXaDXa9zbkfjyJuIQt7b0Zc=";
    };

    # Explicitly add our overridden Go to build inputs
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      final.go_1_24
    ];

    # Handle vendoring for the new source.
    proxyVendor = true;
    # Required when using proxyVendor
    vendorHash = null; 
    # Ensure network access for proxyVendor
    __noChroot = true;

    # Use a build phase hook to explicitly configure Go environment variables
    preBuildPhases = (oldAttrs.preBuildPhases or []) ++ [ "configureGoToolchain" ];
    configureGoToolchain = ''
      export HOME=$TMPDIR # Good practice to set HOME
      # Tell Go to use the toolchain found locally (should be the one in PATH now)
      export GOTOOLCHAIN="local"
      export PATH="${final.go_1_24}/bin:$PATH"
    '';
  });
}
