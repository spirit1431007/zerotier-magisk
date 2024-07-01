#!/system/bin/sh

MODDIR=${0%/*}

ZTROOT=/data/adb/zerotier
APPROOT=/data/user/0/com.eventlowop.zerotier_magisk_app/app_flutter
authtoken=$ZTROOT/home/authtoken.secret
daemon_log=$ZTROOT/run/daemon.log
pipe=$ZTROOT/run/pipe

log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $1" >> $daemon_log
}

if [[ -e $APPROOT ]]; then
  log "found controller app"

  ln -sf $pipe        $APPROOT/pipe
  ln -sf $authtoken   $APPROOT/authtoken
else
  log "controller app not found"
fi