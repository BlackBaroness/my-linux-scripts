#!/bin/bash

# Fail if any error occurred
set -e

function main() {
  wide_log "Checking configuration..."
  load_configuration "$@"

  wide_log "Checking requirements..."
  check_for_superuser

  wide_log "Running APT..."
  run_apt

  wide_log "Running pacman-mirrors..."
  run_pacman_mirrors

  wide_log "Running pamac..."
  run_pamac

  wide_log "Running ferium..."
  run_ferium

  wide_log "Running SDKMAN..."
  run_sdkman

  wide_log "Running BleachBit..."
  run_bleachbit

  wide_log "Running fstrim..."
  config_run_fstrim

  wide_log "Upgrade completed!"
}

function wide_log() {
  echo ""
  # shellcheck disable=SC2003
  echo "============================ ${1} ==========================================================================================" | rev | cut -c"$(expr length "$1")"- | rev
  echo ""
}

function side_log() {
  echo ""
  echo "==========> ${1}"
  echo ""
}

function command_log() {
  side_log "${1} | Running \"${2}\""
}

function load_configuration() {
    config_allow_root=false
    config_avoid_sudo=false
    config_skip_apt=false
    config_skip_apt_update=false
    config_skip_apt_upgrade=false
    config_skip_apt_autoremove=false
    config_skip_apt_clean=false
    config_skip_pamac=false
    config_skip_pamac_upgrade=false
    config_skip_pamac_cleanup=false
    config_skip_pacman_mirrors=false
    config_skip_ferium=false
    config_skip_sdkman=false
    config_skip_sdkman_selfupdate=false
    config_skip_sdkman_update=false
    config_skip_sdkman_upgrade=false
    config_skip_sdkman_clean=false
    config_skip_bleachbit=false
    config_skip_bleachbit_current=false
    config_skip_bleachbit_sudo=false
    config_run_fstrim=false

    options=$*
    for argument in $options; do
      case $argument in
      --allow-root) config_allow_root=true ;;
      --avoid-sudo) config_avoid_sudo=true ;;
      --skip-apt) config_skip_apt=true ;;
      --skip-apt-update) config_skip_apt_update=true ;;
      --skip-apt-upgrade) config_skip_apt_upgrade=true ;;
      --skip-apt-autoremove) config_skip_apt_autoremove=true ;;
      --skip-apt-clean) config_skip_apt_clean=true ;;
      --skip-pamac) config_skip_pamac=true ;;
      --skip-pamac-upgrade) config_skip_pamac_upgrade=true ;;
      --skip-pamac-cleanup) config_skip_pamac_cleanup=true ;;
      --skip-pacman-mirrors) config_skip_pacman_mirrors=true ;;
      --skip-ferium) config_skip_ferium=true ;;
      --skip-sdkman) config_skip_sdkman=true ;;
      --skip-sdkman-selfupdate) config_skip_sdkman_selfupdate=true ;;
      --skip-sdkman-update) config_skip_sdkman_update=true ;;
      --skip-sdkman-upgrade) config_skip_sdkman_upgrade=true ;;
      --skip-sdkman-clean) config_skip_sdkman_clean=true ;;
      --skip-bleachbit) config_skip_bleachbit=true ;;
      --skip-bleachbit-current) config_skip_bleachbit_current=true ;;
      --skip-bleachbit-sudo) config_skip_bleachbit_sudo=true ;;
      --run-fstrim) config_run_fstrim=true ;;
      *) echo "Unknown option $argument" >&2 && exit 1 ;;
      esac
    done

    if $config_avoid_sudo; then
      side_log "Commands which require sudo will not be executed because of your configuration."
    fi
}

function check_for_superuser() {
  if ! $config_allow_root && [ "$EUID" -eq 0 ]; then
    side_log "You shouldn't run this script as root."
    side_log "If you know what you do, add --allow-root argument."
    exit 1
  fi
}

# =================================================================
# APT
# =================================================================

function run_apt() {
  if $config_skip_apt; then
    side_log "APT is skipped..."
  elif ! command -v apt >/dev/null; then
    side_log "APT is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "APT not available because you avoid commands with sudo."
  else
    apt_update
    apt_upgrade
    apt_autoremove
    apt_clean
  fi
}

function apt_update() {
  if $config_skip_apt_update; then
    side_log "APT | Update is skipped..."
  else
    command_log "APT" "sudo apt update"
    sudo apt update
  fi
}

function apt_upgrade() {
  if $config_skip_apt_upgrade; then
    side_log "APT | Upgrade is skipped..."
  else
    command_log "APT" "sudo apt full-upgrade -y"
    sudo apt full-upgrade -y
  fi
}

function apt_autoremove() {
  if $config_skip_apt_autoremove; then
    side_log "APT | Autoremove is skipped..."
  else
    command_log "APT" "sudo apt autoremove -y"
    sudo apt autoremove -y
  fi
}

function apt_clean() {
  if $config_skip_apt_clean; then
    side_log "APT | Clean is skipped..."
  else
    command_log "APT" "sudo apt clean"
    sudo apt clean
  fi
}

# =================================================================
# pamac
# =================================================================

function run_pamac() {
  if $config_skip_pamac; then
    side_log "Pamac is skipped..."
  elif ! command -v pamac >/dev/null; then
    side_log "Pamac is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "Pamac not available because you avoid commands with sudo."
  else
    pamac_upgrade
    pamac_cleanup
  fi
}

function pamac_upgrade() {
  if $config_skip_pamac_upgrade; then
    side_log "Pamac | Upgrade is skipped..."
  else
    command_log "Pamac" "pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel"
    pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel
  fi
}

function pamac_cleanup() {
  if $config_skip_pamac_cleanup; then
    side_log "Pamac | Cleanup is skipped..."
  else
    command_log "Pamac" "pamac remove --no-confirm --orphans"
    set +e
    pamac remove --no-confirm --orphans
    set -e
    command_log "Pamac" "pamac clean --no-confirm --verbose --build-files"
    pamac clean --no-confirm --verbose --build-files --keep 0
  fi
}

# =================================================================
# pacman-mirrors
# =================================================================

function run_pacman_mirrors() {
  if $config_skip_pacman_mirrors; then
    side_log "pacman-mirrors is skipped..."
  elif ! command -v pacman-mirrors >/dev/null; then
    side_log "pacman-mirrors is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "pacman-mirrors not available because you avoid commands with sudo."
  else
    command_log "pacman-mirrors" "sudo pacman-mirrors --fasttrack --timeout 2"
    sudo pacman-mirrors --fasttrack --timeout 2
  fi
}

# =================================================================
# ferium
# =================================================================

function run_ferium() {
  if $config_skip_ferium; then
    side_log "Ferium is skipped..."
  elif ! command -v ferium >/dev/null; then
    side_log "Ferium is not installed, skipping..."
  else
    command_log "Ferium" "ferium upgrade"
    ferium upgrade
  fi
}

# =================================================================
# SDKMAN
# =================================================================

function run_sdkman() {
  if $config_skip_sdkman; then
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

function sdkman_selfupdate() {
  if $config_skip_sdkman_selfupdate; then
    side_log "SDKMAN selfupdate is skipped..."
  else
    command_log "SDKMAN" "sdk selfupdate"
    sdk selfupdate
  fi
}

function sdkman_update() {
  if $config_skip_sdkman_update; then
    side_log "SDKMAN update is skipped..."
  else
    command_log "SDKMAN" "sdk update"
    sdk update
  fi
}

sdkman_upgrade() {
  if $config_skip_sdkman_upgrade; then
    side_log "SDKMAN upgrade is skipped..."
  else
    command_log "SDKMAN" "sdk upgrade"
    sdk upgrade
  fi
}

sdkman_clean() {
  if $config_skip_sdkman_clean; then
    side_log "SDKMAN clean is skipped..."
  else
    command_log "SDKMAN" "sdk flush"
    sdk flush
  fi
}

# BleachBit

run_bleachbit() {
  if $config_skip_bleachbit; then
    side_log "BleachBit is skipped..."
  elif ! command -v bleachbit >/dev/null; then
    side_log "BleachBit is not installed, skipping..."
  else
    # Current user
    if $config_skip_bleachbit_current; then
      side_log "BleachBit | Run with current user is skipped..."
    else
      command_log "BleachBit" "bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
      bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
    fi

    # Sudo
    if $config_skip_bleachbit_sudo; then
      side_log "BleachBit | Run with sudo is skipped..."
    elif $config_avoid_sudo; then
      side_log "BleachBit | Run with sudo is skipped because you avoid sudo..."
    else
      command_log "BleachBit" "sudo bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
      sudo bleachbit --clean firefox.cache firefox.crash_reports firefox.vacuum firefox.backup discord.vacuum discord.cache system.cache system.clipboard system.desktop_entry system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache journald.clean system.localizations
    fi
  fi
}

# fstrim

config_run_fstrim() {
  if ! [[ $run_ftrim ]]; then
    side_log "fstrim is skipped..."
  elif $config_avoid_sudo; then
    side_log "fstrim not available because you avoid commands with sudo."
  else
    command_log "fstrim" "sudo fstrim --all --verbose --quiet-unsupported"
    sudo fstrim --all --verbose --quiet-unsupported
  fi
}

# ===========================================

main "$@"