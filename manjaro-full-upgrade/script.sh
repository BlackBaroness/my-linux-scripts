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
  side_log "Running BleachBit as current user..."
  sudo bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations

  side_log "Running BleachBit as root..."
  bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
}

trim_ssd() {
  sudo fstrim --all --verbose --quiet-unsupported
}

skipSdkman=
skipMirrorList=
skipPamacUpgrade=
skipPamacCleanup=
skipBleachbit=
skipTrim=

main() {
  wide_log "Checking requirements..."
  check_requirements

  if [ "$skipSdkman" ]; then
    side_log "SDKMAN! upgrade disabled, skipping..."
  else
    if sdkman_available; then
      enable_sdkman
      wide_log "SDKMAN! found. Running upgrade for it..."
      upgrade_sdkman
      wide_log "Running SDKMAN! cleanup..."
      clean_sdkman
    fi
  fi

  if [ "$skipMirrorList" ]; then
    side_log "Mirrorlist update disabled, skipping..."
  else
    wide_log "Updating mirror list..."
    update_mirrors
  fi

  if [ "$skipPamacUpgrade" ]; then
    side_log "Pamac upgrade disabled, skipping..."
  else
    wide_log "Upgrading pamac packages..."
    upgrade_pamac
  fi

  if [ "$skipPamacCleanup" ]; then
    side_log "Pamac cleanup disabled, skipping..."
  else
    wide_log "Cleaning pamac..."
    clean_pamac
  fi

  if [ "$skipBleachbit" ]; then
    side_log "BleachBit disabled, skipping..."
  else
    wide_log "Cleaning system via BleachBit..."
    clean_bleachbit
  fi

  if [ "$skipTrim" ]; then
    side_log "TRIM disabled, skipping..."
  else
    wide_log "Running TRIM at SSD (if supported)..."
    trim_ssd
  fi

  wide_log "Upgrade completed!"
}

options=$*
for argument in $options; do
  case $argument in
  --skip-sdkman) skipSdkman=true ;;
  --skip-mirrorlist) skipMirrorList=true ;;
  --skip-pamac-upgrade) skipPamacUpgrade=true ;;
  --skip-pamac-cleanup) skipPamacCleanup=true ;;
  --skip-bleachbit) skipBleachbit=true ;;
  --skip-trim) skipTrim=true ;;
  esac
done

main
