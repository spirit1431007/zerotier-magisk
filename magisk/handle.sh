#!/system/bin/sh

# LD_LIBRARY_PATH for NDK
export LD_LIBRARY_PATH=/system/lib64:/data/adb/zerotier/lib

ZTROOT=/data/adb/zerotier
APPROOT=/sdcard/zerotier

ZTLOG=$APPROOT/zerotier.log
daemon_log=$APPROOT/daemon.log

log_cli() {
  echo -e "$1" >> $APPROOT/cli.out
}
log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $@" >> $daemon_log
  log_cli "$@"
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
  rm -f $APPROOT/cli.out

  case "$cmd" in
    "start") _start;;
    "stop") _stop;;
    "restart") _stop; _start;;
    "status") _status;;
    *) log "unknown command $cmd";;
  esac

  if [[ -f "$APPROOT/cli.pid" ]]; then
    read cpid < $APPROOT/cli.pid
    rm -f $APPROOT/cli.pid
    kill -SIGUSR1 $cpid
  fi

  exit 0
fi