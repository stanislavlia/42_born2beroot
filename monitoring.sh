# Preparing formatted outputs to print

ARCHITECTURE=$(uname -a)
N_PHYSICAL_CPU=$(grep 'physical id' /proc/cpuinfo | wc -l)
N_VIRTUAL_CPU=$(grep 'processor' /proc/cpuinfo | wc -l)

AV_RAM=$(grep 'MemAvailable' /proc/meminfo | awk '{printf $2}')
TOTAL_RAM=$(grep 'MemTotal'  /proc/meminfo | awk '{printf $2}')
AV_RAM=$(( AV_RAM / 1024)) #Transform to MB
TOTAL_RAM=$(( TOTAL_RAM / 1024)) #Transform to MB
MEM_USAGE=$( echo "scale=2;  100 * ($TOTAL_RAM - $AV_RAM) / ($TOTAL_RAM)" | bc)


TOTAL_DISK=$(df / | awk 'NR>1 {print $2}')
USED_DISK=$(df / | awk 'NR>1 {print $3}')
DISK_RATE=$(df / | awk 'NR>1 {print $5}')
TOTAL_DISK=$( echo "scale=2; ($TOTAL_DISK / 1024) / 1024" | bc)
USED_DISK=$( echo "scale=2; ($USED_DISK / 1024) / 1024" | bc )

CPU_LOAD=$(top -bn1 | grep 'Cpu' | cut -c -11 | xargs | awk '{printf("%.1f%%"), $1 + $3}')
LAST_REBOOT=$(last reboot -F | awk 'NR==1 {print $9, $6, $7, $8}')

lvm_ments=$(lsblk | grep 'lvm' | wc -l)

LVMU=$(if [ $lvm_ments -eq 0 ]; then echo no; else echo yes; fi)
USER_LOGGED=$(who | wc -l)
TCP_CONS=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')


IP4_ADR=$(ip addr show | awk '/inet / {print $2}' | tail -n 1)
MAC_ADR=$(ip addr show | awk '/ether/ {print $2}')
SUDO_CMDS=$(cat /var/log/sudo/sudo.log | grep "USER" | wc -l)

# Writes message for all users
wall  " 	#Architecture: $ARCHITECTURE
	#CPU physical: $N_PHYSICAL_CPU
	#vCPU: $N_VIRTUAL_CPU
	#Memory Usage: $((TOTAL_RAM - AV_RAM))/$TOTAL_RAM MB ($MEM_USAGE%)
	#Disk Usage: $USED_DISK/$TOTAL_DISK GB ($DISK_RATE)
	#CPU load: $CPU_LOAD
	#Last boot: $LAST_REBOOT
	#LVM use: $LVMU
	#Connections TCP: $TCP_CONS ESTABLISHED
	#User log: $USER_LOGGED
	#Network: IP $IP4_ADR ($MAC_ADR)
	#Sudo: $SUDO_CMDS cmd
	"
