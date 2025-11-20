{ pkgs, ... }:
{
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

      user = {
        name = "Pxndxs 🐼";
        email = "pxnditxyr@gmail.com";
      };

      init.defaultBranch = "main";

      # Core settings
      core = {
        editor = "nvim";
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
        autocorrect = 10;  # Auto-corrige comandos después de 1 segundo
      };

      # Performance
      feature = {
        manyFiles = true;  # Optimiza para repos grandes
      };
    };

    # Ignores globales
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
