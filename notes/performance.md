# Performance

### Changing I/O scheduler

`sudo touch /etc/udev/rules.d/60-ioschedulers.rules`

```
sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null << EOF
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

# SSD
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

# NVMe SSD
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
EOF
```

### Profile-sync-daemon

> https://wiki.archlinux.org/title/Profile-sync-daemon

### Improving build times

`sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j16"/g' /etc/makepkg.conf`

`sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 16 -z -)/g' /etc/makepkg.conf`

### Disable watchdogs

`sudo touch /etc/modprobe.d/disable-sp5100-watchdog.conf`
`echo blacklist sp5100_tco > /etc/modprobe.d/disable-sp5100-watchdog.conf`

# Networking Performance

```
# Increasing the size of the receive queue.
net.core.netdev_max_backlog = 16384

# Increase the maximum connections
net.core.somaxconn = 8192

# Increase the memory dedicated to the network interfaces
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Tweak the pending connection handling
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0

# Change TCP keepalive parameters
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# Enable MTU probing
net.ipv4.tcp_mtu_probing = 1

# TCP timestamps
net.ipv4.tcp_timestamps = 0

# TCP Selective Acknowledgement  
net.ipv4.tcp_sack = 1

# Enable BBR
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

# Increase the Ephemeral port range
net.ipv4.ip_local_port_range = 30000 65535

# TCP/IP stack hardening
net.ipv4.tcp_syncookies = 1

# TCP rfc1337
net.ipv4.tcp_rfc1337 = 1

# Reverse path filtering
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

# Increase the maximum amount of memory that can be allocated
vm.max_map_count = 262144

# Allow for more efficient swapping
vm.swappiness = 10

# Increase the amount of memory used for inodes and dentries cache
vm.vfs_cache_pressure = 50

# Improve read and write operations for storage
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
```