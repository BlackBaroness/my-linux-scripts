#!/bin/bash

# Fail if any error occurred
set -e

# Settings
allow_root=false
avoid_sudo=false
skip_apt=false
skip_apt_update=false
skip_apt_upgrade=false
skip_apt_autoremove=false
skip_apt_clean=false
skip_pamac=false
skip_pamac_upgrade=false
skip_pamac_cleanup=false
skip_pacman_mirrors=false
skip_ferium=false
skip_sdkman=false
skip_sdkman_selfupdate=false
skip_sdkman_update=false
skip_sdkman_upgrade=false
skip_sdkman_clean=false
skip_fstrim=false

options=$*
for argument in $options; do
  case $argument in
  --allow-root) allow_root=true ;;
  --avoid-sudo) avoid_sudo=true ;;
  --skip-apt) skip_apt=true ;;
  --skip-apt-update) skip_apt_update=true ;;
  --skip-apt-upgrade) skip_apt_upgrade=true ;;
  --skip-apt-autoremove) skip_apt_autoremove=true ;;
  --skip-apt-clean) skip_apt_clean=true ;;
  --skip-pamac) skip_pamac=true ;;
  --skip-pamac-upgrade) skip_pamac_upgrade=true ;;
  --skip-pamac-cleanup) skip_pamac_cleanup=true ;;
  --skip-pacman-mirrors) skip_pacman_mirrors=true ;;
  --skip-ferium) skip_ferium=true ;;
  --skip-sdkman) skip_sdkman=true ;;
  --skip-sdkman-selfupdate) skip_sdkman_selfupdate=true ;;
  --skip-sdkman-update) skip_sdkman_update=true ;;
  --skip-sdkman-upgrade) skip_sdkman_upgrade=true ;;
  --skip-sdkman-clean) skip_sdkman_clean=true ;;
  --skip-fstrim) skip_fstrim=true ;;
  *) echo "Unknown option $argument" >&2 && exit 1 ;;
  esac
done

wide_log() {
  echo ""
  # shellcheck disable=SC2003
  echo "============================ ${1} ==========================================================================================" | rev | cut -c"$(expr length "$1")"- | rev
  echo ""
}

side_log() {
  echo ""
  echo "==========> ${1}"
  echo ""
}

command_log() {
  side_log "${1} | Running \"${2}\""
}

check_for_superuser() {
  if ! $allow_root && [ "$EUID" -eq 0 ]; then
    side_log "You shouldn't run this script as root."
    side_log "If you know what you do, add --allow-root argument."
    exit 1
  fi
}

log_sudo_state() {
  if $avoid_sudo; then
    side_log "Commands which require sudo will not be executed because of your configuration."
  fi
}

# APT

run_apt() {
  if $skip_apt; then
    side_log "APT is skipped..."
  elif ! command -v apt >/dev/null; then
    side_log "APT is not installed, skipping..."
  elif $avoid_sudo; then
    side_log "APT not available because you avoid commands with sudo."
  else
    apt_update
    apt_upgrade
    apt_autoremove
    apt_clean
  fi
}

apt_update() {
  if $skip_apt_update; then
    side_log "APT | Update is skipped..."
  else
    command_log "APT" "sudo apt update"
    sudo apt update
  fi
}

apt_upgrade() {
  if $skip_apt_upgrade; then
    side_log "APT | Upgrade is skipped..."
  else
    command_log "APT" "sudo apt full-upgrade -y"
    sudo apt full-upgrade -y
  fi
}

apt_autoremove() {
  if $skip_apt_autoremove; then
    side_log "APT | Autoremove is skipped..."
  else
    command_log "APT" "sudo apt autoremove -y"
    sudo apt autoremove -y
  fi
}

apt_clean() {
  if $skip_apt_clean; then
    side_log "APT | Clean is skipped..."
  else
    command_log "APT" "sudo apt clean"
    sudo apt clean
  fi
}

# Pamac

run_pamac() {
  if $skip_pamac; then
    side_log "Pamac is skipped..."
  elif ! command -v pamac >/dev/null; then
    side_log "Pamac is not installed, skipping..."
  elif $avoid_sudo; then
    side_log "Pamac not available because you avoid commands with sudo."
  else
    pamac_upgrade
    pamac_cleanup
  fi
}

pamac_upgrade() {
  if $skip_pamac_upgrade; then
    side_log "Pamac | Upgrade is skipped..."
  else
    command_log "Pamac" "pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel"
    pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel
  fi
}

pamac_cleanup() {
  if $skip_pamac_cleanup; then
    side_log "Pamac | Cleanup is skipped..."
  else
    command_log "Pamac" "pamac remove --no-confirm --orphans"
    set +e
    pamac remove --no-confirm --orphans
    set -e
    command_log "Pamac" "pamac clean --no-confirm --verbose --build-files --keep 0"
    pamac clean --no-confirm --verbose --build-files --keep 0
  fi
}

# pacman-mirrors

run_pacman_mirrors() {
  if $skip_pacman_mirrors; then
    side_log "pacman-mirrors is skipped..."
  elif ! command -v pacman-mirrors >/dev/null; then
    side_log "pacman-mirrors is not installed, skipping..."
  elif $avoid_sudo; then
    side_log "pacman-mirrors not available because you avoid commands with sudo."
  else
    command_log "pacman-mirrors" "sudo pacman-mirrors --fasttrack --timeout 2"
    sudo pacman-mirrors --fasttrack --timeout 2
  fi
}

# Ferium

run_ferium() {
  if $skip_ferium; then
    side_log "Ferium is skipped..."
  elif ! command -v ferium >/dev/null; then
    side_log "Ferium is not installed, skipping..."
  else
    command_log "Ferium" "ferium upgrade"
    ferium upgrade
  fi
}

# SDKMAN

run_sdkman() {
  if $skip_sdkman; then
    side_log "SDKMAN is skipped..."
  elif ! test -f "$HOME/.sdkman/bin/sdkman-init.sh"; then
    side_log "SDKMAN is not installed, skipping..."
  else
    command_log "SDKMAN" "source ${HOME}/.sdkman/bin/sdkman-init.sh"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdkman_selfupdate
    sdkman_update
    sdkman_upgrade
    sdkman_clean
  fi
}

sdkman_selfupdate() {
  if $skip_sdkman_selfupdate; then
    side_log "SDKMAN selfupdate is skipped..."
  else
    command_log "SDKMAN" "sdk selfupdate"
    sdk selfupdate
  fi
}

sdkman_update() {
  if $skip_sdkman_update; then
    side_log "SDKMAN update is skipped..."
  else
    command_log "SDKMAN" "sdk update"
    sdk update
  fi
}

sdkman_upgrade() {
  if $skip_sdkman_upgrade; then
    side_log "SDKMAN upgrade is skipped..."
  else
    command_log "SDKMAN" "sdk upgrade"
    sdk upgrade
  fi
}

sdkman_clean() {
  if $skip_sdkman_clean; then
    side_log "SDKMAN clean is skipped..."
  else
    command_log "SDKMAN" "sdk flush"
    sdk flush
  fi
}

# fstrim

run_fstrim() {
  if $skip_fstrim; then
    side_log "fstrim is skipped..."
  elif $avoid_sudo; then
    side_log "fstrim not available because you avoid commands with sudo."
  else
    command_log "fstrim" "sudo fstrim --all --verbose --quiet-unsupported"
    sudo fstrim --all --verbose --quiet-unsupported
  fi
}

# ===========================================

main() {
  wide_log "Checking requirements..."
  check_for_superuser

  wide_log "Checking sudo policy..."
  log_sudo_state

  wide_log "Running APT..."
  run_apt

  wide_log "Running pacman-mirrors"
  run_pacman_mirrors

  wide_log "Running pamac"
  run_pamac

  wide_log "Running ferium"
  run_ferium

  wide_log "Running SDKMAN"
  run_sdkman

  wide_log "Running fstrim"
  run_fstrim

  wide_log "Upgrade completed!"
}

main