#!/bin/bash
export JVM_ARGS="-Xmn512m -Xms512m -Xmx512m"
tail -f jmeter-server.log &
exec jmeter-server -D "java.rmi.server.hostname=${IP}" -D "client.rmi.localport=${RMI_PORT}" -D "server.rmi.localport=${RMI_PORT}"