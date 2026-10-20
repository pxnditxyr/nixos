{ pkgs, lib, config, ... }:
let
  # zsh shortcuts that run the git aliases below, overriding the omz git
  # plugin's version where they differ (HM writes shellAliases after the
  # plugins). Every other omz g* alias already does the same thing.
  # Single source of truth: the `alias` attrset in programs.git.settings.
  zshShortcuts = {
    gst = "s";          # status -sb
    glog = "l";         # oneline graph --all
    glol = "ll";
    glola = "lg";
    glast = "last";
    ghist = "history";
    gdst = "ds";        # diff --stat (gds stays omz's diff --staged)
    gpsf = "psf";       # push --force-with-lease
    gundo = "undo";
    gunstage = "unstage";
    gbr = "branches";
    gfind = "find";
    galias = "alias";
  };
in
{
  assertions = lib.mapAttrsToList (short: alias: {
    assertion = config.programs.git.settings.alias ? ${alias};
    message = "git.nix: zsh shortcut `${short}` points to missing git alias `${alias}`.";
  }) zshShortcuts;

  programs.zsh.shellAliases = lib.mapAttrs (_: alias: "git ${alias}") zshShortcuts;

  # Bootstrap untracked local identity files on every switch.
  # Idempotent: only writes a stub if the file is absent. User fills in real
  # name/email once; subsequent switches leave the file alone.
  # Skipped on dry runs: HM's `run` only echoes there, but a `run cat > f`
  # redirect would still create f (with the word "cat" in it).
  home.activation.gitLocalIdentityBootstrap =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ID_DIR="$HOME/.config/git/local"
      if [[ -v DRY_RUN ]]; then
        echo "gitLocalIdentityBootstrap: would create stubs in $ID_DIR if missing"
      else
        mkdir -p "$ID_DIR"
        chmod 700 "$ID_DIR"

        if [ ! -e "$ID_DIR/identity-personal" ]; then
          install -m600 /dev/stdin "$ID_DIR/identity-personal" <<'EOF'
      # Personal git identity — edit me. Not tracked by Nix or git.
      [user]
          # name = Your Name
          # email = you@example.com
      EOF
        fi

        if [ ! -e "$ID_DIR/identity-work" ]; then
          install -m600 /dev/stdin "$ID_DIR/identity-work" <<'EOF'
      # Work git identity — edit me. Not tracked by Nix or git.
      [user]
          # name = Your Work Name
          # email = work@example.com
      EOF
        fi
      fi
    '';

  programs.git = {
    enable = true;



    settings = {
      alias = {
        # Status shortcuts
        s = "status -sb";
        st = "status";

        # Log aliases
        lg = ''log --graph --abbrev-commit --decorate --pretty="format:%C(bold yellow)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(italic cyan)%s%C(reset) %C(cyan)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'';
        l = "log --oneline --decorate --graph --all";
        ll = "log --graph --pretty=format:'%C(yellow)%h%C(reset) - %C(cyan)%an%C(reset), %C(green)%ar%C(reset) : %s'";
        last = "log -1 HEAD --stat";
        history = "log --pretty=format:'%C(yellow)%h %C(reset)%ad %C(blue)%an%C(reset) - %s' --date=short";

        # Diff aliases
        d = "diff";
        dc = "diff --cached";
        ds = "diff --stat";
        dw = "diff --word-diff";

        # Branch aliases
        b = "branch";
        ba = "branch -a";
        bd = "branch -d";
        bD = "branch -D";

        # Commit aliases
        c = "commit";
        ca = "commit -a";
        cm = "commit -m";
        cam = "commit -am";
        amend = "commit --amend";
        amendf = "commit --amend --no-edit";

        # Checkout aliases
        co = "checkout";
        cob = "checkout -b";
        com = "checkout main";

        # Switch (modern alternative to checkout)
        sw = "switch";
        swc = "switch -c";

        # Restore (modern alternative to checkout for files)
        rs = "restore";
        rss = "restore --staged";

        # Stash aliases
        ss = "stash";
        sp = "stash pop";
        sl = "stash list";
        sa = "stash apply";

        # Remote aliases
        r = "remote";
        rv = "remote -v";

        # Pull/Push aliases
        pl = "pull";
        ps = "push";
        psf = "push --force-with-lease";  # Safer force push

        # Reset aliases
        unstage = "reset HEAD --";
        undo = "reset --soft HEAD~1";

        # Other useful aliases
        alias = "config --get-regexp ^alias\\.";  # Lista todos los aliases
        ignored = "ls-files --others --ignored --exclude-standard";
        contributors = "shortlog -sn";  # Lista contributors
        branches = "branch --sort=-committerdate";  # Lista branches por fecha
        tags = "tag -l";

        # Advanced aliases
        fixup = "commit --fixup";
        squash = "commit --squash";
        wip = "commit -am 'WIP' --no-verify";
        unwip = "reset HEAD~1";

        # Find commits by message
        find = "log --all --oneline --grep";

        # Show files in a commit
        show-files = "show --name-only";
      };

      # user.name / user.email intentionally NOT set here — credentials
      # live in untracked local files loaded via the `includes` directive
      # below. Keeps the public Nix repo free of personal identity data.

      init.defaultBranch = "main";

      # Core settings
      core = {
        editor = "neocats";
        autocrlf = "input";  # Evita problemas de line endings en Linux
        whitespace = "trailing-space,space-before-tab";
      };

      # Colors
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };

      # Diff settings
      diff = {
        algorithm = "histogram";  # Mejor algoritmo de diff
        colorMoved = "default";   # Detecta código movido
        colorMovedWS = "allow-indentation-change";
      };

      # Merge settings
      merge = {
        conflictstyle = "zdiff3";  # Mejor visualización de conflictos
        tool = "vimdiff";
      };

      # Pull/Push settings
      pull = {
        rebase = true;  # Usa rebase en lugar de merge por defecto
      };

      push = {
        default = "current";
        autoSetupRemote = true;  # Auto-setup remote branch on first push
      };

      # Rebase settings
      rebase = {
        autoStash = true;  # Auto-stash antes de rebase
        autoSquash = true;  # Auto-squash commits con fixup!
      };

      # Status settings
      status = {
        showUntrackedFiles = "all";
        submoduleSummary = true;
      };

      # Branch settings
      branch = {
        sort = "-committerdate";  # Ordena branches por fecha
      };

      # Fetch settings
      fetch = {
        prune = true;  # Auto-limpia remote branches eliminadas
        pruneTags = true;
      };

      # Log settings
      log = {
        date = "relative";
        abbrevCommit = true;
      };

      # Blame settings
      blame = {
        date = "relative";
        coloring = "repeatedLines";
      };

      # Help settings
      help = {
        autocorrect = 10;
      };

      # Performance
      feature = {
        manyFiles = true;
      };
    };

    includes = [
      { path = "~/.config/git/local/identity-personal"; }
      {
        condition = "gitdir:~/workspace/";
        path = "~/.config/git/local/identity-work";
      }
    ];

    ignores = [
      # OS files
      ".DS_Store"
      "Thumbs.db"

      # Editor files
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".vim/"

      # Build outputs
      "dist/"
      "build/"
      "*.log"

      # Dependencies
      "node_modules/"
      ".env"
      ".env.local"

      # Nix
      "result"
      "result-*"
    ];
  };

  # Delta - syntax highlighting pager for git diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;  # Integración explícita con git

    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;  # Vista lado a lado (izquierda=antes, derecha=después)
      syntax-theme = "OneHalfDark";

      features = "decorations";

      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };

      line-numbers-left-style = "cyan";
      line-numbers-right-style = "cyan";
      line-numbers-minus-style = 124;
      line-numbers-plus-style = 28;
    };
  };
}
