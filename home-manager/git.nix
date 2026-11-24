{ pkgs, lib, config, ... }:
let
  # Override omz git plugin shortcuts with the aliases below (single source).
  zshShortcuts = {
    gst = "s";
    glog = "l";
    glol = "ll";
    glola = "lg";
    glast = "last";
    ghist = "history";
    gdst = "ds"; # gds stays omz's diff --staged
    gpsf = "psf";
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

  # Stub untracked identity files once. Skipped on dry runs: a redirect would
  # still create the file even though HM's `run` only echoes.
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

    # No user.name/email: identity lives in untracked files (includes below).
    settings = {
      alias = {
        s = "status -sb";
        st = "status";

        lg = ''log --graph --abbrev-commit --decorate --pretty="format:%C(bold yellow)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(italic cyan)%s%C(reset) %C(cyan)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'';
        l = "log --oneline --decorate --graph --all";
        ll = "log --graph --pretty=format:'%C(yellow)%h%C(reset) - %C(cyan)%an%C(reset), %C(green)%ar%C(reset) : %s'";
        last = "log -1 HEAD --stat";
        history = "log --pretty=format:'%C(yellow)%h %C(reset)%ad %C(blue)%an%C(reset) - %s' --date=short";

        d = "diff";
        dc = "diff --cached";
        ds = "diff --stat";
        dw = "diff --word-diff";

        b = "branch";
        ba = "branch -a";
        bd = "branch -d";
        bdf = "branch -D";

        c = "commit";
        ca = "commit -a";
        cm = "commit -m";
        cam = "commit -am";
        amend = "commit --amend";
        amendf = "commit --amend --no-edit";

        co = "checkout";
        cob = "checkout -b";
        com = "checkout main";

        sw = "switch";
        swc = "switch -c";

        rs = "restore";
        rss = "restore --staged";

        ss = "stash";
        sp = "stash pop";
        sl = "stash list";
        sa = "stash apply";

        r = "remote";
        rv = "remote -v";

        pl = "pull";
        ps = "push";
        psf = "push --force-with-lease";

        unstage = "reset HEAD --";
        undo = "reset --soft HEAD~1";

        alias = "config --get-regexp ^alias\\.";
        ignored = "ls-files --others --ignored --exclude-standard";
        contributors = "shortlog -sn";
        branches = "branch --sort=-committerdate";
        tags = "tag -l";

        fixup = "commit --fixup";
        squash = "commit --squash";
        wip = "commit -am 'WIP' --no-verify";
        unwip = "reset HEAD~1";

        find = "log --all --oneline --grep";

        show-files = "show --name-only";
      };

      init.defaultBranch = "main";

      core = {
        editor = "neocats";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };

      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
      };

      merge = {
        conflictstyle = "zdiff3";
        tool = "vimdiff";
      };

      pull = {
        rebase = true;
      };

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      rebase = {
        autoStash = true;
        autoSquash = true;
      };

      status = {
        showUntrackedFiles = "all";
        submoduleSummary = true;
      };

      branch = {
        sort = "-committerdate";
      };

      fetch = {
        prune = true;
        pruneTags = true;
      };

      log = {
        date = "relative";
        abbrevCommit = true;
      };

      blame = {
        date = "relative";
        coloring = "repeatedLines";
      };

      help = {
        autocorrect = 10;
      };

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
      ".DS_Store"
      "Thumbs.db"

      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".vim/"

      "dist/"
      "build/"
      "*.log"

      "node_modules/"
      ".env"
      ".env.local"

      # nix build symlinks
      "result"
      "result-*"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
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
