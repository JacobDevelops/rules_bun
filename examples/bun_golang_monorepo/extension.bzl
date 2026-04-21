"""Bzlmod module extensions for this monorepo.

Two extensions are declared here so MODULE.bazel stays readable:

  nix_toolchains  — creates @nixpkgs and @nix_bun repositories from flake.lock
  bun_packages    — creates @npm repository from the root bun.lock
"""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_local_repository", "nixpkgs_package")
load("@rules_bun//internal:bun_install.bzl", "bun_install_repository")

###############################################################################
# nix_toolchains
#
# Creates two repositories:
#   @nixpkgs — the nixpkgs snapshot locked by flake.lock
#   @nix_bun — the Bun binary extracted from that snapshot
#
# The BUILD.bazel at the workspace root then wires @nix_bun//:bin/bun into a
# bun_toolchain target and registers it via MODULE.bazel's register_toolchains.
###############################################################################
def _nix_toolchains_impl(_ctx):
    nixpkgs_local_repository(
        name = "nixpkgs",
        nix_flake_lock_file = "//:flake.lock",
    )
    nixpkgs_package(
        name = "nix_bun",
        attribute_path = "bun",
        build_file_content = 'exports_files(glob(["bin/*"]))\n',
        repository = "@nixpkgs",
    )

nix_toolchains = module_extension(
    implementation = _nix_toolchains_impl,
)

###############################################################################
# bun_packages
#
# Creates the @npm repository by running `bun install` against the root
# bun.lock during the repository fetch phase.  All TypeScript packages share
# this single @npm — no per-package lockfiles.
###############################################################################
def _bun_packages_impl(_ctx):
    bun_install_repository(
        name = "npm",
        bun_lockfile = "//:bun.lock",
        package_json = "//:package.json",
        visible_repo_name = "npm",
    )

bun_packages = module_extension(
    implementation = _bun_packages_impl,
)
