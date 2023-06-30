{ pkgs ? import <nixpkgs> { } }:

let 
  packages = ps: {
    erofs-utils = ps.callPackage ./linglong/erofs-utils.nix { };
    linglong = ps.callPackage ./linglong { };
    linglong-loader = ps.callPackage ./linglong/loader.nix { };
    linglong-box = ps.callPackage ./linglong/box.nix { };
    linglong-dbus-proxy = ps.callPackage ./linglong/dbus.nix { };
    linglong-root = ps.callPackage ./linglong/root.nix { };

    # linglong currently expects ostree to be built without curl support
    ostree = pkgs.ostree.overrideAttrs (old: {
      configureFlags = pkgs.lib.subtractLists [
        "--with-curl"
      ] old.configureFlags;
    });
  };
in
  pkgs.lib.makeScope pkgs.libsForQt5.newScope packages
