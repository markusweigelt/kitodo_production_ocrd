# Makefile Variables 

## MODE

You may want Docker Compose to either
- **manage** the Controller (besides Production and Manager services itself), or
- leave the Controller to be run **standalone** (and merely control Production and Manager here).

### Managed Mode

This is the default setting in the Makefile, and can be made explicit via

    export MODE=managed

Equivalently, when using `docker-compose` without the Makefile, it is recommended
to export all config files into a variable once
(so you won't have to type `-f docker-compose.kitodo-app.yml` each time):

    export COMPOSE_FILE=docker_compose.yml:docker_compose.managed.yml:docker-compose.kitodo-app.yml

### Standalone Mode

In this mode, you build, configure, start and stop the [OCR-D Controller](https://github.com/bertsky/ocrd_controller)
_externally (and possibly remotely)_.

When using the Makefile, just set

    export MODE=standalone

in your shell once.

Equivalently, when using `docker-compose` without the Makefile, you should set

    export COMPOSE_FILE=docker_compose.yml:docker-compose.kitodo-app.yml

In addition, you _must_ also [configure](#configuration) where the Manager can find the standalone Controller.
_For example_, you may want to set:

    export MODE=standalone CONTROLLER_ENV_UID=$(id -u) CONTROLLER_HOST=ocrserver CONTROLLER_PORT_SSH=8022