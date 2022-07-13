# Environment Variables of Docker Compose

The following variables must be defined.

## OCR-D

### Controller

(only relevant in **managed mode**, see [above](#setup))

{%
   include-markdown 'docs/_generated/env-controller-table.md'
%}

| Name | Default | Description
| --- | --- | --- |
| CONTROLLER_IMAGE | bertsky/ocrd_controller:latest | name and tag of image |
| CONTROLLER_HOST | ocrd-controller | name of host |
| CONTROLLER_ENV_UID | 1001 | user id of SSH user (`id -u` when using `make`) |
| CONTROLLER_ENV_GID | 1001 | group id of SSH user (`id -g` when using `make`)  |
| CONTROLLER_ENV_UMASK | 0002 | SSH user specific permission mask |
| CONTROLLER_PORT_SSH | 22 | SSH port to reach |
| CONTROLLER_KEYS | `./ocrd/controller/.ssh/authorized_keys` | file with public SSH keys of users allowed to login from Manager or externally |
| CONTROLLER_DATA | `./kitodo/data/metadata` | data volume to mount |
| CONTROLLER_MODELS | `./ocrd/controller/models` | path to Controller models (in `ocrd-resources/`) |
| CONTROLLER_CONFIG | `./ocrd/controller/config` | path to Controller config (in `ocrd/resources.yml`) |
| CONTROLLER_WORKERS | 1 | count of workers for processing |

### Manager

| Name | Default | Description
| --- | --- | --- |
| MANAGER_IMAGE | markusweigelt/ocrd_manager:latest | name and tag of image |
| MANAGER_HOST | ocrd-manager | name of host |
| MANAGER_ENV_UID | 1001 | user id of SSH user (`id -u` when using `make`) |
| MANAGER_ENV_GID | 1001 | group id of SSH user (`id -g` when using `make`) |
| MANAGER_ENV_UMASK | 0002 | ssh user specific permission mask |
| MANAGER_KEYS | `./ocrd/manager/.ssh/authorized_keys` | file with public SSH keys of users allowed to login from Kitodo or externally |
| MANAGER_KEY | `./ocrd/manager/.ssh/id_rsa` | file with private SSH key of `ocrd` user for login to local (`managed`) or external Controller |
| MANAGER_DATA | `./kitodo/data/metadata` | data volume to mount |

(It is allowed and realistic if `MANAGER_DATA` is different than `CONTROLLER_DATA`.
 Input/output will be synchronized between them at runtime.)

### Monitor

| Name | Default | Description
| --- | --- | --- |
| MONITOR_IMAGE | bertsky/ocrd_monitor:latest | name and tag of image |
| MONITOR_HOST | ocrd-monitor | name of host |
| MONITOR_PORT_WEB | 5000 | host-side port to exposed Web server |
| MONITOR_PORT_GTK | 8085 | host-side port to exposed Broadwayd (Gtk Web server) |
| MONITOR_PORT_LOG | 8088 | host-side port to exposed Dozzle (Docker log viewer) |
| MONITOR_DATA | `./kitodo/data/metadata` | data volume to mount |

(Currently, `MONITOR_DATA` should be the same as `MANAGER_DATA`.)

## Kitodo.Production 

### Resource Builder

| Name | Default | Description
| --- | --- | --- |
| BUILDER_TYPE | GIT | name of image |
| BUILDER_GIT_COMMIT | ocrd-main | branch "ocrd-main" of git repository |
| BUILDER_GIT_SOURCE_URL | https://github.com/markusweigelt/kitodo-production/ | repository of BUILDER_GIT_COMMIT |
| BUILDER_BUILD_RESOURCES | `./_modules/kitodo-production-docker/kitodo/build-resources` | directory path to resources for building Kitodo.Production image |

### Application

| Name | Default | Description                                               
| --- | --- | --- |
| APP_IMAGE | markusweigelt/kitodo-production:latest | name and tag of image |
| APP_BUILD_CONTEXT | `./_modules/kitodo-production-docker/kitodo` | directory of Dockerfile |
| APP_BUILD_RESOURCES | `./_modules/kitodo-production-docker/kitodo` | directory of build resources |
| APP_DATA | `./kitodo/data` | directory of application data e.g. config and modules |
| APP_KEY | `./kitodo/.ssh/id_rsa` | file with private ssh key of ocrd user to login to Manager |
| APP_PORT | 8080 | port of Kitodo.Production |

### Database

| Name | Default | Description                                               
| --- | --- | --- |
| DB_IMAGE | mysql:8.0.26 | name and tag of image |
| DB_HOST | kitodo-db | host of database |
| DB_PORT | 3306 | port of database |
| DB_ROOT_PASSWORD | 1234 | root user password |
| DB_NAME | kitodo | name of database used by Kitodo.Productions |
| DB_USER | kitodo | username to access database |
| DB_USER_PASSWORD | kitodo | password used by username to access database |

### Elastic Search

| Name | Default | Description                                               
| --- | --- | --- |
| ES_IMAGE | docker.elastic.co/elasticsearch/elasticsearch:7.17.3 | name and tag of image |
| ES_HOST | kitodo-es | host of elastic search |
| ES_REST_PORT | 9200 | rest port |
| ES_NODE_PORT | 9300 | node port |

### Active MQ

| Name | Default | Description                                               
| --- | --- | --- |
| MQ_IMAGE | markusweigelt/activemq:latest | name and tag of image |
| MQ_HOST | kitodo-mq | host of active mq |
| MQ_PORT | 61616 | port of active mq |
