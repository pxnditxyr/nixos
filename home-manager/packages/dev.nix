# packages/dev.nix — programming-language runtimes, package managers,
# and developer-focused CLIs. CLI-only; nothing GUI.
{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    # Node.js ecosystem
    # nodejs_22
    pnpm
    bun
    fnm

    # Deno + JS bundler
    deno

    # Rust tools (commented; uncomment when needed)
    # cargo
    # rust
    # rustc

    # Misc dev CLIs
    # rolldown: per project (`bunx rolldown` / devDependency). nixpkgs'
    # `rolldown` is only the node library (no CLI) and `rPackages.rolldown`
    # is an unrelated R package.
    # Real ngrok agent (unfree). hiPrio so its `bin/ngrok` wins the buildEnv
    # collision against pyngrok's bundled `bin/ngrok` (pyngrok lives in the
    # python env, ../python.nix). Use: `ngrok http <port>`.
    (lib.hiPrio ngrok)
    stripe-cli                  # Stripe API CLI
    glab                        # GitLab CLI — manage/unstick MRs from the terminal
    gh                          # GitHub CLI — manage PRs/issues from the terminal
  ];
}
