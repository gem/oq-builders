#!/bin/bash
while :
do
    (echo > /dev/tcp/oq-cluster-rabbitmq/5672) >/dev/null 2>&1
    result=$?
    if [[ $result -eq 0 ]]; then
        break
    fi
    sleep 1
done

# Start celery
/opt/openquake/bin/celery worker --config openquake.engine.celeryconfig --purge -Ofair
