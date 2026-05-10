# 🐼 Pxndxs Nix Configuration

Modular Nix flake covering two host classes:

| Profile | Target | Imports |
|---|---|---|
| `pxndxs@pxndxs` | NixOS desktop (Hyprland/Wayland) | full set: GUI apps + Wayland modules |
| `pxndxs@ubuntu-mac` | Ubuntu 26.04 + Flashback Metacity (X11) | curated CLI subset, no GUI/Wayland |

Single source of truth for shared modules; per-host profiles compose them.

---

## Layout

```
.
├── flake.nix                 # inputs + nixosConfigurations + homeConfigurations
├── nixos/                    # NixOS-only system config (configuration.nix, hardware-configuration.nix)
├── home-manager/             # shared HM modules (canonical home.nix lives here)
│   ├── home.nix              #   canonical NixOS HM profile (imports all)
│   ├── packages.nix          #   aggregator: imports packages/* including gui
│   ├── packages/
│   │   ├── core.nix          #     wget, curl, zip, unzip, unrar, xclip, clang_multi, gnumake42
│   │   ├── cli-modern.nix    #     fd, ripgrep, tldr, dust, btop, procs, sd, yazi
│   │   ├── dev.nix           #     pnpm, bun, fnm, deno, stripe-cli, pyngrok, rolldown
│   │   └── gui.nix           #     warp-terminal, mangohud  (NixOS only)
│   ├── shell-integrations.nix  # programs.{zoxide,fzf,bat,eza}.enable — binary + shell hook
│   ├── brave-nightly.nix · direnv.nix · fonts.nix · git.nix · jq.nix
│   ├── kitty.nix · neocats.nix · obs.nix · python.nix · zsh.nix
│   └── hyprland.nix · waybar.nix · rofi.nix    # NixOS only (Wayland-bound or conflict)
├── overlays/default.nix      # overrides pkgs.warp-terminal with local package
├── pkgs/
│   ├── brave-nightly/        # local Brave Nightly package
│   └── warp-terminal/        # local Warp package + versions/update script
└── hosts/
    └── ubuntu-mac/
        └── home.nix          # Ubuntu HM profile — imports curated subset
```

Add a package once in `home-manager/packages/<bucket>.nix` → propagates to every profile that imports that bucket.

---

## Apply

### NixOS (canonical)

```bash
sudo nixos-rebuild switch --flake .#pxndxs
home-manager switch --flake .#pxndxs@pxndxs
```

### Ubuntu / non-NixOS

Prereqs: Nix multi-user installed, flakes enabled (`~/.config/nix/nix.conf` → `experimental-features = nix-command flakes`).

```bash
home-manager switch --flake $HOME/.config/nixos#pxndxs@ubuntu-mac -b backup
```

`-b backup` renames any pre-existing dotfile to `*.backup` instead of failing.

First-time bootstrap (no `home-manager` binary yet):

```bash
nix run home-manager/master -- switch --flake $HOME/.config/nixos#pxndxs@ubuntu-mac -b backup
```

---

## Shell entry-point (Ubuntu / non-NixOS)

**Do not** `chsh` to `~/.nix-profile/bin/zsh` — volatile path, dangles after `nix store gc` or profile rotation.

Stable pattern: system zsh as login binary, HM owns the configs.

```bash
sudo apt install zsh                 # /usr/bin/zsh — gc-immune
sudo chsh -s /usr/bin/zsh $USER      # /etc/passwd points to stable path
```

`/etc/zsh/zshenv` (patched by Nix installer) sources Nix env on shell start. `~/.zshrc` is symlinked by HM into the current generation. Future GC of old generations cannot brick login.

For bash users, ensure `~/.bashrc` and `~/.profile` source:

```bash
[ -e /etc/profile.d/nix-daemon.sh ] && . /etc/profile.d/nix-daemon.sh
[ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ] && \
  . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

The first line gets `~/.nix-profile/bin` on `PATH`. Second line exports HM `XDG_DATA_DIRS` additions so HM-installed fonts/icons/MIME types are visible to GTK apps.

---

## Package vs program

| Bucket | When to use |
|---|---|
| `home.packages = [ pkgs.X ]` | Tool needs only a binary (`fd`, `ripgrep`, `dust`). |
| `programs.X.enable = true` | Tool needs binary **and** shell hook (`zoxide`, `fzf`, `direnv`) or generates configs (`bat`, `git`, `eza`, `kitty`). |

Picking the right one prevents duplicate installs and gets the `z`/`Ctrl+R`/alias hooks wired automatically.

---

## Add a package

1. Pick the bucket: `core` / `cli-modern` / `dev` / `gui` / `shell-integrations`.
2. Edit `home-manager/packages/<bucket>.nix` (or `shell-integrations.nix` if it has a program module).
3. `git add` (Nix flakes only see tracked files).
4. `home-manager switch --flake .#pxndxs@<host>`.

---

## Rollback

```bash
home-manager generations
~/.local/state/nix/profiles/profile-N-link/activate     # roll back to gen N
```

Old generations stay until explicit GC:

```bash
home-manager expire-generations '-7 days'
nix store gc
```

---

## Excluded from `pxndxs@ubuntu-mac` and why

| Module | Reason |
|---|---|
| `hyprland.nix` | Wayland-only compositor; host is X11. |
| `waybar.nix` | Hyprland status bar; gnome-panel owns top bar. |
| `rofi.nix` | Would clobber `~/.config/rofi/whitesur.rasi` (Spotlight, hand-tuned). |
| `brave-nightly.nix` | apt provides Brave Nightly. |
| `kitty.nix` | apt provides Warp Terminal. |
| `obs.nix` | Install via apt if/when needed. |
| `packages/gui.nix` | warp-terminal, mangohud — apt or unused. |

Restore any of these by adding the import back to `hosts/ubuntu-mac/home.nix`.
