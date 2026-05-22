# 🐼 Pxndxs Nix Configuration

Modular Nix flake covering three host classes:

| Profile | Target | Imports |
|---|---|---|
| `pxndxs@pxndxs` | NixOS desktop (Hyprland/Wayland) | full set: GUI apps + Wayland modules |
| `pxndxs@ubuntu-mac` | Ubuntu 26.04 + Flashback Metacity (X11) | curated CLI subset, no GUI/Wayland |
| `pxndxs@mac` / `shipedge@mac` | macOS (Apple Silicon, `aarch64-darwin`) — headless | strict CLI-only, no GUI / Wayland / X11 |

Single source of truth for shared modules; per-host profiles compose them. The two `*@mac` entries share one module (`hosts/mac/home.nix`) and only differ in the injected `username` — see *Identity injection* below.

---

## Layout

```
.
├── flake.nix                 # inputs + nixosConfigurations + homeConfigurations
├── nixos/                    # NixOS-only system config (configuration.nix, hardware-configuration.nix)
├── home-manager/             # shared HM modules (canonical home.nix lives here)
│   ├── home.nix              #   canonical NixOS HM profile (imports all)
│   ├── platform.nix          #   _module.args.platform + derives homeDirectory from username × OS
│   ├── packages.nix          #   aggregator: imports packages/* including gui
│   ├── packages/
│   │   ├── core.nix             #  wget, curl, zip, unzip, unrar, gnumake42         (OS-pure)
│   │   ├── core-linux.nix       #  xclip, clang_multi                                (Linux-only)
│   │   ├── cli-modern.nix       #  fd, ripgrep, tldr, dust, btop, procs, sd, yazi, nh (OS-pure)
│   │   ├── cli-modern-linux.nix #  playerctl, qalculate-qt                           (Linux-only)
│   │   ├── dev.nix              #  pnpm, bun, fnm, deno, stripe-cli, pyngrok, rolldown
│   │   └── gui.nix              #  warp-terminal, mangohud                           (NixOS only)
│   ├── shell-integrations.nix  # programs.{zoxide,fzf,bat,eza}.enable — binary + shell hook
│   ├── brave-nightly.nix · direnv.nix · fonts.nix · git.nix · jq.nix
│   ├── kitty.nix · neocats.nix · obs.nix · python.nix · zsh.nix
│   └── hyprland.nix · waybar.nix · rofi.nix    # NixOS only (Wayland-bound or conflict)
├── overlays/default.nix      # overrides pkgs.warp-terminal with local package
├── pkgs/
│   ├── brave-nightly/        # local Brave Nightly package      (x86_64-linux only)
│   └── warp-terminal/        # local Warp package + versions/update script (Linux only)
└── hosts/
    ├── ubuntu-mac/
    │   └── home.nix          # Ubuntu HM profile — imports curated subset
    └── mac/
        └── home.nix          # macOS HM profile — CLI-only; accepts injected `username`
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

### macOS (Apple Silicon, headless)

Same prereqs as Ubuntu (Nix multi-user + flakes enabled in `~/.config/nix/nix.conf`). Repo lives at `~/.config/nixos`. Pick the profile whose `username` matches the current Mac:

```bash
# Personal Mac (user pxndxs)
home-manager switch --flake ~/.config/nixos#pxndxs@mac -b backup

# Work Mac (user shipedge)
home-manager switch --flake ~/.config/nixos#shipedge@mac -b backup
```

First-time bootstrap (no `home-manager` binary yet):

```bash
nix run home-manager/master -- switch --flake ~/.config/nixos#<username>@mac -b backup
```

#### Identity injection

Both Mac profiles share `hosts/mac/home.nix`. The flake passes a per-profile `username` through `extraSpecialArgs`; `hosts/mac/home.nix` sets `home.username = username` and `home-manager/platform.nix` derives `home.homeDirectory = "/Users/${username}"`. Add a new Mac by appending one block to `flake.nix#homeConfigurations`.

GUI apps (Warp, Brave, OBS, Raycast, …) are intentionally **not** managed by this flake on macOS — install them via Homebrew casks or the App Store.

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

1. Pick the bucket: `core` / `cli-modern` / `dev` / `gui` / `shell-integrations`. For Linux-only items use the `-linux.nix` sibling (`core-linux`, `cli-modern-linux`) so darwin profiles stay clean.
2. Edit `home-manager/packages/<bucket>.nix` (or `shell-integrations.nix` if it has a program module).
3. `git add` (Nix flakes only see tracked files).
4. `home-manager switch --flake .#<username>@<host>`.

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

---

## Excluded from `*@mac` and why

Strict CLI-only profile. Anything that ships a GUI, depends on a Linux compositor, or is Linux-bound at the package level is omitted.

| Module / bucket | Reason |
|---|---|
| `hyprland.nix`, `waybar.nix`, `rofi.nix` | Wayland / X11 stack; no compositor on macOS. |
| `brave-nightly.nix`, `kitty.nix`, `obs.nix` | GUI apps — install via Homebrew cask. |
| `chromium.nix` *(if reintroduced)* | `programs.chromium` HM module is Linux-bound. |
| `packages/gui.nix` | `warp-terminal`, `mangohud` — Linux GUI / Vulkan. |
| `packages/core-linux.nix` | `xclip` (X11), `clang_multi` (Linux multilib). |
| `packages/cli-modern-linux.nix` | `playerctl` (MPRIS/D-Bus), `qalculate-qt` (Qt). |

The flake also gates the custom `brave-nightly` and `warp-terminal` derivations behind `pkgs.stdenv.hostPlatform.isLinux` via `lib.optionalAttrs`, so `nix flake check` on `aarch64-darwin` does not try to build them.
