# NixOS Installation Guide: From Fresh Install to Your Fork

This guide will walk you through installing NixOS using a forked flake configuration. This process allows you to use a shared base configuration while maintaining your own customizations and still being able to pull updates from the upstream repository.

## Prerequisites

Before starting, make sure you:
- Have created a GitHub account
- Have forked this repository to your own GitHub account
- Have downloaded the [NixOS minimal ISO](https://nixos.org/download.html#nixos-iso) and created a bootable USB drive

## Part 1: Standard NixOS Installation

Follow the [official NixOS installation guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual) through the partitioning and mounting steps. This covers:

1. **Boot from the USB drive** (Section 2.2 of the manual)
2. **Connect to the internet** (Section 2.3.2)
3. **Partition your disks** (Section 2.3.3)
4. **Format your partitions** (Section 2.3.4)
5. **Mount your filesystems** (Section 2.3.5)

### STOP HERE - Do Not Generate Config Yet

Before running `nixos-generate-config`, proceed to Part 2.

## Part 2: Generate Hardware Configuration

Now we'll generate the hardware configuration that we'll need later:

```bash
# Generate the hardware configuration
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix` which contains your system's hardware-specific settings. **We'll need it later.**

## Part 3: Complete Basic Installation

Continue with the basic NixOS installation using the generated configuration:

```bash
# Install NixOS with the default configuration
nixos-install

# Set the root password when prompted
# Also set your user password if you created a user account
# (If you didn't, you'll log in as root initially)

# Reboot into your new system
reboot
```

Remove the USB drive when prompted.

## Part 4: Clone Your Forked Repository

After rebooting, log in and set up your forked configuration:

```bash
# Get git temporarily (if git not installed)
nix-shell -p git

# Clone your forked repository
cd ~
git clone https://github.com/dokkodo1/nixos-config.git configurations
cd configurations

# Exit the nix-shell
exit
```

## Part 5: Customize Your Configuration

Now customize the flake for your system:

```bash
cd ~/configurations

# Copy the hardware configuration
cp /etc/nixos/hardware-configuration.nix ~configurations/hosts/default/

# Edit the flake configuration
nano flake.nix  # or vim, or your preferred editor
```

Make the following changes:
- Update the hostname and username in flake.nix
- Update any system-specific packages
- Ensure the hardware-configuration.nix is imported in the right place

## Part 6: Rebuild with Your Configuration

Now rebuild the system with your customized flake:

```bash
cd ~/configurations

# Rebuild with flake, enabling experimental features for this one command
sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME --extra-experimental-features "nix-command flakes"
```

**Important:** Replace `YOUR-HOSTNAME` with the hostname you configured in your flake. The default name is `default`

After this completes, you'll have your full configuration active, including all the tools needed for the next steps.

## Part 7: Authenticate with GitHub

Now we'll set up SSH authentication using the GitHub CLI:

```bash
cd ~/configurations

# Authenticate with GitHub
gh auth login
```

Follow the prompts:
1. **What account?** → GitHub.com
2. **Preferred protocol?** → SSH
3. **Generate new SSH key?** → Yes
4. **Passphrase?** → (optional - press Enter to skip)
5. **Title for key?** → "NixOS Machine" (or whatever you prefer)
6. **How to authenticate?** → Login with a web browser

You'll see a code like `ABCD-1234`. On your phone or another device:
- Open https://github.com/login/device
- Enter the code shown
- Authorize the GitHub CLI

The `gh` CLI will automatically:
- Generate your SSH key
- Upload it to your GitHub account
- Configure git to use it

## Part 8: Set Up Git Remotes

Configure your repository to track both your fork and the upstream repository:

```bash
cd ~/configurations

# Set your fork as the origin (if not already set correctly)
git remote set-url origin git@github.com:YOUR-USERNAME/your-repo-name.git

# Add the original repository as upstream
git remote add upstream git@github.com:dokkodo1/nixos-config.git

# Verify the remotes are correct
git remote -v
```

You should see:
```
origin    git@github.com:YOUR-USERNAME/your-repo-name.git (fetch)
origin    git@github.com:YOUR-USERNAME/your-repo-name.git (push)
upstream  git@github.com:dokkodo1/nixos-config.git (fetch)
upstream  git@github.com:dokkodo1/nixos-config.git (push)
```

## Part 9: Commit and Push Your Changes

Save your customizations to your fork:

```bash
cd ~/configurations

# Stage all your changes
git add .

# Commit with a descriptive message
git commit -m "Initial customization for my system"

# Push to your fork on GitHub
git push -u origin main
```

## Installation Complete!

Your system is now:
- Running your customized NixOS configuration
- Tracking your fork on GitHub
- Ready to pull updates from upstream
- Fully configured with all your packages and settings

## Maintaining Your System

### Making Changes to Your Configuration

Whenever you want to modify your system:

```bash
cd ~/configurations

# Edit your configuration
nano flake.nix  # or any other config files

# Rebuild the system (flakes are now enabled permanently)
sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME

# Commit your changes
git add .
git commit -m "Description of changes"

# Push to your fork
git push origin main
```

### Pulling Updates from Upstream

When the upstream repository has updates you want to include:

```bash
cd ~/configurations

# Fetch the latest changes from upstream
git fetch upstream

# Merge upstream changes into your configuration
git merge upstream/main

# If there are conflicts, resolve them:
# 1. Open the conflicting files
# 2. Look for conflict markers: <<<<<<<, =======, >>>>>>>
# 3. Decide what to keep from each version
# 4. Remove the conflict markers
# 5. Save the files

# After resolving conflicts (if any), stage and commit
git add .
git commit -m "Merge upstream changes"

# Test the new configuration
sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME

# If everything works, push to your fork
git push origin main
```

### Understanding the Three Git Layers

Think of your setup like this:

```
Upstream Repo (Original)
    ↓ (you pull updates)
Your Local Copy
    ↓ (you push changes)
Your Fork (on GitHub)
```

- **Upstream** = The original repository. You can only read from this (pull updates).
- **Local** = The files on your computer. This is where you make changes.
- **Origin** (your fork) = Your personal backup on GitHub. You can read and write to this.

## Troubleshooting

### If the rebuild fails:

1. Check the error message carefully
2. Make sure your hostname in the command matches your flake configuration
3. Verify that hardware-configuration.nix is in the correct location
4. You can roll back to the previous configuration with:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

### If SSH authentication fails:

1. Check that you're using the SSH protocol (not HTTPS) for your Git remotes
2. Verify your SSH key is added to GitHub: https://github.com/settings/keys
3. Test SSH connection: `ssh -T git@github.com`

### If git merge creates conflicts:

Don't panic! Conflicts are normal when both you and upstream modified the same files. The conflict markers show you both versions, and you decide what to keep. When in doubt, prioritize keeping your personal customizations (username, packages) while adopting upstream improvements (bug fixes, new features).

## Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/packages)
- [NixOS Wiki](https://wiki.nixos.org/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - A great introduction to Nix concepts
