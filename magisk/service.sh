#!/system/bin/sh

MODDIR=${0%/*}

ZTROOT=/data/adb/zerotier
APPROOT=/sdcard/zerotier
ZTLOG=$APPROOT/zerotier.log
PIPE=$APPROOT/pipe

rm -f $APPROOT/*

ip rule add from all lookup main pref 1
ip -6 rule add from all lookup main pref 1
export LD_LIBRARY_PATH=/system/lib64:/data/adb/zerotier/lib

$ZTROOT/zerotier-one -d >> $ZTLOG 2>&1 &

# ----------------------------------------------
#             trap and authtoken
# ----------------------------------------------

cp $ZTROOT/home/authtoken.secret $APPROOT/authtoken
touch $PIPE
chmod 666 $APPROOT/authtoken $PIPE

inotifyd $MODDIR/handle.sh $PIPE::w   # why toybox inotifyd needs another character before colon?