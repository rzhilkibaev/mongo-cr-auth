#!/usr/bin/env bash

set -e
set -o pipefail

mongod --dbpath=${MONGO_DBPATH} &

# downgrade authSchema to version 3, otherwise the user will be added with SCRAM-SHA-1 auth

counter=10
while ! mongo admin --eval "db.system.version.remove({});"; do   
    ((counter--))
    if [[ $counter = 0 ]];then
        break
    fi
    sleep 5
done
mongo admin --eval "db.system.version.insert({ '_id': 'authSchema', 'currentVersion': 3 });"

mongo admin --eval "db.createUser({user: 'admin', pwd: 'admin', roles:[{role:'root',db:'admin'}]});"

mongo admin --eval "db.shutdownServer({timeoutSecs: 3});"
sleep 3
