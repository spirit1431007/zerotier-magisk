#!/system/bin/sh
PIPE=/sdcard/zerotier/pipe

cli_output=/sdcard/zerotier/cli.out
cli_pid=/sdcard/zerotier/cli.pid

help_text="Usage: zerotier.sh {start|stop|restart|status}"

if [[ ! -f $PIPE ]]; then
    echo "daemon not running"
    exit 1
fi

echo $$ > $cli_pid

on_receive() {
  kill -9 %%
  cat $cli_output
  exit 0
}
run() {
  echo $cmd > $PIPE
}

trap 'on_receive' SIGUSR1
cmd=$1

if [[ $# -eq 1 ]]; then
  case "$cmd" in
    "start") run;;
    "stop") run;;
    "restart") run;;
    "status") run;;
    *) echo "unknown command $cmd";;
  esac
else
  echo $help_text
  exit 1
fi

sleep 20 &
wait

echo "20 seconds time out"
exit 1