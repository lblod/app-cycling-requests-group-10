#!/bin/bash

docker-compose up -d --build cycling
docker logs --follow --tail 200 app-cycling-requests-group-10_cycling_1
