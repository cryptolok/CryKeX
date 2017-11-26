#!/usr/bin/env bash

#$ apt install gdb aeskeyfind rsakeyfind

echo -e "\033[01;33m"
echo '
 ######  ########  ##    ## ##    ## ######## ##     ## 
##    ## ##     ##  ##  ##  ##   ##  ##        ##   ##  
##       ##     ##   ####   ##  ##   ##         ## ##   
##       ########     ##    #####    ######      ###    
##       ##   ##      ##    ##  ##   ##         ## ##   
##    ## ##    ##     ##    ##   ##  ##        ##   ##  
 ######  ##     ##    ##    ##    ## ######## ##     ##

 ad8888888888ba
dP'"'"'         `"8b,
8  ,aaa,       "Y888a     ,aaaa,     ,aaa,  ,aa,
8  8'"'"' `8           "8baaaad""""baaaad""""baad""8b
8  8   8              """"      """"      ""    8b
8  8, ,8         ,aaaaaaaaaaaaaaaaaaaaaaaaddddd88P
8  `"""'"'"'       ,d8""
Yb,         ,ad8"                    
 "Y8888888888P"
'
echo '    Linux Memory Cryptographic Keys Extractor
'
echo -e "\e[0m"

PROCESS=$1

if [[ ! "$PROCESS" ]]
then
	echo 'Usage : CryKeX PROCESS/BINARY'
	echo 'Example : CryKeX openssl'
	echo 'Example : CryKeX cipher'
	exit 1
fi

PID=$(pidof $PROCESS)
if [[ ! "$PID" ]]
then
	PROCESS=${PROCESS,,}
	PID=$(pidof $PROCESS)
fi
if [[ ! "$PID" ]]
then
	echo '!!! PROCESS NOT FOUND !!!'
	echo 'Enter the Process ID (PID) manually or "wrap" to wrap process and inject after execution or blank to exit :'
	read PID
fi
if [[ ! "$PID" ]]
then
	exit 2
fi

INJECTED=0
if [[ "$PID" == "wrap" ]]
then
	echo 'Enter the binary path/name :'
	read PROCESS
	if [[ "$PROCESS" != *"/"* ]]
	then
		PROCESS=./$PROCESS
	fi
	echo 'Enter the delay in seconds after execution for injection (blank for 0.0003)'
	read DELAY
	if [[ ! "$DELAY" ]]
	then
		DELAY=0.0003
	fi
	echo 'WRAPPING PROCESS ...'
	($PROCESS) & sleep $DELAY && kill -STOP $! &>/dev/null
	if [[ $? -ne 0 ]]
	then
		for i in {1..250}
		do
			($PROCESS) & sleep $DELAY && kill -STOP $! &>/dev/null
			if [[ $? -eq 0 ]]
			then
				break
			fi
		done
	fi
	PID=$(pidof $PROCESS)
	if [[ ! "$PID" ]]
	then
	        echo '!!! INJECTION FAILED !!!'
		echo 'Retry or change delay'
		exit 3
	fi
	INJECTED=1
fi

echo 'DUMPING MEMORY ...
'
cd /tmp
gcore $PID &> /dev/null
if [[ $? -ne 0 ]]
then
	echo '!!! DUMP FAILED !!!'
	echo 'Ensure that you have enough privileges for the process or run as root'
	exit 4
fi
if [[ $INJECTED -eq 1 ]]
then
	kill -CONT $PID &>/dev/null
fi

echo 'SEARCHING KEYS ...
'
for dump in $(ls core.*)
do
#	ALGO=$(strings $dump | grep -i 'rsa-' | tail -n 1 | rev | cut -d ',' -f 1 | rev | cut -d '.' -f 1 | cut -d '@' -f 1)
	ALGO=$(strings $dump | grep -i -o 'rsa-...' | tail -n 1)
	if [[ "$ALGO" ]]
	then
		echo "*** ${ALGO^^} ***"
	else
		echo '*** POTENTIAL RSA ***'
	fi
	rsakeyfind $dump
#	ALGO=$(strings $dump | grep -i 'aes[-,_,1-5]' | tail -n 2 | head -n 1 | rev | cut -d ',' -f 1 | rev | cut -d '.' -f 1 | cut -d '@' -f 1 | cut -d ':' -f 5)
	ALGO=$(strings $dump | grep -i -o 'aes[-,_,1-5].......' | tail -n 2 | head -n 1)
	if [[ "$ALGO" ]]
	then
		echo "*** ${ALGO^^} ***"
	else
		echo '*** POTENTIAL AES ***'
	fi
	aeskeyfind $dump
	rm $dump
done

