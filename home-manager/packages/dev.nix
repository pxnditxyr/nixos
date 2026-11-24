{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    # nodejs_22
    pnpm
    bun
    fnm

    deno

    go_latest
    gopls # needs `go` on PATH to load packages

    # cargo
    # rust
    # rustc

    # rolldown: use per project (`bunx rolldown`); nixpkgs' `rolldown` has no
    # CLI and `rPackages.rolldown` is an unrelated R package.

    # hiPrio: its bin/ngrok must win over pyngrok's (../python.nix).
    (lib.hiPrio ngrok)
    stripe-cli
    glab
    gh
  ];
}
