# moonbit-wasi-nix-example

This is an example of using [WASI HTTP](https://github.com/WebAssembly/wasi-http) with MoonBit from "[Developing Wasm component model in MoonBit with minimal output size](https://www.moonbitlang.com/blog/component-model)", setup using a [Nix flake](https://wiki.nixos.org/wiki/Flakes) for the development environment.

## Developing

Run `direnv allow` and the devshell will provide the necessary tooling (the MoonBit compiler, lsp, `wit-bindgen`, `wit-deps` and `wasm-tools`).

## Running

Run `nix build .` or `nix run .` to run the application then visit http://localhost:8080.