#!/bin/bash
#
# atasnap_init.sh - A wrapper around hpguppi_init.sh for running
# hpguppi_daq when using hte ATA SNAP F engines.

# Set high performance mode
for i in `ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`; do echo performance > $i; done

#interface="enp134s0d1"
interface="ens6d1"

# Set mtu
#ifconfig ${interface} mtu 9000

# Kernel buffer sizes
sysctl net.core.rmem_max=1073741824 #1G
sysctl net.core.rmem_default=1073741824 #1G

# Kill packets before the IP stack, applicable to hashpipe_pktsock
iptables -t raw -A PREROUTING -i ${interface} -p udp -j DROP

# Set interrupt coalescing
ethtool -C ${interface} adaptive-rx on
ethtool -C ${interface} rx-frames 8
ethtool -C ${interface} rx-usecs 0

# Set ring sizes to max
ethtool -G ${interface} rx 8192

perf=
if [ "$1" = 'perf' ]
then
  perf=perf
  shift
fi

# echo -n "BINDHOST: "
# read bindhost
# echo -n "BINDPORT: "
# read bindport

# use environment variable instead of HOME/"/tmp" to ensure user-agnostic key is generated by ftok
export HASHPIPE_KEYFILE=/home/sonata 

$(dirname $0)/hpguppi_init.sh $perf atasnap 0 \
	-o BINDHOST=${interface} \
  "${@}"

# sleep 2 

# echo "Starting hashpipe REDIS Gateway"
# # hashpipe_redis_gateway.rb -s ${REDISHOST:-redishost}# -D hashpipe -g `hostname -s` -i 0 -f &
# hashpipe_redis_gateway.rb -s ${REDISHOST:-redishost} -f -i 0 & # -D hashpipe -g `hostname -s` -i 0 -f &
# hashpipe_redis_gateway.rb -s ${REDISHOST:-redishost} -f -i 1 & # -D hashpipe -g `hostname -s` -i 0 -f &
