#!/bin/bash

docker-compose up -d --build cycling-application-request-service
docker logs --follow --tail 200 app-cycling-requests-group-10_cycling-application-request-service_1
