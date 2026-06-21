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
    rPackages.rolldown          # R Markdown websites
    # Real ngrok agent (unfree). hiPrio so its `bin/ngrok` wins the buildEnv
    # collision against pyngrok's bundled `bin/ngrok`. Use: `ngrok http <port>`.
    (lib.hiPrio ngrok)
    python313Packages.pyngrok   # Python ngrok wrapper/lib (keeps its python module)
    stripe-cli                  # Stripe API CLI
    glab                        # GitLab CLI — manage/unstick MRs from the terminal
    gh                          # GitHub CLI — manage PRs/issues from the terminal
  ];
}
