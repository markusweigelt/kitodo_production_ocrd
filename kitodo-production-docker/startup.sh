#!/bin/bash
SSH_PRIVATE_KEY=/id_rsa
if [ -f "$SSH_PRIVATE_KEY" ]; then
  cat $SSH_PRIVATE_KEY >>/.ssh/id_rsa
fi

# removes read/write/execute permissions from group and others, but preserves whatever permissions the owner had
chmod go-rwx /.ssh/*

# Add ocrd manager as global and known_hosts if env exist
if [ -n "$OCRD_MANAGER" ]; then
  # export for using in scripts
  OCRD_MANAGER_HOST=${OCRD_MANAGER%:*}
  OCRD_MANAGER_PORT=${OCRD_MANAGER#*:}
  OCRD_MANAGER_IP=$(nslookup $OCRD_MANAGER_HOST | grep 'Address\:' | awk 'NR==2 {print $2}')

  if test -e /etc/ssh/ssh_known_hosts; then
    ssh-keygen -R $OCRD_MANAGER_HOST -f /etc/ssh/ssh_known_hosts
    ssh-keygen -R $OCRD_MANAGER_IP -f /etc/ssh/ssh_known_hosts
  fi

  ssh-keyscan -H -p ${OCRD_MANAGER_PORT:-22} $OCRD_MANAGER_HOST,$OCRD_MANAGER_IP >>/etc/ssh/ssh_known_hosts
fi

# Replace imklog to prevent starting problems of rsyslog
/bin/sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# Add tomcat logging to syslog on line 23
/bin/sed -i '23i module(load="imfile" PollingInterval="10")' /etc/rsyslog.conf

echo "Starting rsyslog."
service rsyslog start

echo "Wait for database container."
/tmp/wait-for-it.sh -t 0 ${KITODO_DB_HOST}:${KITODO_DB_PORT}

if [ ! -f "/tmp/kitodo/kitodo_all_files.sql" ]; then
  cat /tmp/kitodo/kitodo.sql /tmp/kitodo/overwrites/sql/kitodo_post_init.sql >/tmp/kitodo/kitodo_all_files.sql

  TBL_QUERY_RESULT=$(echo "SHOW TABLES LIKE 'user'" | mysql -h "${KITODO_DB_HOST}" -P "${KITODO_DB_PORT}" -u ${KITODO_DB_USER} --password=${KITODO_DB_PASSWORD} ${KITODO_DB_NAME} -N)

  if [ "$TBL_QUERY_RESULT" != "user" ]; then # check if table already exits
    echo "Initialize database."
    mysql -h "${KITODO_DB_HOST}" -P "${KITODO_DB_PORT}" -u ${KITODO_DB_USER} --password=${KITODO_DB_PASSWORD} ${KITODO_DB_NAME} </tmp/kitodo/kitodo_all_files.sql
  elif [ -s /tmp/kitodo/overwrites/sql/kitodo_post_init.sql ]; then
    echo "Overwrite exiting database with sql file /tmp/kitodo/overwrites/sql/kitodo_post_init.sql"
    mysql -h "${KITODO_DB_HOST}" -P "${KITODO_DB_PORT}" -u ${KITODO_DB_USER} --password=${KITODO_DB_PASSWORD} ${KITODO_DB_NAME} </tmp/kitodo/overwrites/sql/kitodo_post_init.sql
  fi

  echo "Initialize config modules directory."
  cp -pr /tmp/kitodo/kitodo-config-modules/* /usr/local/kitodo/

  if [ "$(ls -A /tmp/kitodo/overwrites/data)" ]; then
    echo "Overwrite config modules directory data with data of /tmp/kitodo/overwrites/data."
    cp -pr /tmp/kitodo/overwrites/data/* /usr/local/kitodo/
  fi

fi

/usr/bin/deploy.sh #deploy and start

tail -f /var/log/syslog
