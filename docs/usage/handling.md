# Handling of Docker Compose

## Starting

To start containers from images for all services

    make start

(or equivalently:)

    docker-compose up -d


## Stopping

To stop containers for all services

    make stop

(or equivalently:)

    docker-compose stop


## Stopping and removing

To stop containers for all services, and then remove the stopped containers as well as any created networks:

    make down

(or equivalently:)

    docker-compose down


## Dumping

To see the complete configuration for Docker Compose:

    make config

(or equivalently:)

    docker-compose config


## Status

To get a list of currently running containers:

    make status

(or equivalently:)

    docker-compose ps