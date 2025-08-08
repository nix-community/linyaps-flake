{ pkgs ? import <nixpkgs> { } }:

let 
  packages = ps: {
    linglong = ps.callPackage ./linglong { };
    # linglong currently expects ostree to be built without curl support
    #ostree = pkgs.ostree.overrideAttrs (old: {
    #  configureFlags = pkgs.lib.subtractLists [
    #    "--with-curl"
    #  ] old.configureFlags;
    #});
  };
in
  pkgs.lib.makeScope pkgs.qt6Packages.newScope packages
