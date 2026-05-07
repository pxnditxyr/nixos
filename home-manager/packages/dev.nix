# packages/dev.nix — programming-language runtimes, package managers,
# and developer-focused CLIs. CLI-only; nothing GUI.
{ pkgs, ... }: {
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
    python313Packages.pyngrok   # Python ngrok wrapper
    stripe-cli                  # Stripe API CLI
  ];
}
