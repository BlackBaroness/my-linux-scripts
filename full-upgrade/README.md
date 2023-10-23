Distro independent customizable system upgrade script, written with Bash.

### Steps
1. Runs **[APT](https://manpages.ubuntu.com/manpages/xenial/man8/apt.8.html) - package manager.** 
   Script updates packages and cleans orphans & caches.
2. Runs **[pacman-mirrors](https://wiki.manjaro.org/index.php/Pacman-mirrors) - mirror updater for Manjaro.**
   Script searches for the best mirrors available.
3. Runs **[Pamac](https://wiki.manjaro.org/index.php/Pamac) - package manager for Manjaro.**
   Script updates packages and cleans orphans & caches (AUR included).
4. Runs **[Ferium](https://github.com/gorilla-devs/ferium) - Minecraft mod manager.**
   Script updates mods (only for selected profile - ferium restriction).
5. Runs **[SDKMAN](https://sdkman.io/) - SDK manager.**
   Script updates downloaded SDKs and clean cache.
   Also updates SDKMAN itself.
6. Runs **[BleachBit](https://www.bleachbit.org/) - system cleaning software.**
   Script cleans a lot of junk from many applications.
   Is uses all available clean options which **will not delete sensitive data**, like browser sessions.
   Only junk.
7. Runs **[fstrim](https://man7.org/linux/man-pages/man8/fstrim.8.html) - SSD TRIM utility, included in the Linux kernel.**
   Script sends TRIM to the all supported devices, ignoring unsupported ones.

**You don't need to install anything to run this script; unavailable software will be just ignored.**

### Root policy

By default, this script discards running as root because of security.
You can disable this requirement via configuration.

At the same time, script uses `sudo` for commands that need it. If you don't know root password or don't want to give
access to script, you can disable all commands that require superuser access via configuration.

### Configuration:

**Common:**

- `--allow-root` allow running the script as root. Note that some programs like SDKMAN are being installed as user, so may not work.
- `--avoid-sudo` don't call commands that potentially will require superuser password, such as `sudo`.

**APT:**

- `--skip-apt` do not touch APT at all.
- `--skip-apt-update` do not run `apt update`.
- `--skip-apt-upgrade` do not run `apt full-upgrade`.
- `--skip-apt-autoremove` do not run `apt autoremove`.
- `--skip-apt-clean` do not run `apt clean`.

**Pamac:**

- `--skip-pamac` do not touch Pamac at all.
- `--skip-pamac-upgrade` do not upgrade Pamac packages.
- `--skip-pamac-cleanup` do not clean Pamac orphans and installation caches.

**pacman-mirrors:**

- `--skip-pacman-mirrors` do not update mirrors list.

**Ferium:**

- `--skip-ferium` do not touch Ferium at all.

**SDKMAN:**

- `--skip-sdkman` do not touch SDKMAN at all.
- `--skip-sdkman-selfupdate` do not update SDKMAN itself.
- `--skip-sdkman-update` do not update SDKMAN candidates list.
- `--skip-sdkman-upgrade` do not upgrade SDKMAN candidates.
- `--skip-sdkman-clean` do not clean SDKMAN.

**BleachBit:**

- `--skip-bleachbit` do not touch BleachBit at all.
- `--skip-bleachbit-current` do not run BleachBit with current user.
- `--skip-bleachbit-sudo` do not run BleachBit with `sudo`.

**fstrim:**

- `--run-fstrim` send TRIM to supported devises. Disabled by default
  because [frequently TRIM usage can be harmful for your SSD](https://man7.org/linux/man-pages/man8/fstrim.8.html).

### Usage:

You can run this script without saving to disk with something like this:

```bash
curl -s -L https://github.com/BlackBaroness/my-linux-scripts/raw/master/full-upgrade/script.sh | bash -s -- --skip-fstrim
```
