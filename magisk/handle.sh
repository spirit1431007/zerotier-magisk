#!/system/bin/sh

MODDIR=${0%/*}

ZTROOT=/data/adb/zerotier
ZTRUNTIME=$ZTROOT/run
APPROOT=/sdcard/Android/zerotier

ZTLOG=$ZTRUNTIME/zerotier.log
daemon_log=$ZTRUNTIME/daemon.log

log_cli() {
  echo -e "$1" >> $CWD/cli.out
}
log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $1" >> $daemon_log
  log_cli $1
}
_stop() {
  pid=`pidof zerotier-one`
  if [[ $? -ne 0 ]]; then
    log "zerotier-one not running"
    return
  fi

  kill -9 $pid
  if [[ $? -ne 0 ]]; then
    log "kill zerotier-one failed"
    return
  fi

  wait
  sleep 1 # sometimes it fails without sleeping

  log "stopped zerotier-one"
}
_start() {
  if pid=`pidof zerotier-one`; then
    log "zerotier-one already running pid $pid"
  else
    $ZTROOT/zerotier-one -d >> $ZTLOG 2>&1 &
    pid=`pidof zerotier-one`
    log "started zerotier-one pid $pid"
  fi
}
_status() {
  # fake systemd lol
  if pid=`pidof zerotier-one`; then
    log_cli "\033[32m●\033[0m zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: \033[32mactive (running)\033[0m"
    log_cli "   Main PID: $pid (zerotier-one)"
  else
    read pid_ < $ZTROOT/home/zerotier-one.pid
    log_cli "○ zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: inactive (dead)"
    log_cli "   Main PID: $pid_ (code=exited)"
  fi
}

# ----------------------------------------------
#             trap for inotifyd
# ----------------------------------------------

if [[ $# == 2 && "$1" == "w" ]]; then
  read cmd < $2

  CWD=`dirname $2`

  case "$cmd" in
    "start") _start;;
    "stop") _stop;;
    "restart") _stop; _start;;
    "status") _status;;
    *) log "unknown command $cmd";;
  esac

  read cpid < $CWD/cli.pid
  kill -SIGUSR1 $cpid

  exit 0
fi