{
  description = "bun-golang monorepo dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bazelisk
            pkgs.go
            pkgs.bun
          ];
        };

        # Expose bun as a package so Bazel's nixpkgs_package rule can extract it.
        packages.bun = pkgs.bun;
      });
}
