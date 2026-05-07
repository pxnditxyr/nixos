# shell-integrations.nix — first-class HM modules for CLI tools that need
# both a binary AND a shell hook (eval / completion). Shared by every host.
#
# Why this is its own module:
#   home.packages = [ pkgs.zoxide ] only installs the binary. The 'z' command
#   is a shell function defined by `zoxide init <shell>`. HM's program modules
#   handle BOTH halves — binary + the eval line into ~/.bashrc / ~/.zshrc —
#   so we centralise them here and remove the corresponding entries from
#   packages/cli-modern.nix to avoid duplicate installs.
{ pkgs, ... }: {
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };
}
