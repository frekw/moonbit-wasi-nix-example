{
  description = "An example of using MoonBit and WASI HTTP";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    moonbit-overlay.url = "github:jetjinser/moonbit-overlay";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      overlays = {
        wit-deps = (
          final: prev: {
            wit-deps = final.callPackage ./nix/wit-deps.nix { };
          }
        );
      };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          inputs.devshell.flakeModule
        ];

        systems = [
          "x86_64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        perSystem =
          {
            inputs',
            system,
            pkgs,
            ...
          }:
          rec {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.moonbit-overlay.overlays.default
                overlays.wit-deps
              ];
            };

            packages.default = pkgs.stdenv.mkDerivation {
              name = "moonbit-wasi-nix-example";
              version = "0.1.0";

              src = ./.;

              buildInputs = with pkgs; [
                moonbit-bin.moonbit.latest

                # wasm stuff
                wasm-tools
                wit-bindgen
                wit-deps
              ];

              buildPhase = ''
                mkdir -p target
                moon build --target wasm --target-dir target
                wasm-tools component embed wit target/wasm/release/build/gen/gen.wasm -o target/wasm/release/build/gen/gen.wasm --encoding utf16
                wasm-tools component new target/wasm/release/build/gen/gen.wasm -o target/wasm/release/build/gen/gen.wasm
              '';

              installPhase = ''
                mkdir -p $out/bin
                cp -r target/wasm/release/build/gen/gen.wasm $out/bin/moonbit-wasi-nix-example.wasm
              '';
            };

            apps.default = {
              type = "app";
              program = pkgs.writeShellScriptBin "run-moonbit-wasi-nix-example" ''
                #!/usr/bin/env sh
                ${pkgs.wasmtime}/bin/wasmtime serve ${packages.default}/bin/moonbit-wasi-nix-example.wasm
              '';
            };

            devshells.default = {
              packages =
                (with pkgs; [
                  moonbit-bin.lsp.latest
                  wasmtime
                ])
                ++ packages.default.buildInputs;
            };
          };
      };
}
