#!/usr/bin/env bash
#
# muonato/check_dcont.sh @ GitHub (12-DEC-2023)
#
# Reports container statistics using docker stat,
# compatible with Nagios monitoring as host plugin
#
# Usage:
#       bash check_dcont.sh <container-name> [<container-name>] ...
#
#       Nagios nrpe configuration on host :
#       command[check_dcont]=/path/to/plugins/check_dcont.sh $ARG1$
#
# Parameters:
#       1..n: docker container name
#
# Examples:
#       $ bash check_dcont.sh container-psql
#       (check single docker container)
#
#       check_nrpe -H $HOSTADDRESS$ -c check_dcont -a 'fubar-one fubar-two'
#       (nagios monitor line for two containers)
#
function container_stat () {
    # Assign fn arguments
    CONT=$1

    # Get docker container memory stats
    CMEM=$(sudo docker stats --format "{{.MemPerc}}" --no-stream $CONT 2>/dev/null)

    # Strip percentage
    CMEM=${CMEM%"%"}

    # Get docker container CPU stats
    CCPU=$(sudo docker stats --format "{{.CPUPerc}}" --no-stream $CONT 2>/dev/null)

    # Strip percentage
    CCPU=${CCPU%"%"}

    if [[ -z "$CMEM" || -z "$CCPU" ]]; then
        echo "CRITICAL - Docker container '$CONT' statistics failed"
    elif [[ ${CMEM%.*} -ge 90 || ${CCPU%.*} -ge 90 ]]; then
        echo "CRITICAL - Docker container '$CONT' CPU: $CCPU MEM: $CMEM"
    elif [[ ${CMEM%.*} -ge 70 || ${CCPU%.*} -ge 70 ]]; then
        echo "WARNING - Docker container '$CONT' CPU: $CCPU MEM: $CMEM"
    elif [[ ${CMEM%.*} -ge 0 || ${CCPU%.*} -ge 0 ]]; then
        echo "OK - Docker container '$CONT' CPU: $CCPU MEM: $CMEM"
    else
            echo "UNKNOWN - Docker container '$CONT'"
    fi
}

# BEGIN __main__
if [[ -z "$1" ]]; then
    echo -e "check docker container statistics\n\tUsage:\
    `basename $0` <container-name> [<container-name>...<container-name>]\n
    \tmissing container name
            "
    exit 3
else
     CSTAT=""
fi

# Loop thru args to get status
for (( i=1; i<=$#; i++ )); do
    CSTAT="${CSTAT}${i}: $(container_stat ${@:i:1})\n"
done

# Status excl. line feed
echo -e ${CSTAT%??}

# Apply exit code corresponding to container stat message
if [[ -n $(echo -e $CSTAT|grep -om 1 "UNKNOWN") ]]; then
    exit 3
elif [[ -n $(echo -e $CSTAT|grep -om 1 "CRITICAL") ]]; then
    exit 2
elif [[ -n $(echo -e $CSTAT|grep -om 1 "WARNING") ]]; then
    exit 1
else
    exit 0
fi
