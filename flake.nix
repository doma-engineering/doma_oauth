{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        goo.url = "github:doma-engineering/goo-1.14?ref=v1.14";
        fenix = {
            url = "github:nix-community/fenix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {self, nixpkgs, goo, fenix}:
        let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            npkgs = pkgs.nodePackages;
            rust_complete = (fenix.outputs.packages.x86_64-linux.complete.withComponents [
                        "cargo"
                        "clippy"
                        "rustc"
                        "rustfmt"
                        "rust-src"
                    ]);
        in {
            defaultPackage.x86_64-linux = pkgs.hello;

            devShell.x86_64-linux =
                pkgs.mkShell {
                    nativeBuildInputs = [
                        pkgs.libsodium
                    ];
                    buildInputs = [
                        rust_complete

                        pkgs.erlangR24
                        goo.defaultPackage.x86_64-linux
                        pkgs.inotify-tools
                        pkgs.postgresql
                        pkgs.openssl
                        # Helpers
                        pkgs.httpie
                        pkgs.jq
                        pkgs.yq
                        pkgs.dig
                        # Stuff that has to be externally configured
                        pkgs.gnupg
                        pkgs.darcs
                        pkgs.unzip
                        npkgs.yarn
                        ## Stuff that isn't yet implemented
                        # domaPakages.passveil
                        ## Stuff that doesn't work
                        # pkgs.yggdrasil
                    ];
                    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.libsodium ];
                };
        };
}
