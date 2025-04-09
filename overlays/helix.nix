# https://nixos.wiki/wiki/Overlays#Rust_packages
# if you don't know the hash, set:
#   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
# you will get an error similar to:
#          specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
#             got:    sha256-H3jFVK5G/BHBNfUto2TzblnfyV879olOgFbG9pfMtnQ=
# (which will refer to the first hash set to AAAA..., then replace and repeat)
# 
# https://nixos.org/manual/nixpkgs/stable/#fetchfromgithub
# 
# Never managed to get this to work
# https://nixos.org/manual/nixpkgs/unstable/#versioncheckhook
# 
# doesnt work to disable check
# 
# installCheckPhase = "";
#
# doesnt replace hook
# 
# versionCheckHook = ''
#   version="$($out/bin/hx --version)"
#   if [[ "$version" != "helix 25.01.1" ]]; then
#     echo "error: version mismatch, expected 25.01.1"
#     exit 1
#   fi
# '';

final: prev: {
  helix = prev.helix.overrideAttrs (oldAttrs: rec{
    version = "25.01.1"; # is not checked

    src = prev.fetchFromGitHub {
      owner = "sanderlegit";
      repo = "helix";
      rev = "79433382f76f38a0816f65df7ea974eec7fb040c";
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-n98J1eD4KoSd/muaOVel5TTExszzPcIE7Z0dtWrDR+I=";
    };

    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
      name = "helix-vendor.tar.gz";
      inherit src;
      # outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      outputHash = "sha256-cdSZbyA48KRjPpFqu33QB6V4wUhWRHJ3DRV9HC6Srx0=";
    });

    # Required for fetching git dependencies during build
    # start
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
      prev.git
      prev.cacert
      prev.pkg-config
      prev.makeWrapper
    ];

    buildInputs = oldAttrs.buildInputs ++ [
      prev.openssl
      prev.openssl.dev
    ];

    __contentAddressed = false;
    __noChroot = true;

    preBuildPhases = [ "preBuildPhase" ];
    preBuildPhase = ''
      export HOME=$TMPDIR
      export GIT_SSL_CAINFO="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
      # Ensure git can access the network
      export GIT_SSL_CERT_FILE="${prev.cacert}/etc/ssl/certs/ca-bundle.crt"
      git config --global http.sslCAInfo "${prev.cacert}/etc/ssl/certs/ca-bundle.crt"    '';
    # end
  });
}
