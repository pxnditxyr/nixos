# neopanda 🐼 Neovim config. Installs npd/neopanda from the GitHub flake and
# symlinks ~/.config/neopanda to the clone (vim.pack writes its lockfile there).
{ inputs, config, ... }:
{
  imports = [ inputs.neopanda.homeModules.default ];

  programs.neopanda = {
    enable = true;
    configPath = "${config.home.homeDirectory}/dev/neopanda";
  };
}
