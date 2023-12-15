#!/bin/sh
#
# muonato/check_dcont.sh @ GitHub (15-DEC-2023)
#
# Reports container statistics using docker stat,
# compatible with Nagios monitoring as host plugin
#
# Usage:
#       bash check_dcont.sh <container-name> [<container-name>] ...
#
#       Nagios nrpe configuration on host :
#       command[check_dcont]=sudo /path/to/plugins/check_dcont.sh $ARG1$
#
# Parameters:
#       1..n: docker container name
#
# Examples:
#       $ bash check_dcont.sh fubar-one
#       (Check single docker container)
#
#       check_nrpe -H $HOSTADDRESS$ -t 300 -c check_dcont -a 'fubar-one fubar-two'
#       (Nagios monitor expression for two containers, allow for long timeout)
#
#       opsview ALL=NOPASSWD:/path/to/plugins/check_dcont
#       (Configure user group 'opsview' for sudo permissions in /etc/sudoers)
#
# Platform:
#       Red Hat Enterprise Linux 8.9 (Ootpa)
#       Docker version 24.0.7
#       Opsview Core 3.20140409.0
#
function container_stat () {
    # Container path as fn parameter
    CONT=$1

    # Get docker container memory stats
    CMEM=$(docker stats --format "{{.MemPerc}}" --no-stream $CONT 2>/dev/null)

    # Strip percentage
    CMEM=${CMEM%"%"}

    # Get docker container CPU stats
    CCPU=$(docker stats --format "{{.CPUPerc}}" --no-stream $CONT 2>/dev/null)

    # Strip percentage
    CCPU=${CCPU%"%"}

    # Status message as function output
    if [[ -z "$CMEM" || -z "$CCPU" ]]; then
        echo "CRITICAL - Docker container '$CONT' statistics failed"
    elif [[ ${CMEM%.*} -ge 90 || ${CCPU%.*} -ge 90 ]]; then
        echo "CRITICAL - Docker container '$CONT' CPU: $CCPU% MEM: $CMEM%"
    elif [[ ${CMEM%.*} -ge 70 || ${CCPU%.*} -ge 70 ]]; then
        echo "WARNING - Docker container '$CONT' CPU: $CCPU% MEM: $CMEM%"
    elif [[ ${CMEM%.*} -ge 0 || ${CCPU%.*} -ge 0 ]]; then
        echo "OK - Docker container '$CONT' CPU: $CCPU% MEM: $CMEM%"
    else
        echo "UNKNOWN - Docker container '$CONT'"
    fi
}

# BEGIN __main__
umask 0077

if [[ -z "$1" ]]; then
    echo -e "check docker container statistics\n\tUsage:\
    `basename $0` <container-name> [<container-name>] ...\n
    \tERROR: missing container name"
    exit 3
else
     CSTAT=""
fi

# Loop args to append message
for (( i=1; i<=$#; i++ )); do
    CSTAT="${CSTAT}${i}: $(container_stat ${@:i:1})\n"
done

# Message excl. line feed
echo -e ${CSTAT%??}

# Apply exit code corresponding to status message
if [[ -n $(echo -e $CSTAT|grep -om 1 "CRITICAL") ]]; then
    exit 2
elif [[ -n $(echo -e $CSTAT|grep -om 1 "WARNING") ]]; then
    exit 1
elif [[ -n $(echo -e $CSTAT|grep -om 1 "UNKNOWN") ]]; then
    exit 3
else
    exit 0
fi
