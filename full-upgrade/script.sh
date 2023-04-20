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
skip_bleachbit=false
skip_bleachbit_current=false
skip_bleachbit_sudo=false
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
  --skip-bleachbit) skip_bleachbit=true ;;
  --skip-bleachbit-current) skip_bleachbit_current=true ;;
  --skip-bleachbit-sudo) skip_bleachbit_sudo=true ;;
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

# BleachBit

run_bleachbit() {
  if $skip_bleachbit; then
    side_log "BleachBit is skipped..."
  elif ! command -v bleachbit >/dev/null; then
    side_log "BleachBit is not installed, skipping..."
  else
    # Current user
    if $skip_bleachbit_current; then
      side_log "BleachBit | Run with current user is skipped..."
    else
      command_log "BleachBit" "bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
      bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
    fi

    # Sudo
    if $skip_bleachbit_sudo; then
      side_log "BleachBit | Run with sudo is skipped..."
    elif $avoid_sudo; then
      side_log "BleachBit | Run with sudo is skipped because you avoid sudo..."
    else
      command_log "BleachBit" "sudo bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
      sudo bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
    fi
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

  wide_log "Running BleachBit"
  run_bleachbit

  wide_log "Running fstrim"
  run_fstrim

  wide_log "Upgrade completed!"
}

main