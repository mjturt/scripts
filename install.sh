#!/usr/bin/env bash
#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃░░░░ ┓━┓┏━┓┳━┓o┳━┓┏┓┓┓━┓ ░░░░┃
#┃░░░░ ┗━┓┃  ┃┳┛┃┃━┛ ┃ ┗━┓ ░░░░┃
#┃░░░░ ━━┛┗━┛┇┗┛┇┇   ┇ ━━┛ ░░░░┃
#┠━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┃░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃
#┃░░ Install script for my   ░░┃
#┃░░ scripts.                ░░┃
#┃░░ ./install.sh            ░░┃
#┃░░ ./install.sh --help     ░░┃
#┃░░░░░░░░░░░░░░░░░░░░░░░░░░░░░┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

#┏━━━━━━━━━━━┓
#┃ Variables ┃
#┗━━━━━━━━━━━┛

BACKUPROOT=~/.scripts-backup
BACKUP=${BACKUPROOT}/scripts-backup-$(date +%H%M%S)
LOGS=${BACKUP}/scripts-logs-$(date +%H%M%S).log
SH_PATH=${HOME}/sh
STATUS_PATH=${HOME}/.statusscripts
BIN_PATH=${HOME}/bin
ASSETS_PATH=${HOME}/.assets
SCRIPTS=$(pwd)

#┏━━━━━━━━━━━┓
#┃ Functions ┃
#┗━━━━━━━━━━━┛

isFunction() { [[ "$(declare -Ff "$1")" ]]; }

animate() {
    echo -ne "     $1\\033[0K\\r"
    sleep "$2"
}

installScripts() {
    installSh
    installStatus
    installBin
    installAssets
}

installSh() {
    if [[ -e "$SH_PATH" ]]; then
        mv -v "$SH_PATH" "$BACKUP" >> "$LOGS"
    elif [[ -L "$SH_PATH" ]]; then
        rm -v "$SH_PATH" >> "$LOGS"
    fi
    ln -v -s "${SCRIPTS}"/sh "$SH_PATH" >> "$LOGS"
}

installStatus() {
    if [[ -e "$STATUS_PATH" ]]; then
        mv -v "$STATUS_PATH" "$BACKUP" >> "$LOGS"
    elif [[ -L "$STATUS_PATH" ]]; then
        rm -v "$STATUS_PATH" >> "$LOGS"
    fi
    ln -v -s "${SCRIPTS}"/statusscripts "$STATUS_PATH" >> "$LOGS"
}

installBin() {
    if [[ -e "$BIN_PATH" ]]; then
        mv -v "$BIN_PATH" "$BACKUP" >> "$LOGS"
    elif [[ -L "$BIN_PATH" ]]; then
        rm -v "$BIN_PATH" >> "$LOGS"
    fi
    ln -v -s "${SCRIPTS}"/bin "$BIN_PATH" >> "$LOGS"
}

installAssets() {
    if [[ -e "$ASSETS_PATH" ]]; then
        mv -v "$ASSETS_PATH" "$BACKUP" >> "$LOGS"
    elif [[ -L "$ASSETS_PATH" ]]; then
        rm -v "$ASSETS_PATH" >> "$LOGS"
    fi
    ln -v -s "${SCRIPTS}"/assets "$ASSETS_PATH" >> "$LOGS"
}

helps() {
    echo -e "\\e[0;34mＨｅｌｐ ━━━━━━━━━━━━━━━━"
    echo -e "\\e[1;36mScript symlinks $SH_PATH to ~/sh, $STATUS_PATH to ~/.statusscripts and $BIN_PATH to ~/bin"
    echo -e "\\e[1;36mIf these paths has something, they are backed up to $BACKUPROOT"
}

loader() {
    animate '  \e[0;35m░░░░░░░░░ ' 0.1
    animate '  \e[0;35m▓░░░░░░░░ ' 0.1
    animate '  \e[0;35m▓▓░░░░░░░ ' 0.1
    animate '  \e[0;35m▓▓▓░░░░░░ ' 0.1
    animate '  \e[0;35m▓▓▓▓░░░░░ ' 0.1
    animate '  \e[0;35m▓▓▓▓▓░░░░ ' 0.1
    animate '  \e[0;35m▓▓▓▓▓▓░░░ ' 0.1
    animate '  \e[0;35m▓▓▓▓▓▓▓░░ ' 0.1
    animate '  \e[0;35m▓▓▓▓▓▓▓▓░ ' 0.1
    animate '  \e[0;35m▓▓▓▓▓▓▓▓▓ ' 0.1
    animate '\e[1;31m' 0.1
}

echoDone() {
    echo -e "\\e[1;32m┳━┓┏━┓┏┓┓┳━┓\\e[0m"
    echo -e "\\e[1;32m┃ ┃┃ ┃┃┃┃┣━\\e[0m"
    echo -e "\\e[1;32m┇━┛┛━┛┇┗┛┻━┛\\e[0m"
}

echoError() {
    echo -e "\\e[1;31m┳━┓┳━┓┳━┓┏━┓┳━┓\\e[0m"
    echo -e "\\e[1;31m┣━ ┃┳┛┃┳┛┃ ┃┃┳┛\\e[0m"
    echo -e "\\e[1;31m┻━┛┇┗┛┇┗┛┛━┛┇┗┛\\e[0m"
}

initAnimation() {
    sleep 0.1
    animate "\\e[1;35mＳ\\e[0m" 0.1
    animate "\\e[1;35mＳＣ\\e[0m" 0.1
    animate "\\e[1;35mＳＣＲ\\e[0m" 0.1
    animate "\\e[1;35mＳＣＲＩ\\e[0m" 0.1
    animate "\\e[1;35mＳＣＲＩＰ\\e[0m" 0.1
    animate "\\e[1;35mＳＣＲＩＰＴ\\e[0m" 0.1
    animate "\\e[1;35mＳＣＲＩＰＴＳ\\e[0m" 0.1
    echo
}

#┏━━━━━━━┓
#┃ Start ┃
#┗━━━━━━━┛

initAnimation

if [[ $# -gt 0 ]]; then
    helps
    exit 0
else
    printf "Are you sure you want to install scripts (y/n) "
    read -r SURE
    case $SURE in
        [yY]) echo ;;
        *) exit 0 ;;
    esac
    loader

    if [[ ! -e "$BACKUPROOT" ]]; then
        mkdir -p -v "$BACKUPROOT"
    fi
    mkdir -p "$BACKUP"

    if installScripts; then
        echoDone
        echo -e "Logs can be found at \\e[1;35m${LOGS}\\e[0m"
        printf "Want to see logs now? (y/n) "
        read -r LOGANS
        case $LOGANS in
            [yY]) less "$LOGS" ;;
            *) exit 0 ;;
        esac
    else
        echoError
        echo -e "Something went wrong during installation."
        echo -e "Backup of old files can be found at \\e[1;35m${BACKUP}\\e[0m"
        echo -e "Logs can be found at \\e[1;35m${LOGS}\\e[0m"
        printf "Want to see logs now? (y/n) "
        read -r LOGANS
        case $LOGANS in
            [yY]) less "$LOGS" ;;
            *) exit 1 ;;
        esac
    fi
fi
