#!/bin/bash
# This script provides a front end to a Swift / Couchdb environment
#
# This script is executed within a Swift Docker container with the expectation
# that a couchdb instance exists at $COUCH_URL
# Note that a specific database is not expected to be encoded in the url
#
# The couchdb instance will be populated by local data if it is empty
# Data is uploaded from the local /code/.data directory where each sub directory
# is mapped to a couchdb database of the same name. Each json file within the
# subdirectory will be loaded in couchdb
#

if [ "$#" -eq 0 ] | [ "$1" == "help" ]; then

    echo "Options"
    echo ""
    echo "Install compose script into current directory:"
    echo ""
    echo 'docker -it -v $PWD:/code swiftercodelab install'
    echo ""
    echo "Use docker compose to start a local running environment:"
    echo ""
    echo "docker-compose up -d"
    echo ""
    echo "Use docker compose to stop a local running environment:"
    echo ""
    echo "docker-compose down"
    echo ""
    echo "Use docker to drive swift building"
    echo "docker -it -v $PWD:/code swiftercodelab build"
    echo ""
    echo "Use docker to drive swift in other ways:"
    echo "Replace * below with any swift command. Try '-help'"
    echo "docker -it -v $PWD:/code swiftercodelab *"

    exit 0
fi

# if setup requested then copy in compose script
# for later usage

if [ "$1" == "install" ]; then
  cp -rf /scripts/docker-compose.yml /code
  exit 0
fi

if [ "$1" == "start" ]; then

  # get a list of local directories and upload json docs to couchdb
  # each dir will be mapped to a database
  # each document will be loaded with an id#
  # each document must contain well formed json.  "{}" at the very least

  readarray -t local_dbs <<< $(find ./.data -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

  for i in $local_dbs
  do
     echo "checking for database $i"
     curl -sS -f --head $COUCH_URL/$i
     if [ $? -ne 0 ]; then
      # assume DB does not exist
      echo "$i does not exist - uploading data"
      curl -sS -X PUT $COUCH_URL/$i
      readarray -t local_files <<< $(find ./.data/$i  -name '*.json' -mindepth 1 -maxdepth 1 -type f)
      id=1
      for j in $local_files
      do
        echo "uploading $j"
        curl -sS -X PUT -d @$j $COUCH_URL/$i/$id -c "application/json"
        id=id+1
      done
     fi
  done


  file=`find .build/debug -executable -type f ! -name "*.*"`
  echo "executing $file"
  $file
  exit 0
fi

# default as swift what to do

swift "$@"
