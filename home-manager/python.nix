{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Libraries must be inside withPackages to be importable by the
    # interpreter; loose python3.pkgs.* entries in home.packages are not.
    (python313.withPackages (ps: with ps; [
      pip
      virtualenv
      setuptools
      wheel
      pyngrok # ngrok wrapper/lib; its bin/ngrok loses to the real agent (packages/dev.nix)
    ]))
  ];

  # home.sessionVariables = {
  #   PYTHONPATH = "${config.home.homeDirectory}/.local/lib/python3.14/site-packages";
  #   PIP_TARGET = "${config.home.homeDirectory}/.local/lib/python3.14/site-packages";
  # };
}
