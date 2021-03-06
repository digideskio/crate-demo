#!/bin/bash

currDir=$(pwd)

if [ -d "$currDir/data" ]
then
  echo "Data already downloaded"
else
  echo "No data, downloading. This may take a while."
  mkdir data
  mon=`date +%m`
  lastmonth=`expr $mon - 1`
  wget http://data.githubarchive.org/2015-0$lastmonth-{01..30}-{0..23}.json.gz -P data
fi

docker-compose up -d
CONTAINERIP=$(boot2docker ip)

http $CONTAINERIP:4200/_sql stmt="DROP TABLE if exists ghevent"

http $CONTAINERIP:4200/_sql stmt="CREATE TABLE ghevent (id STRING primary key, type STRING, actor OBJECT, repo OBJECT, payload OBJECT, public BOOLEAN, created_at TIMESTAMP)"

http $CONTAINERIP:4200/_sql stmt="COPY ghevent FROM '/importdata/*' WITH (compression = 'gzip', overwrite_duplicates = 'TRUE')"

# TODO: Run Apps
# Android, Python, Rails?
# Android
emulator -avd Nexus_5_API_22 && adb install Android/app/build/outputs/apk/app-debug.apk && adb shell am start -a android.intent.action.MAIN -n io.crate.cratedemo/io.crate.cratedemo.MainActivity
# TODO: Seems you still have to open app. We could also install to a real phone.
