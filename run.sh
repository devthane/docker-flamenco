#!/usr/bin/env bash

addHostsEntry() {
    echo "127.0.0.1 flamenco.app" >> /etc/hosts
}

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

setupDatabase () {
    python manage.py setup setup_db ${PILLAR_ADMIN_EMAIL}
}

createLocalSubscriber() {
    python manage.py setup create_local_user_account ${SUBSCRIBER_EMAIL} ${SUBSCRIBER_PASSWORD}
    python manage.py setup badger grant ${SUBSCRIBER_EMAIL} subscriber
}

startWorker () {
    screen -d -m -S celery-worker python manage.py celery worker
}

runserver () {
    screen -d -m -S flamenco-server python runserver.py
    until curl -f "${SERVER_DOMAIN}/api"
    do
        sleep 5
    done
}

getToken () {
    response=$(curl -X POST -F "username=${SUBSCRIBER_USERNAME}" -F "password=${SUBSCRIBER_PASSWORD}" http://${SERVER_DOMAIN}/api/auth/make-token)
    token=$(echo ${response} | python -c "import sys, json; print(json.load(sys.stdin)['token'])")
    echo ${token}
}

stopScreens () {
    screen -S flamenco-server -X quit
    screen -S celery-worker -X quit
    exit 0
}

createProject () {
    response=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -d "{\"name\":\"${PROJECT_NAME}\"}" http://${SERVER_DOMAIN}/api/p/create)
    url=$(echo ${response} | python -c "import sys, json; print(json.load(sys.stdin)['url'])")
    echo ${url}
}

enableFlamenco () {
    python manage.py flamenco setup_for_flamenco ${PROJECT_URL}
}

createManager () {
    python manage.py flamenco create_manager ${SUBSCRIBER_EMAIL} ${MANAGER_NAME} "${MANAGER_DESCRIPTION}" > /tmp/output/manager-info.txt
}

source ~/envs/flamenco/bin/activate

SUBSCRIBER_USERNAME=$(echo "${SUBSCRIBER_EMAIL}" | sed "s/\(.*\)@.*/\1/")

addHostsEntry

waitForMongo
waitForRedis
waitForRabbit

setupDatabase

createLocalSubscriber
startWorker
trap stopScreens SIGINT SIGTERM
runserver

TOKEN=$(getToken)
PROJECT_URL=$(createProject)

enableFlamenco
createManager

while :
do
    sleep 10
done
