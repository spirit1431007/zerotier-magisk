#!/system/bin/sh

MODDIR=${0%/*}

ZTROOT=/data/adb/zerotier
APPROOT=/sdcard/zerotier
ZTLOG=$ZTROOT/run/zerotier.log

rm -f $ZTROOT/run/*

ip rule add from all lookup main pref 1
ip -6 rule add from all lookup main pref 1
export LD_LIBRARY_PATH=/system/lib64:/data/adb/zerotier/lib

$ZTROOT/zerotier-one -d >> $ZTLOG 2>&1 &

# ----------------------------------------------
#             trap and authtoken
# ----------------------------------------------
PIPE_CLI=$ZTRUNTIME/pipe
PIPE_APP=$APPROOT/pipe

cp $ZTROOT/home/authtoken.secret $APPROOT/authtoken
touch $PIPE_CLI $PIPE_APP
chmod 666 $APPROOT/authtoken $PIPE_CLI $PIPE_APP

inotifyd $MODDIR/handle.sh $PIPE_CLI::w   # why toybox inotifyd needs another character before colon?
inotifyd $MODDIR/handle.sh $PIPE_APP::w