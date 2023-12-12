# check_dcont
Nagios monitoring compatible docker container statistics

## Usage
```
check_dcont.sh <container-name> [<container-name>] ...
```

## Nagios monitoring setup
Specify command in your nrpe configuration file on host

```
command[check_dcont]=/path/to/plugins/check_dcont.sh $ARG1$
```

Set command on your nagios monitoring server

```
check_nrpe -H $HOSTADDRESS$ -c check_dcont -a '<container-name>'
```

## Examples
Check container statistics

```
$ ./check_dcont.sh foo-bar
1: CRITICAL - Docker container 'foo-bar' CPU: 89.5% MEM: 40.4%
```

Check statistics of two containers

```
$ ./check_dcont.sh foo-bar fubar
1: OK - Docker container 'foo-bar' CPU: 0.12% MEM: 0.41%
2: WARNING - Docker container 'fubar' CPU: 0.05% MEM: 62.8%
```
Check non-existent container

```
$ ./check_dcont.sh dokker
1: UNKNOWN - Docker container 'dokker'
```
