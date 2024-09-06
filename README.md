# 🐼 Pxndxs' Custom Nix Configuration 🛠️🏡

Welcome to 🐼 **Pxndxs' custom Nix configuration** setup guide for both **Nix** and **NixOS**! 🎉 Follow these steps to configure your environment and start using Home Manager with ease.

---

## 💻 Setting Up Home Manager on Non-NixOS Systems

If you're using a system other than NixOS, follow these steps to get started:

1. **Install Nix** 🛠️
   Head to the official Nix website and install Nix by following the instructions for your system: [Install Nix](https://nixos.org/download.html)

2. **Clone the Configuration Repository** 🗂️
   Clone your NixOS configuration repository using the following command:

```bash
git clone https://github.com/pxnditxyr/nixos.git ~/.config/nixos
```

   Then navigate to the directory with:

```bash
cd ~/.config/nixos
```

3. **Create Configuration Directory** 📁
   Create the required directories and configuration file by running the following commands:

```bash
mkdir -p ~/.config/nix
touch ~/.config/nix/nix.conf
```

4. **Enable Flakes Support** 🧩
   Add the necessary line to enable experimental features by running:

```bash
echo "extra-experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

5. **Install Home Manager** 📦
   Run the following command to install Home Manager using Nix:

```bash
nix shell nixpkgs#home-manager
```

6. **Apply the Configuration** 🛠️
   Now, run the following command to apply your Home Manager configuration using the Flake setup:

```bash
home-manager switch --flake .#pxndxs@pxndxs
```

7. **Set Zsh as Default Shell** 🐚
   If you prefer using Zsh, follow these steps to set it as your default shell:

   - First, add the Zsh binary to the list of valid shells by running the following command:

    ```bash
    echo "~/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
    ```
     This ensures that your Zsh installation is recognized as a valid shell.

   - Then, change the shell for your user:

    ```bash
    chsh -s ~/.nix-profile/bin/zsh
    ```

   - Optionally, change the shell for the superuser (if applicable):

    ```bash
    sudo chsh -s ~/.nix-profile/bin/zsh
    ```

8. **Sit Back & Enjoy!** 🎉

   Wait for the process to complete, and you're good to go! 😎

---

## 🐧 Setting Up Home Manager on NixOS

If you're on NixOS, it's even easier! 🎉

1. **Rebuild Your NixOS System** 🔄
   To rebuild your system with the latest configuration, run:

    ```bash
    sudo nixos-rebuild switch --flake .#pxndxs
    ```

2. **Rebuild Home Manager** 🏠
   For Home Manager, run the following command:

    ```bash
    home-manager switch --flake .#pxndxs@pxndxs
    ```

---

Now you're all set! 🚀 If you run into any issues, feel free to explore the [NixOS Manual](https://nixos.org/manual/nixos/stable/) for more details. Happy coding! ✨
