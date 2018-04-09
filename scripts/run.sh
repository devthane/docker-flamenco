#!/usr/bin/env bash

startWorker () {
    screen -d -m -S celery-worker python manage.py celery worker
}

isProvisionedCheck () {
    local response=$(mongo mongo:27017/flamenco --quiet --eval "db.getCollectionNames()")

    if [ "${response}" != "" ]; then
        return 0
    else
        return 1
    fi

}

runserver () {
    local domain=$1

    screen -d -m -S flamenco-server python runserver.py
    until curl -f "${domain}/api"
    do
        sleep 5
    done
}

stopScreens () {
    screen -S flamenco-server -X quit
    screen -S celery-worker -X quit
    exit 0
}

main() {
    source ~/envs/flamenco/bin/activate
    source await_connections.sh
    source provision.sh

    local subscriber_username=$(echo "${SUBSCRIBER_EMAIL}" | sed "s/\(.*\)@.*/\1/")

    addHostsEntry ${SERVER_DOMAIN}
    waitForMongo
    waitForRedis
    waitForRabbit

    local is_provisioned=false

    if ! $(isProvisionedCheck); then
        setupDatabase ${PILLAR_ADMIN_EMAIL}
        createLocalSubscriber ${SUBSCRIBER_EMAIL} ${SUBSCRIBER_PASSWORD}
    else
        is_provisioned=true
        echo "DETECTED PROVISIONED SERVER"
    fi

    startWorker
    trap stopScreens SIGINT SIGTERM
    runserver ${SERVER_DOMAIN}

    #TODO: HANDLE OTHER PORTS
    local url="${SERVER_SCHEME}://${SERVER_DOMAIN}"

    if ! ${is_provisioned}; then
        local token=$(getToken ${subscriber_username} ${SUBSCRIBER_PASSWORD} ${url})
        local project_url=$(createProject ${token} ${PROJECT_NAME} ${url})

        enableFlamenco ${project_url}
        createManager ${SUBSCRIBER_EMAIL} ${MANAGER_NAME} "${MANAGER_DESCRIPTION}"
        # TODO: Link manager to project.
    fi

    while :
    do
        sleep 10
    done
}

main
