#! /bin/bash

# copy the mounted credentials into the user dir
cat /authorized_keys >> /.ssh/authorized_keys

# silence the greeting
touch /.hushlogin

# re-use most of the environment from root (i.e. Dockerfile)
set | fgrep -ve BASH > /.ssh/environment

# make "ocrd" look like the UID/GID user (to fit the volume permissions)
mkdir -p /.parallel
chown -R $UID:$GID /.parallel
chmod go-rwx /.ssh/*
chown $UID:$GID /.ssh/*
echo ocrd:x:$UID:$GID:SSH OCR user:/:/bin/bash >> /etc/passwd
echo admin:x:$UID:$GID:SSH control user:/:/bin/bash >> /etc/passwd
echo ocrd:*:19020:0:99999:7::: >> /etc/shadow
echo admin:*:19020:0:99999:7::: >> /etc/shadow

# wait for WORKERS semaphore before continuing (to prevent oversubscription)
# "wait $$" is not allowed, because sem runs it in a subshell of $$
# (so instead, we use tail --pid)
# also, we cannot use $$ directly, because SSHRC is not sourced but execd
# (so instead, we use the parent of the parent PID)
echo 'test x$USER != xocrd && exit' >> /.ssh/rc
echo 'parent=$(cat /proc/$PPID/stat | cut -d\  -f4)' >> /.ssh/rc
echo "workers=${WORKERS:-1}" >> /.ssh/rc
echo 'sem --will-cite -j $workers --bg --id ocrd_controller_job tail --pid $parent -f /dev/null' >> /.ssh/rc

# start OpenSSH in the background
#/usr/sbin/sshd -D -e
service ssh start

# disable kernel logging to allow unpriviledged rsyslog
/bin/sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# start Syslog in the background
service rsyslog start
sleep 1

# show Syslog in the foreground (for easy "docker logs" passing)
tail -f /var/log/syslog
