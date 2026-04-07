{
  description = "obs-service-cargo";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { self, nixpkgs, rust-overlay, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;

              overlays = [
                rust-overlay.overlays.default
              ];
            };

            rustToolchain = pkgs.rust-bin.stable."1.94.0".default.override {
                extensions = [ "rust-analyzer" "rust-src" ];
            };

          in
          f {
            inherit system pkgs rustToolchain;
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system, rustToolchain }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              rustToolchain
              self.formatter.${system}
            ];

            env = {
            };

          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
