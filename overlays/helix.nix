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
      rev = "aec1594bb9335af00e9ed7526fc63ed40f4048c0";
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-Re3b7Jb2EuTqMA+kJNhoJS4rHv9fBIfDseBBJPjUguo=";
    };

    # cargoHash = "";

    # cargoHash = builtins.trace oldAttrs.cargoDeps "wow";

    # cargoDeps = oldAttrs.cargoDeps.overrideAttrs (prev.lib.const {
    # cargoDeps = oldAttrs.cargoDeps.overrideAttrs (old: {
    #   # name = "helix-vendor.tar.gz";
    #   # inherit src;

    #   outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    #   # outputHash = "sha256-cdSZbyA48KRjPpFqu33QB6V4wUhWRHJ3DRV9HC6Srx0=";
    # });
    #
    # cargoDeps = oldAttrs.fetchCargoVendor.overrideAttrs (old: {
    #   hash = "";
    # });

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
