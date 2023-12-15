# check_dcont
Nagios monitoring compatible docker container statistics

## Usage
```
check_dcont.sh <container-name> [<container-name>] ...
```

## Nagios monitoring setup
Specify command in your nrpe configuration file on host

```
command[check_dcont]=sudo /path/to/plugins/check_dcont.sh $ARG1$
```
Specify sudo right to Opsview user group ( where applicable )

```
opsview ALL=NOPASSWD:/path/to/plugins/check_dcont
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
$ ./check_dcont.sh fubar-one fubar-two
1: OK - Docker container 'fubar-one' CPU: 0.12% MEM: 0.41%
2: WARNING - Docker container 'fubar-two' CPU: 0.05% MEM: 62.8%
```
Check non-existent container

```
$ ./check_dcont.sh foo-bar
1: CRITICAL - Docker container 'foo-bar' statistics failed
```
## Platform
Script development and testing

```
Red Hat Enterprise Linux 8.9 (Ootpa)
Docker version 24.0.7
Opsview Core 3.20140409.0

```
