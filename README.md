# 🐼 Pxndxs Nix Configuration

Modular Nix flake covering three host classes:

| Profile | Target | Imports |
|---|---|---|
| `pxndxs@pxndxs` | NixOS desktop (Hyprland/Wayland) | full set: GUI apps + Wayland modules |
| `pxndxs@ubuntu-mac` | Ubuntu 26.04 + Flashback Metacity (X11) | curated CLI subset, no GUI/Wayland |
| `pxndxs@mac` / `shipedge@mac` | macOS (Apple Silicon, `aarch64-darwin`) — headless | strict CLI-only, no GUI / Wayland / X11 |

Single source of truth for shared modules; per-host profiles compose them. The two `*@mac` entries share one module (`hosts/mac/home.nix`) and only differ in the injected `username` — see *Identity injection* below.

---

## Prerequisites

Install these once per machine before applying any profile.

### 1 — Install Nix

**macOS & Ubuntu** — use the Determinate Systems installer (recommended; supports flakes out of the box):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or the official multi-user installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Verify: `nix --version` (expect `nix (Nix) 2.x`).

### 2 — Enable flakes (if not using Determinate installer)

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### 3 — Clone this repo

```bash
git clone git@github.com:pxnditxyr/nixos.git ~/.config/nixos
```

### NixOS only

NixOS ships with Nix. Enable flakes in `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then apply the system config once (it re-enables flakes and takes over from there):

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#pxndxs
```

---

## Layout

```
.
├── flake.nix                 # inputs + nixosConfigurations + homeConfigurations + formatter/devShells/checks
├── nixos/                    # NixOS-only system config (configuration.nix, hardware-configuration.nix)
├── home-manager/             # shared HM modules (canonical home.nix lives here)
│   ├── home.nix              #   canonical NixOS HM profile: cli-base + Linux/GUI layer
│   ├── cli-base.nix          #   shared CLI base for every profile (packages, shell, git, ssh, …)
│   ├── nixpkgs-config.nix    #   shared nixpkgs policy (allowUnfree) — all profiles
│   ├── platform.nix          #   _module.args.platform + derives homeDirectory from username × OS
│   ├── packages/
│   │   ├── core.nix             #  wget, curl, zip, unzip, unrar, gnumake            (OS-pure)
│   │   ├── core-linux.nix       #  xclip, clang_multi                                (Linux-only)
│   │   ├── cli-modern.nix       #  fd, ripgrep, tldr, dust, btop, procs, sd, yazi + programs.nh (OS-pure)
│   │   ├── cli-modern-linux.nix #  playerctl, qalculate-qt                           (Linux-only)
│   │   ├── dev.nix              #  pnpm, bun, fnm, deno, ngrok, stripe-cli, glab, gh
│   │   └── gui.nix              #  warp-terminal, mangohud, karere                   (NixOS only)
│   ├── shell-integrations.nix  # programs.{zoxide,fzf,bat,eza,starship}.enable — binary + shell hook
│   ├── zsh.nix + zsh/nix-helpers.zsh  # zsh config + rebuild helpers (hms, nrs, nfu, …) with a gum UI
│   ├── git.nix · ssh.nix · direnv.nix · fonts.nix · jq.nix · neocats.nix · python.nix
│   ├── brave-nightly.nix · kitty.nix · obs.nix                          # NixOS only (GUI)
│   ├── hyprland.nix · waybar.nix · rofi.nix  # NixOS only (Wayland-bound or conflict)
│   └── hypr/                 #   Hyprland Lua config: hyprland.lua + modules/*.lua, wallpapers
├── overlays/default.nix      # overrides pkgs.warp-terminal with the local package
├── pkgs/
│   ├── brave-nightly/        # local Brave Nightly package      (x86_64-linux only)
│   └── warp-terminal/        # local Warp package + versions/update script (Linux only)
└── hosts/
    ├── ubuntu-mac/
    │   └── home.nix          # Ubuntu HM profile — imports cli-base + linux siblings
    └── mac/
        └── home.nix          # macOS HM profile — imports cli-base; accepts injected `username`
```

Add a package once in `home-manager/packages/<bucket>.nix` → propagates to every profile that imports that bucket.

---

## Daily use

Shell helpers from `home-manager/zsh/nix-helpers.zsh` (wrap [nh](https://github.com/nix-community/nh)):

| Command | Does |
|---|---|
| `hms [-p] [profile]` | home-manager switch (auto-detects the profile; `-p` opens a picker) |
| `nrs [host]` | nixos-rebuild switch (NixOS only) |
| `nfu [inputs…]` | `nix flake update` + table of what changed, then offers `hms` |
| `nclean` | clean old generations (asks first, shows space freed) |
| `nsearch [query]` | search nixpkgs |
| `ngen [--system]` | pick a generation and activate it (rollback) |
| `nixprofiles` | list the flake's home-manager profiles |
| `nxhelp` | this list |

`NO_COLOR=1` gives plain output; `NX_MOTION=0` disables animation; `NX_ICONS=0` drops Nerd Font icons.

Repo tooling: `nix fmt` (nixfmt), `nix develop` (nixd, statix, deadnix), `nix flake check` (evaluates/builds the profiles of the current system).

---

## Apply

### ❄️ NixOS (canonical)

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#pxndxs   # or: nrs
home-manager switch --flake ~/.config/nixos#pxndxs@pxndxs  # or: hms
```

### 🐧 Ubuntu / non-NixOS

Complete step-by-step from a fresh Ubuntu install:

1. **Install Nix** (see [Prerequisites](#prerequisites)).
2. **Enable flakes** (Determinate installer does this automatically; otherwise add to `~/.config/nix/nix.conf`).
3. **Install `home-manager` CLI** (optional — you can skip this and use `nix run` instead):
   ```bash
   nix profile install home-manager/master
   ```
4. **Clone the repo**:
   ```bash
   git clone git@github.com:pxnditxyr/nixos.git ~/.config/nixos
   ```
5. **Apply**:
   ```bash
   home-manager switch --flake ~/.config/nixos#pxndxs@ubuntu-mac -b backup
   ```
   `-b backup` renames any pre-existing dotfile to `*.backup` instead of failing.

   First-time bootstrap (no `home-manager` binary yet):
   ```bash
   nix run home-manager/master -- switch --flake ~/.config/nixos#pxndxs@ubuntu-mac -b backup
   ```
6. **Confirm**: `echo $SHELL` → `/usr/bin/zsh`; `which fd ripgrep` → paths under `~/.nix-profile/`.

### 🍎 macOS (Apple Silicon, headless)

Complete step-by-step from a fresh macOS install:

1. **Install Nix** (see [Prerequisites](#prerequisites)). The Determinate installer handles flakes and daemon setup automatically.
2. **Clone the repo** (repo lives at `~/.config/nixos`):
   ```bash
   mkdir -p ~/.config
   git clone git@github.com:pxnditxyr/nixos.git ~/.config/nixos
   ```
3. **Apply** — pick the profile whose `username` matches the current Mac:
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
4. **Confirm**: `echo $SHELL` → `/bin/zsh` (macOS system zsh); `which fd ripgrep` → paths under `/Users/<username>/.nix-profile/`.

> **GUI apps** (Warp, Brave, OBS, Raycast, …) are **not** managed by this flake on macOS — install them via Homebrew casks or the App Store.

#### Identity injection

Both Mac profiles share `hosts/mac/home.nix`. The flake passes a per-profile `username` through `extraSpecialArgs`; `hosts/mac/home.nix` sets `home.username = username` and `home-manager/platform.nix` derives `home.homeDirectory = "/Users/${username}"`. Add a new Mac by appending one block to `flake.nix#homeConfigurations`.

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
4. `hms` (or `home-manager switch --flake .#<username>@<host>`).

---

## Rollback

```bash
ngen            # pick a home-manager generation and activate it
ngen --system   # NixOS: roll back the system generation
```

Old generations stay until explicit GC:

```bash
home-manager expire-generations '-7 days'
nix store gc
```

---

## Troubleshooting

**`error: experimental Nix feature 'flakes' is disabled`**
Add `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf` (non-NixOS) or to `nix.settings.experimental-features` in `configuration.nix` (NixOS). Restart the Nix daemon: `sudo systemctl restart nix-daemon` (Linux) or `sudo launchctl kickstart -k system/org.nixos.nix-daemon` (macOS).

**`home-manager: command not found`**
Skip the binary and run directly:
```bash
nix run home-manager/master -- switch --flake .#<username>@<host> -b backup
```

**`error: ... is marked as broken`** or **`unfree package`**
The `nixpkgs-config.nix` module sets `allowUnfree = true`. If you see this, verify the module is imported (check with `home-manager edit` or `nix flake check`).

**`git add` after adding a new file**
Nix flakes only evaluate tracked files. If `nix flake check` or `home-manager switch` silently ignores a new `.nix` file, run `git add <file>` first.

**NVIDIA / Hyprland — session not in SDDM login screen**
Run `sudo nixos-rebuild switch --flake .#pxndxs` to install the system-level `programs.hyprland` config. The HM profile alone does not register the Wayland session with the display manager.

**`error: collision between ... ngrok`**
`packages/dev.nix` wraps `ngrok` in `lib.hiPrio` to resolve the `bin/ngrok` collision with `pyngrok`. If you see this error on a fresh eval, ensure you are using a lockfile with the current `nixpkgs` revision (`git pull && nfu`).

**Home Manager switch fails with conflict on existing dotfile**
Pass `-b backup`: `home-manager switch --flake .#<profile> -b backup`. This renames conflicting files to `*.backup` instead of aborting.

---

## Excluded from `pxndxs@ubuntu-mac` and why

| Module | Reason |
|---|---|
| `hyprland.nix` | Wayland-only compositor; host is X11. |
| `waybar.nix` | Hyprland status bar; gnome-panel owns top bar. |
| `rofi.nix` | Would clobber `~/.config/rofi/whitesur.rasi` (Spotlight, hand-tuned). |
| `brave-nightly.nix` | apt provides Brave Nightly. |
| `kitty.nix` | Terminal comes from apt (Warp). |
| `obs.nix` | Install via apt if/when needed. |
| `packages/gui.nix` | warp-terminal, mangohud, karere — apt or unused. |

Restore any of these by adding the import back to `hosts/ubuntu-mac/home.nix`.

---

## Excluded from `*@mac` and why

Strict CLI-only profile. Anything that ships a GUI, depends on a Linux compositor, or is Linux-bound at the package level is omitted.

| Module / bucket | Reason |
|---|---|
| `hyprland.nix`, `waybar.nix`, `rofi.nix` | Wayland / X11 stack; no compositor on macOS. |
| `brave-nightly.nix`, `kitty.nix`, `obs.nix` | GUI apps — install via Homebrew cask. |
| `chromium.nix` *(if reintroduced)* | `programs.chromium` HM module is Linux-bound. |
| `packages/gui.nix` | `warp-terminal`, `mangohud`, `karere` — Linux GUI / Vulkan / Wayland. |
| `packages/core-linux.nix` | `xclip` (X11), `clang_multi` (Linux multilib). |
| `packages/cli-modern-linux.nix` | `playerctl` (MPRIS/D-Bus), `qalculate-qt` (Qt). |

The flake also gates the custom `brave-nightly` and `warp-terminal` derivations behind `pkgs.stdenv.hostPlatform.isLinux` via `lib.optionalAttrs`, so `nix flake check` on `aarch64-darwin` does not try to build them.
