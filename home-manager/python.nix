{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (python313.withPackages (ps: with ps; [
      pip
      virtualenv
    ]))

    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  # home.sessionVariables = {
  #   PYTHONPATH = "${config.home.homeDirectory}/.local/lib/python3.14/site-packages";
  #   PIP_TARGET = "${config.home.homeDirectory}/.local/lib/python3.14/site-packages";
  # };
}
