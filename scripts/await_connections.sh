#!/usr/bin/env bash

waitForMongo () {
    until mongo mongo:27017/flamenco --eval "print(\"waited for connection\")"
    do
        sleep 5
    done
}

waitForRedis () {
    until redis-cli -h redis ping
    do
        sleep 5
    done
}

waitForRabbit() {
    until nc rabbit 5672
    do
        sleep 5
    done
}
