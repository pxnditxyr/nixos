{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Pxndxs 🐼";
        email = "pxnditxyr@gmail.com";
      };
      init.defaultBranch = "main";
      alias = {
        s = "status -sb";
        lg = ''log --graph --abbrev-commit --decorate --pretty="format:%C(bold yellow)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(italic cyan)%s%C(reset) %C(cyan)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'';
      };
    };
  };
}
