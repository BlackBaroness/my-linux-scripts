This script allows you to make full upgrade on Manjaro. 
Some parts can be used on other distros but I use `pamac-cli` as package manager,
so you have to install it.

### Steps:
1. Check requirements and fail if some of them are missing.
2. If [Ferium](https://github.com/gorilla-devs/ferium) is installed, run upgrade for current profile.
3. If [SDKMAN](https://sdkman.io/) is installed, upgrade and clean it.
4. Update mirrors list.
5. Upgrade all pamac packages.
6. Clean pamac orphans and installation caches.
7. Clean system with BleachBit (current user + root).
8. Send TRIM to all mounted SSDs (if supported).

### Requirements:
1. Do not run script as root.
2. You have to know root password (it will ask for it several times).
3. You have to install `pamac-cli` (installed in Manjaro by default) and [BleachBit](https://www.bleachbit.org/).

### Configuration:
- `--skip-ferium` don't touch Ferium at all.
- `--skip-sdkman` don't touch SDKMAN at all.
- `--skip-mirrorlist` don't update mirrorlist.
- `--skip-pamac-upgrade` don't upgrade pamac packages.
- `--skip-pamac-cleanup` don't clean pamac orphans and installation caches.
- `--skip-bleachbit` don't run BleachBit.
- `--skip-trim` don't send TRIM to SSDs.

### Usage:
By default, everything is enabled, but usually you need something like this:
```bash
curl -s -L https://github.com/BlackBaroness/my-linux-scripts/raw/master/manjaro-full-upgrade/script.sh | bash -s -- --skip-trim
```

Please note that [frequently TRIM usage can be harmful for your SSD](https://man7.org/linux/man-pages/man8/fstrim.8.html).
