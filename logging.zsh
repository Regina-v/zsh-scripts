#!/bin/zsh

# Modified from https://github.com/jeliasson/zsh-logging/blob/main/includes/logging.sh

# Script log
TIMESTAMP=$(date +%F_%H-%M-%S)
SCRIPT_LOG_PATH="$HOME/logs"
SCRIPT_LOG_FILE="${TIMESTAMP}.log"

# Scripts log
SCRIPT_LOG=${SCRIPT_LOG_PATH}/${SCRIPT_LOG_FILE}

# Make directory and log file
mkdir -p "${SCRIPT_LOG_PATH}"
touch ${SCRIPT_LOG_PATH}/${SCRIPT_LOG_FILE}

# Colors
GREY='\033[1;30;40'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'

function SCRIPTENTRY() {
   SCRIPT_NAME=$(basename "$0")
   echo -e "${GREY}[$(date)]${NOCOLOR} ${PURPLE}[DEBUG]${NOCOLOR} ${GREY}> $SCRIPT_NAME ${NOCOLOR}" | tee -a "$SCRIPT_LOG"
}
export SCRIPTENTRY

function SCRIPTEXIT() {
   SCRIPT_NAME=$(basename "$0")
   echo -e "${GREY}[$(date)]${NOCOLOR} ${PURPLE}[DEBUG]${NOCOLOR} ${GREY}< $SCRIPT_NAME ${NOCOLOR}" | tee -a "$SCRIPT_LOG"
}
export SCRIPTEXIT

function ENTRY() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${PURPLE}[DEBUG]${NOCOLOR} ${GREY}> $msg${NOCOLOR}" | tee -a "$SCRIPT_LOG"
}
export ENTRY

function EXIT() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${PURPLE}[DEBUG]${NOCOLOR} ${GREY}< $msg${NOCOLOR}" | tee -a "$SCRIPT_LOG"
}
export EXIT

function INFO() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${BLUE}[INFO]${NOCOLOR}    $msg" | tee -a "$SCRIPT_LOG"
}
export INFO

function SUCCESS() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${GREEN}[SUCCESS]${NOCOLOR} $msg" | tee -a "$SCRIPT_LOG"
}
export SUCCESS

function WARN() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${YELLOW}[WARN]${NOCOLOR}    $msg" | tee -a "$SCRIPT_LOG"
}
export WARN

function DEBUG() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${PURPLE}[DEBUG]${NOCOLOR}   $msg" | tee -a "$SCRIPT_LOG"
}
export DEBUG

function ERROR() {
   local msg="$1"
   echo -e "${GREY}[$(date)]${NOCOLOR} ${RED}[ERROR]${NOCOLOR}   $msg" | tee -a "$SCRIPT_LOG"
}
export ERROR

function PROGRESS {
   if [ -z "$1" ] || [ -z "$2" ]; then
      echo -e "${GREY}[$(date)]${NOCOLOR} ${RED}[ERROR]${NOCOLOR} Both arguments must be provided" | tee -a "$SCRIPT_LOG"
      return
   fi
   if ! [[ "$1" =~ ^[0-9]+$ ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
      echo -e "${GREY}[$(date)]${NOCOLOR} ${RED}[ERROR]${NOCOLOR} Both arguments must be numbers" | tee -a "$SCRIPT_LOG"
      return
   fi
   if [ $2 -eq 0 ]; then
      echo -e "${GREY}[$(date)]${NOCOLOR} ${RED}[ERROR]${NOCOLOR} Total (second argument) cannot be zero" | tee -a "$SCRIPT_LOG"
      return
   fi
   let _progress=(${1} * 100 / ${2})
   let _done=(${_progress} * 4)/10
   let _left=40-$_done
   _fill=$(printf "%${_done}s")
   _empty=$(printf "%${_left}s")
   echo -e "${GREY}[$(date)]${NOCOLOR} ${CYAN}[PROGRESS]${NOCOLOR} [${_fill// /▇}${_empty// /-}] ${_progress}%" | tee -a "$SCRIPT_LOG"
}
export PROGRESS
