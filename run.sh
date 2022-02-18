#!/bin/bash
docker rm dvxte
docker rmi dvxte
docker run --name dvxte -p 80:80 -p 1080:1080 -p 3000:3000 -p 4000:4000 -p 8000:8000 -p 8080:8080 -p 8200:8200 -p 9090:9090 davevs/dvxte
