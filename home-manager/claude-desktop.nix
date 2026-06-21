# Claude Desktop — community Linux repackage (Electron over the macOS app).
# Linux-only, so this module belongs to the canonical NixOS profile only.
# Module + options come from inputs.claude-for-linux.homeManagerModules.default.
{ inputs, ... }: {
  imports = [ inputs.claude-for-linux.homeManagerModules.default ];

  programs.claude-desktop = {
    enable = true;
    fhs = true;                # FHS wrapper — needed for MCP / Cowork
    createDesktopEntry = true; # XDG launcher entry
  };
}
