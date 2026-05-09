{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.self.packages.${pkgs.system}.brave-nightly
  ];
}
