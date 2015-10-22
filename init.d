#! /bin/sh

### BEGIN INIT INFO
# Provides:            igmpproxy
# Required-Start:      $network $remote_fs $local_fs
# Required-Stop:      $network $remote_fs $local_fs
# Default-Start:      2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:   Stop/start igmpproxy
### END INIT INFO

PATH=/sbin:/usr/local/sbin:/bin:/usr/local/bin
DESC=IGMPProxy
NAME=igmpproxy
CONFFILE=/usr/local/etc/igmpproxy.conf
DAEMON=/usr/local/sbin/$NAME
DAEMON_ARGS="$CONFFILE"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

[ -x "$DAEMON" ] || exit 0

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

. /lib/init/vars.sh

. /lib/lsb/init-functions

do_start()
{
   start-stop-daemon --start --quiet --background --pidfile $PIDFILE --exec $DAEMON -- \
        $DAEMON_ARGS
    RETVAL="$?"
    return "$RETVAL"
}

do_stop()
{
   start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
    RETVAL="$?"
    rm -f $PIDFILE
    return "$RETVAL"
}

do_reload() {
    start-stop-daemon --stop --signal HUP --quiet --pidfile $PIDFILE --name $NAME
    RETVAL="$?"
    return "$RETVAL"
}

case "$1" in
   start)
      
      [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC " "$NAME"
      do_start
      case "$?" in
         0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
         2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
      esac
      ;;
    stop)
      
      [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
      do_stop
      case "$?" in
         0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
         2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
      esac
      ;;
   status)
      status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
      ;;
   restart)
      log_daemon_msg "Restarting $DESC" "$NAME"
      do_stop
      case "$?" in
         0|1)
            do_start
            case "$?" in
               0) log_end_msg 0 ;;
               1) log_end_msg 1 ;; # Old process is still running
               *) log_end_msg 1 ;; # Failed to start
            esac
            ;;
         *)
            # Failed to stop
            log_end_msg 1
            ;;
      esac
      ;;
   *)
      echo "Usage: $SCRIPTNAME {start|stop|status|restart}" $
      exit 3
      ;;
esac

exit $RETVAL
