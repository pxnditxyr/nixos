# packages/cli-modern.nix — modern (mostly Rust/Go) CLI replacements
# for the classic POSIX tools. Universally useful regardless of host.
{ pkgs, ... }: {
  # Tools needing only a binary go here.
  # bat / eza / zoxide / fzf are wired up via programs.* in
  # ../shell-integrations.nix (binary + shell hook in one), so they are
  # intentionally NOT listed below to avoid duplicate installs.
  home.packages = with pkgs; [
    fd           # Better find - simple, fast, user-friendly
    ripgrep      # Better grep - respects .gitignore, super fast
    tldr         # Simplified man pages with practical examples
    dust         # Better du - disk usage analyzer with tree view
    btop         # Better top/htop - beautiful system monitor
    procs        # Better ps - modern process viewer
    sd           # Better sed - simpler find & replace
    yazi         # Terminal file manager
    playerctl    # Media key controls (XF86AudioNext/Prev/Play/Pause)
    qalculate-qt # Provides qalc CLI used by Hyprland rofi calculator script
    nh           # nix-helper - modern wrapper for nixos-rebuild / home-manager with diffs
  ];
}
