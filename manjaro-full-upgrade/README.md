This script allows you to make full upgrade on Manjaro. 
Some parts can be used on other distros but I use `pamac-cli` as package manager,
so you have to install it.

Steps:
1. Check requirements and fail if some of them are missing.
2. If [SDKMAN!](https://sdkman.io/) installed, upgrade and clean it.
3. Upgrade all pamac packages.
4. Clean pamac orphans and installation caches.
5. Clean system with bleachbit (current user + root).
6. Send TRIM to SSD on `/` (if supported).

Requirements:
1. Do not run script as root.
2. You have to know root password (it will ask for it several times).
3. You have to install `pamac-cli` (installed in Manjaro by default) and [bleachbit](https://www.bleachbit.org/).