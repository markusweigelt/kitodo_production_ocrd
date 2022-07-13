#!/bin/sh

#
# Kitodo Production Builder Entrypoint shell script
#

set -e

mkdir -p /data/

echo "========================================================================="
echo "Builder with type $BUILDER_TYPE started"
echo "========================================================================="

echo "builder type $BUILDER_TYPE"

if [ "$BUILDER_TYPE" = "RELEASE" ]; then
	
	curl -L https://github.com/kitodo/kitodo-production/releases/download/kitodo-production-${BUILDER_RELEASE_VERSION}/${BUILDER_RELEASE_WAR_NAME}.war > /data/kitodo.war

	curl -L https://github.com/kitodo/kitodo-production/releases/download/kitodo-production-${BUILDER_RELEASE_VERSION}/${BUILDER_RELEASE_CONFIG_MODULES_NAME}.zip > /data/kitodo-config-modules.zip

	curl -L https://github.com/kitodo/kitodo-production/releases/download/kitodo-production-${BUILDER_RELEASE_VERSION}/${BUILDER_RELEASE_SQL_NAME}.sql > /data/kitodo.sql
	
	echo "========================================================================="
	echo "Builder with type $BUILDER_TYPE ended"
	echo "========================================================================="
	echo "Release Version: $BUILDER_RELEASE_VERSION"
	echo "Release WAR Name: $BUILDER_RELEASE_WAR_NAME"
	echo "Release Config Modules Name: $BUILDER_RELEASE_CONFIG_MODULES_NAME"
	echo "Release SQL Name: $BUILDER_RELEASE_SQL_NAME"
	echo "========================================================================="
	echo "Have a nice day!"
	
	exit 0
fi

if [ "x$BUILDER_GIT_COMMIT" = "x" ]; then
  if [ "x$BUILDER_GIT_SOURCE_URL" = "x" ]; then
    echo "Syntax: docker-compose run kitodo [<BUILDER_GIT_COMMIT>] [<BUILDER_GIT_SOURCE_URL>]"
	echo "Either BUILDER_GIT_COMMIT or BUILDER_GIT_SOURCE_URL must be given."
	echo "Use \"master\" for BUILDER_GIT_COMMIT to get the latest commit."
	exit 1
  fi
  BUILDER_GIT_COMMIT="master"
fi
if [ "x$BUILDER_GIT_SOURCE_URL" = "x" ]; then
  if [ $BUILDER_GIT_COMMIT = "master" ]; then
	BUILDER_GIT_SOURCE_URL="https://github.com/kitodo/kitodo-production/archive/master.zip"
  else
    BUILDER_GIT_SOURCE_URL="https://github.com/kitodo/kitodo-production/archive/$BUILDER_GIT_COMMIT.zip"
  fi
elif [ `echo "$BUILDER_GIT_SOURCE_URL" | rev | cut -c 1-4` != 'piz.' ]; then
  if [ `echo "$BUILDER_GIT_SOURCE_URL" | rev | cut -c 1-1` != '/' ]; then
    BUILDER_GIT_SOURCE_URL="${BUILDER_GIT_SOURCE_URL}/"
  fi
  BUILDER_GIT_SOURCE_URL="${BUILDER_GIT_SOURCE_URL}archive/$BUILDER_GIT_COMMIT.zip"
fi

echo "========================================================================="
echo "1. Download source files"
echo "========================================================================="

echo "using commit $BUILDER_GIT_COMMIT"
echo "using $BUILDER_GIT_SOURCE_URL as download location"

curl -L $BUILDER_GIT_SOURCE_URL > master.zip
unzip master.zip 

DIR=`ls -1 . | grep kitodo-prod`
if [ x$DIR = "x" ]; then
  echo "No Kitodo Production directory found in zip"
  exit 1
fi
echo extracted to $DIR
if [ `echo "$DIR" | rev | cut -c 1-6` != 'retsam' ]; then
  mv $DIR kitodo-production-master
  echo renamed $DIR to kitodo-production-master
fi

echo "========================================================================="
echo "Create MySQL database and user"
echo "========================================================================="

echo "Wait for database container."
/tmp/wait-for-it.sh -t 0 -h $DB_HOST -p $DB_PORT

mysql --host=$DB_HOST -u root --password=$DB_ROOT_PASSWORD -e "drop database kitodo; create database kitodo; grant all privileges on kitodo.* to kitodo@'%' ;"


echo "SQL statements done."

sed -i "s!flyway.url=jdbc:mysql://localhost/kitodo?useSSL=false!flyway.url=jdbc:mysql://$DB_HOST/$DB_NAME?useSSL=false\&allowPublicKeyRetrieval=true!;" kitodo-production-master/Kitodo-DataManagement/src/main/resources/db/config/flyway.properties

echo "Adapted mysql connection for maven."


echo "========================================================================="
echo "2. Build files for deployment"
echo "========================================================================="

echo "========================================================================="
echo "Build development version and modules"
echo "========================================================================="

(cd kitodo-production-master/ && mvn clean package '-P!development' -DskipTests)
mv kitodo-production-master/Kitodo/target/kitodo-3*.war /data/kitodo.war

echo "========================================================================="
echo "Create Maven fake repository"
echo "========================================================================="

# Deprecated cause datamanagement use kitodo-api as provided scope in master
# For other no rebased branches it may still be neededc
# create a fake repo for kitodo api jar. we need it when generating the sql dump
API_VERSION=`ls kitodo-production-master/Kitodo-API/target/kitodo-api*.jar | xargs basename -s .jar | cut -c 12-` 
mkdir -p maven-fake-repo/org/kitodo/kitodo-api/$API_VERSION
cp kitodo-production-master/Kitodo-API/target/kitodo-api*.jar maven-fake-repo/org/kitodo/kitodo-api/$API_VERSION
# register the repo in the kitodo main pom.xml
MAVEN_URL="file://`pwd`/maven-fake-repo"
REPO_DEF="<repository><id>localfs</id><name>Local System</name><layout>default</layout><url>$MAVEN_URL</url><snapshots><enabled>true</enabled></snapshots></repository>"
sed -i "s!<repositories>!<repositories>$REPO_DEF!;" kitodo-production-master/pom.xml

echo "========================================================================="
echo "Generate SQL dump (flyway migration)"
echo "========================================================================="

echo "Build db"
cat kitodo-production-master/Kitodo/setup/schema.sql | mysql --host=$DB_HOST -u $DB_USER -D $DB_NAME --password=$DB_USER_PASSWORD
cat kitodo-production-master/Kitodo/setup/default.sql | mysql --host=$DB_HOST -u $DB_USER -D $DB_NAME --password=$DB_USER_PASSWORD
(cd kitodo-production-master/Kitodo-DataManagement && mvn flyway:baseline -Pflyway && mvn flyway:migrate -Pflyway)
mysqldump --no-tablespaces --host=$DB_HOST -u $DB_USER --password=$DB_USER_PASSWORD $DB_NAME > /data/kitodo.sql


echo "========================================================================="
echo "Create zip archive with directories and config file"
echo "========================================================================="

mkdir zip zip/config zip/debug zip/import zip/logs zip/messages zip/metadata zip/modules zip/plugins zip/plugins/command zip/plugins/import zip/plugins/opac zip/plugins/step zip/plugins/validation zip/rulesets zip/scripts zip/swap zip/temp zip/users zip/xslt zip/diagrams
install -m 444 kitodo-production-master/Kitodo/src/main/resources/kitodo_*.xml zip/config/
install -m 444 kitodo-production-master/Kitodo/src/main/resources/docket*.xsl zip/xslt/
install -m 444 kitodo-production-master/Kitodo/rulesets/*.xml zip/rulesets/
install -m 444 kitodo-production-master/Kitodo/diagrams/*.xml zip/diagrams/
install -m 554 kitodo-production-master/Kitodo/scripts/*.sh zip/scripts/
install -m 444 kitodo-production-master/Kitodo/modules/*.jar zip/modules/
chmod -w zip/config zip/import zip/messages zip/plugins zip/plugins/command zip/plugins/import zip/plugins/opac zip/plugins/step zip/plugins/validation zip/rulesets zip/scripts zip/xslt
(cd zip && zip -r /data/kitodo-config-modules.zip *)

chmod -R a+rw /data

echo "========================================================================="
echo "Builder with type $BUILDER_TYPE ended"
echo "========================================================================="
echo "Git Commit: $BUILDER_GIT_COMMIT"
echo "Git Repository URL: $BUILDER_GIT_SOURCE_URL"
echo "========================================================================="
echo "Have a nice day!"