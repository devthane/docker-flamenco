#!/usr/bin/env bash

addHostsEntry() {
    local domain=$1

    echo "127.0.0.1 ${domain}" >> /etc/hosts
}

setupDatabase () {
    local email=$1

    python manage.py setup setup_db ${email}
}


createLocalSubscriber() {
    local email=$1
    local password=$2

    python manage.py setup create_local_user_account ${email} ${password}
    python manage.py setup badger grant ${email} subscriber
}

getToken () {
    local username=$1
    local password=$2
    local url=$3

    response=$(curl -X POST -F "username=${username}" -F "password=${password}" ${url}/api/auth/make-token)
    echo ${response} | python -c "import sys, json; print(json.load(sys.stdin)['token'])"
}

createProject () {
    local token=$1
    local name=$2
    local url=$3

    data=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${token}" -d "{\"name\":\"${name}\"}" ${url}/api/p/create)
    echo ${data} > /tmp/output/project-info.txt
    echo ${data} | python -c "import sys, json; print(json.load(sys.stdin)['url'])"
}

enableFlamenco () {
    local url=$1

    python manage.py flamenco setup_for_flamenco ${url}
}

createManager () {
    local email=$1
    local name=$2
    local description=$3

    python manage.py flamenco create_manager ${email} ${name} "${description}" > /tmp/output/manager-info.txt
}