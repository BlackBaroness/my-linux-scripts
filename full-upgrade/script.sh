#!/bin/bash

# Fail if any error occurred
set -eu

function main() {
  wide_log "Checking configuration..."
  load_configuration "$@"

  wide_log "Checking requirements..."
  check_for_superuser

  wide_log "Running APT..."
  run_apt

  wide_log "Running Zypper..."
  run_zypper

  wide_log "Running pacman-mirrors..."
  run_pacman_mirrors

  wide_log "Running pamac..."
  run_pamac

  wide_log "Running Flatpak..."
  run_flatpak

  wide_log "Running SDKMAN..."
  run_sdkman

  wide_log "Running asdf..."
  run_asdf

  wide_log "Running ferium..."
  run_ferium

  wide_log "Running Gradle..."
  run_gradle

  wide_log "Running BleachBit..."
  run_bleachbit

  wide_log "Running post-upgrade actions..."
  run_postupgrade

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

function run_command() {
  side_log "${1} | Running \"${2}\""
  eval "${2}"
}

function load_configuration() {
    config_allow_root=false
    config_avoid_sudo=false
    config_skip_apt=false
    config_skip_apt_update=false
    config_skip_apt_upgrade=false
    config_skip_apt_autoremove=false
    config_skip_zypper=false
    config_skip_zypper_ref=false
    config_skip_zypper_upgrade=false
    config_skip_pamac=false
    config_skip_pamac_upgrade=false
    config_skip_pamac_cleanup=false
    config_skip_pacman_mirrors=false
    config_skip_flatpak=false
    config_skip_flatpak_update=false
    config_skip_flatpak_remove_unused=false
    config_skip_sdkman=false
    config_skip_sdkman_selfupdate=false
    config_skip_sdkman_update=false
    config_skip_sdkman_upgrade=false
    config_skip_sdkman_clean=false
    config_skip_asdf=false
    config_skip_asdf_update_self=false
    config_skip_asdf_update_plugins=false
    config_skip_ferium=false
    config_skip_gradle=false
    config_skip_gradle_stop=false
    config_run_gradle_clean=false
    config_skip_bleachbit=false
    config_skip_bleachbit_current=false
    config_skip_bleachbit_sudo=false
    config_wipe_user_cache=false
    config_wipe_root_cache=false
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
      --skip-zypper) config_skip_zypper=true ;;
      --skip-zypper-ref) config_skip_zypper_ref=true ;;
      --skip-zypper-upgrade) config_skip_zypper_upgrade=true ;;
      --skip-pacman-mirrors) config_skip_pacman_mirrors=true ;;
      --skip-pamac) config_skip_pamac=true ;;
      --skip-pamac-upgrade) config_skip_pamac_upgrade=true ;;
      --skip-pamac-cleanup) config_skip_pamac_cleanup=true ;;
      --skip-flatpak) config_skip_flatpak=true ;;
      --skip-flatpak-update) config_skip_flatpak_update=true ;;
      --skip-flatpak-remove-unused) config_skip_flatpak_remove_unused=true ;;
      --skip-sdkman) config_skip_sdkman=true ;;
      --skip-sdkman-selfupdate) config_skip_sdkman_selfupdate=true ;;
      --skip-sdkman-update) config_skip_sdkman_update=true ;;
      --skip-sdkman-upgrade) config_skip_sdkman_upgrade=true ;;
      --skip-sdkman-clean) config_skip_sdkman_clean=true ;;
      --skip-asdf) config_skip_asdf=true ;;
      --skip-asdf-update-self) config_skip_asdf_update_self=true ;;
      --skip-asdf-update-plugins) config_skip_asdf_update_plugins=true ;;
      --skip-ferium) config_skip_ferium=true ;;
      --skip-gradle) config_skip_gradle=true ;;
      --skip-gradle-stop) config_skip_gradle_stop=true ;;
      --run-gradle-clean) config_run_gradle_clean=true ;;
      --skip-bleachbit) config_skip_bleachbit=true ;;
      --skip-bleachbit-current) config_skip_bleachbit_current=true ;;
      --skip-bleachbit-sudo) config_skip_bleachbit_sudo=true ;;
      --wipe-user-cache) config_wipe_user_cache=true ;;
      --wipe-root-cache) config_wipe_root_cache=true ;;
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
    side_log "APT is skipped."
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
    side_log "APT | Update is skipped."
  else
    run_command "APT" "sudo apt update"
  fi
}

function apt_upgrade() {
  if $config_skip_apt_upgrade; then
    side_log "APT | Upgrade is skipped."
  else
    run_command "APT" "sudo apt full-upgrade -y"
  fi
}

function apt_autoremove() {
  if $config_skip_apt_autoremove; then
    side_log "APT | Autoremove is skipped."
  else
    run_command "APT" "sudo apt autoremove -y"
  fi
}

function apt_clean() {
  if $config_skip_apt_clean; then
    side_log "APT | Clean is skipped."
  else
    run_command "APT" "sudo apt clean"
  fi
}

# =================================================================
# Zypper
# =================================================================

function run_zypper() {
  if $config_skip_zypper; then
    side_log "Zypper is skipped."
  elif ! command -v zypper >/dev/null; then
    side_log "Zypper is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "Zypper not available because you avoid commands with sudo."
  else
    zypper_refresh
    zypper_upgrade
  fi
}

function zypper_refresh() {
  if $config_skip_zypper_ref; then
    side_log "Zypper | Refresh is skipped."
  else
    run_command "Zypper" "sudo zypper ref"
  fi
}

function zypper_upgrade() {
  if $config_skip_zypper_upgrade; then
    side_log "Zypper | Update is skipped."
  else
    run_command "Zypper" "sudo zypper dist-upgrade -y"
  fi
}

# =================================================================
# Flatpak
# =================================================================

function run_flatpak() {
  if $config_skip_flatpak; then
    side_log "Flatpak is skipped."
  elif ! command -v flatpak >/dev/null; then
    side_log "Flatpak is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "Flatpak not available because you avoid commands with sudo."
  else
    flatpak_update
    flatpak_remove_unused
  fi
}

function flatpak_update() {
  if $config_skip_flatpak_update; then
    side_log "Flatpak | Update is skipped."
  else
    run_command "Flatpak" "sudo flatpak update -y"
  fi
}

function flatpak_remove_unused() {
  if $config_skip_flatpak_remove_unused; then
    side_log "Flatpak | Remove unused is skipped."
  else
    run_command "Flatpak" "sudo flatpak uninstall --unused -y"
  fi
}

# =================================================================
# pamac
# =================================================================

function run_pamac() {
  if $config_skip_pamac; then
    side_log "Pamac is skipped."
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
    side_log "Pamac | Upgrade is skipped."
  else
    run_command "Pamac" "pamac update --no-confirm --force-refresh --enable-downgrade --aur --devel"
  fi
}

function pamac_cleanup() {
  if $config_skip_pamac_cleanup; then
    side_log "Pamac | Cleanup is skipped."
  else
    set +e
    run_command "Pamac" "pamac remove --no-confirm --orphans"
    set -eu
    run_command "Pamac" "pamac clean --no-confirm --verbose --build-files --keep 0"
  fi
}

# =================================================================
# pacman-mirrors
# =================================================================

function run_pacman_mirrors() {
  if $config_skip_pacman_mirrors; then
    side_log "pacman-mirrors is skipped."
  elif ! command -v pacman-mirrors >/dev/null; then
    side_log "pacman-mirrors is not installed, skipping..."
  elif $config_avoid_sudo; then
    side_log "pacman-mirrors not available because you avoid commands with sudo."
  else
    run_command "pacman-mirrors" "sudo pacman-mirrors --fasttrack --timeout 2"
  fi
}

# =================================================================
# SDKMAN
# =================================================================

function run_sdkman() {
  if $config_skip_sdkman; then
    side_log "SDKMAN is skipped."
  elif ! test -f "$HOME/.sdkman/bin/sdkman-init.sh"; then
    side_log "SDKMAN is not installed, skipping..."
  else
    run_command "SDKMAN" "source ${HOME}/.sdkman/bin/sdkman-init.sh"
    sdkman_selfupdate
    sdkman_update
    sdkman_upgrade
    sdkman_clean
  fi
}

function sdkman_selfupdate() {
  if $config_skip_sdkman_selfupdate; then
    side_log "SDKMAN selfupdate is skipped."
  else
    run_command "SDKMAN" "sdk selfupdate"
  fi
}

function sdkman_update() {
  if $config_skip_sdkman_update; then
    side_log "SDKMAN update is skipped."
  else
    run_command "SDKMAN" "sdk update"
  fi
}

function sdkman_upgrade() {
  if $config_skip_sdkman_upgrade; then
    side_log "SDKMAN upgrade is skipped."
  else
    run_command "SDKMAN" "sdk upgrade"
  fi
}

function sdkman_clean() {
  if $config_skip_sdkman_clean; then
    side_log "SDKMAN clean is skipped."
  else
    run_command "SDKMAN" "sdk flush"
  fi
}

# =================================================================
# asdf
# =================================================================

function run_asdf() {
  if $config_skip_asdf; then
    side_log "asdf is skipped."
  elif ! command -v asdf >/dev/null; then
    side_log "asdf is not installed, skipping..."
  else
    asdf_update_itself
    asdf_update_plugins
  fi
}

function asdf_update_itself() {
  if $config_skip_asdf_update_self; then
    side_log "asdf selfupdate is skipped."
  else
    run_command "asdf" "asdf update"
  fi
}

function asdf_update_plugins() {
  if $config_skip_asdf_update_plugins; then
    side_log "asdf plugins update is skipped."
  else
    run_command "asdf" "asdf plugin update --all"
  fi
}

# =================================================================
# ferium
# =================================================================

function run_ferium() {
  if $config_skip_ferium; then
    side_log "Ferium is skipped."
  elif ! command -v ferium >/dev/null; then
    side_log "Ferium is not installed, skipping..."
  else
    run_command "Ferium" "ferium upgrade"
  fi
}

# =================================================================
# Gradle
# =================================================================

function run_gradle() {
  if $config_skip_gradle; then
    side_log "Gradle is skipped."
  elif ! command -v gradle >/dev/null; then
    side_log "Gradle is not installed, skipping..."
  else
    gradle_stop
    gradle_clean
  fi
}

function gradle_stop() {
    if $config_skip_gradle_stop; then
      side_log "Gradle | Daemon stop is skipped."
    else
      run_command "Gradle" "gradle --stop"
    fi
}

function gradle_clean() {
    if $config_run_gradle_clean; then
      run_command "Gradle" "rm -rf ~/.gradle/caches/"
    else
      side_log "Gradle | Cache clean is skipped."
    fi
}

# =================================================================
# BleachBit
# =================================================================

function run_bleachbit() {
  if $config_skip_bleachbit; then
    side_log "BleachBit is skipped."
  elif ! command -v bleachbit >/dev/null; then
    side_log "BleachBit is not installed, skipping..."
  else
    # Current user
    if $config_skip_bleachbit_current; then
      side_log "BleachBit | Run with current user is skipped."
    else
      run_command "BleachBit" "bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
    fi

    # Sudo
    if $config_skip_bleachbit_sudo; then
      side_log "BleachBit | Run with sudo is skipped."
    elif $config_avoid_sudo; then
      side_log "BleachBit | Run with sudo is skipped because you avoid sudo."
    else
      run_command "BleachBit" "sudo bleachbit --clean adobe_reader.cache adobe_reader.tmp amsn.cache amsn.chat_logs amule.backup amule.known_clients amule.known_files amule.logs amule.temp apt.autoclean apt.autoremove apt.clean apt.package_lists audacious.cache audacious.log bash.history beagle.cache beagle.index beagle.logs brave.cache brave.vacuum chromium.cache chromium.vacuum d4x.history deepscan.backup deepscan.ds_store deepscan.thumbs_db deepscan.tmp deepscan.vim_swap_root deepscan.vim_swap_user discord.cache discord.vacuum dnf.autoremove dnf.clean_all easytag.history easytag.logs elinks.history emesene.cache emesene.logs epiphany.cache evolution.cache exaile.cache exaile.log firefox.backup firefox.cache firefox.vacuum flash.cache gftp.cache gftp.logs gimp.tmp gl-117.debug_logs gnome.run gnome.search_history google_chrome.cache google_chrome.vacuum google_earth.temporary_files google_toolbar.search_history gpodder.cache gpodder.logs gpodder.vacuum gwenview.recent_documents hexchat.logs hippo_opensim_viewer.cache hippo_opensim_viewer.logs java.cache journald.clean kde.cache kde.recent_documents kde.tmp libreoffice.history liferea.cache liferea.vacuum links2.history midnightcommander.history miro.cache miro.logs nautilus.history nexuiz.cache octave.history openofficeorg.cache openofficeorg.recent_documents opera.cache opera.vacuum palemoon.backup palemoon.cache palemoon.vacuum pidgin.cache pidgin.logs realplayer.history realplayer.logs recoll.index rhythmbox.cache rhythmbox.history screenlets.logs seamonkey.cache seamonkey.chat_logs seamonkey.download_history secondlife_viewer.Cache secondlife_viewer.Logs skype.chat_logs skype.installers slack.cache slack.vacuum sqlite3.history system.cache system.clipboard system.desktop_entry system.localizations system.recent_documents system.rotated_logs system.tmp system.trash thumbnails.cache thunderbird.cache thunderbird.passwords thunderbird.vacuum tremulous.cache vim.history vlc.memory_dump vlc.mru vuze.backup vuze.cache vuze.logs vuze.stats vuze.temp warzone2100.logs waterfox.backup waterfox.cache waterfox.crash_reports waterfox.vacuum wine.tmp winetricks.temporary_files x11.debug_logs xine.cache yum.clean_all yum.vacuum zoom.cache zoom.logs zoom.recordings"
    fi
  fi
}

# =================================================================
# Post-upgrade actions
# =================================================================

function run_postupgrade() {
  if $config_wipe_user_cache; then
    run_command "Post-upgrade" "rm -rf ~/.cache"
  fi

  if $config_wipe_root_cache && ! $config_avoid_sudo; then
    run_command "Post-upgrade" "sudo rm -rf /root/.cache"
  fi
}

# =================================================================
# fstrim
# =================================================================

function run_fstrim() {
  if [ "$config_run_fstrim" = false ]; then
    side_log "fstrim is disabled. Use --run-fstrim to enable it."
  elif $config_avoid_sudo; then
    side_log "fstrim not available because you avoid commands with sudo."
  else
    run_command "fstrim" "sudo fstrim --all --verbose --quiet-unsupported"
  fi
}

# ===========================================

main "$@"