description "RedisLive data collection"

start on (net-device-up
          and local-filesystems
          and runlevel [2345])
stop on runlevel [!2345]

respawn
respawn limit 10 5

exec /sbin/start-stop-daemon --start --chuid redislive --chdir {{ dir }} --pidfile /var/run/RedisLive_monitor.pid --make-pidfile --exec {{ python }} -- redis-monitor.py --duration={{ duration }}
