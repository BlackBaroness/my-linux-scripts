#!/bin/bash

wide_log() {
  echo ""
  echo "======================================================================================================"
  echo "$1"
  echo "======================================================================================================"
  echo ""
}

side_log() {
  echo ""
  echo "=======> ${1}"
  echo ""
}

check_requirements() {
  if [ "$(id -u)" == "0" ]; then
    side_log "Don't run this script as root." 1>&2
    exit 1
  fi

  if ! command -v pamac >/dev/null; then
    side_log "pamac-cli not found. Please install it first."
    exit 1
  fi

  if ! command -v bleachbit >/dev/null; then
    side_log "bleachbit not found. Please install it first."
    exit 1
  fi
}

sdkman_available() {
  if test -f "$HOME/.sdkman/bin/sdkman-init.sh"; then return; else false; fi
}

enable_sdkman() {
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

upgrade_sdkman() {
  sdk upgrade
  sdk update
}

clean_sdkman() {
  sdk flush
}

update_mirrors() {
  sudo pacman-mirrors --fasttrack 15 --api --protocols all
}

upgrade_pamac() {
  side_log "Upgrading both normal and AUR packages..."
  pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel
}

clean_pamac() {
  side_log "Removing junk packages..."
  pamac remove --no-confirm --orphans

  side_log "Removing installation caches..."
  pamac clean --no-confirm --verbose --build-files --keep 0
}

clean_bleachbit() {
  side_log "Running bleachbit as current user..."
  sudo bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations

  side_log "Running bleachbit as root..."
  bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
}

trim_ssd() {
  sudo fstrim --all --verbose --quiet-unsupported
}

main() {
  wide_log "Checking requirements..."
  check_requirements

  if sdkman_available; then
    enable_sdkman
    wide_log "SDKMAN! found. Running upgrade for it..."
    upgrade_sdkman
    wide_log "Running SDKMAN! cleanup..."
    clean_sdkman
  fi

  wide_log "Updating mirror list..."
  update_mirrors

  wide_log "Upgrading pamac packages..."
  upgrade_pamac

  wide_log "Cleaning pamac..."
  clean_pamac

  wide_log "Cleaning system via Bleachbit..."
  clean_bleachbit

  wide_log "Running TRIM at SSD (if supported)..."
  trim_ssd

  wide_log "Upgrade completed!"
}

main
