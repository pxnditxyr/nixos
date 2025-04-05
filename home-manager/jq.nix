{
  programs.jq = {
    enable = true;
    colors = {
      null = "1;35";
      false = "0;35";
      true = "0;35";
      numbers = "0;32";
      strings = "0;33";
      arrays = "1;37";
      objects = "1;37";
      objectKeys = "1;37";
    };
  };
}
