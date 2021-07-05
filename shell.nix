{ pkgs ? import ./nixpkgs.nix {} }:

let
  prelude-source =
    pkgs.fetchFromGitHub {
      owner = "alexherbo2";
      repo = "prelude.kak";
      rev = "5dbdc020c546032885c1fdb463e366cc89fc15ad";
      sha256 = "1pncr8azqvl2z9yvzhc68p1s9fld8cvak8yz88zgrp5ypx2cxl8c";
    };

  kak-spec-source =
    pkgs.fetchFromGitHub {
      owner = "jbomanson";
      repo = "kak-spec.kak";
      rev = "230ccd2a59263954a5eb225e531b074b9455bafa";
      sha256 = "1y5kphz67ym4aqkm89sqic9f2ihqpgilscdicd58cgv17fif0wyn";
    };

  kak-spec =
    pkgs.stdenv.mkDerivation {
      name = "kak-spec.kak";
      nativeBuildInputs = [
        pkgs.gnugrep
      ];
      buildInputs = [
        # pkgs.kakoune
        pkgs.ruby
      ];
      phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
      unpackPhase = ''
        ln -s ${kak-spec-source} kak-spec.kak
        ln -s ${prelude-source} prelude.kak
      '';
      installPhase = ''
        mkdir tmp
        cd kak-spec.kak
        PREFIX=../tmp make install
        cp --recursive --dereference ../tmp "$out"
      '';
      preFixup = ''
        sed -i 's/-S ruby --disable=gems/ruby/' "$out/share/kak-spec/lib/reporter.rb"
      '';
    };

in
  pkgs.mkShell {
    buildInputs = [
      kak-spec
    ];
  }
