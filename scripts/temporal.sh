#!/bin/bash

export TEMPORAL_HOME=$HOME/.personal/temporal

temporal.download(){
  cd $TEMPORAL_HOME
  rm -rf .compose || true
  git clone --depth=1 https://github.com/temporalio/docker-compose.git .compose
  cd .compose
  rm -rf .git .github
  find . -maxdepth 1 -name "docker-compose*" -type f | xargs -n1 sed -i '' '/^version:/Id'
  find . -maxdepth 1 -name "docker-compose*" -type f | xargs -n1 sed -i '' 's/8080:8080/127.0.0.1:9080:8080/g'
  find . -maxdepth 1 -name "docker-compose*" -type f | xargs -n1 sed -i '' 's/5432:5432/127.0.0.1:5432:5432/g'
  find . -maxdepth 1 -name "docker-compose*" -type f | xargs -n1 sed -i '' 's/7233:7233/127.0.0.1:7233:7233/g'
  cd -
}

temporal.start(){
  docker.start
  cd $TEMPORAL_HOME/.compose
  echo " "
  echo "[INFO] Starting Temporal Server"
  docker compose -f docker-compose-postgres.yml up -d 
  cd -
}

temporal.stop(){
  cd $TEMPORAL_HOME/.compose
  echo " "
  echo "[INFO] Stopping Temporal Server"
  docker compose -f docker-compose-postgres.yml down 
  cd -
}

temporal.logs(){
  cd $TEMPORAL_HOME/.compose
  echo " "
  temporal-postgresql
}

alias tctl="docker exec temporal-admin-tools tctl"
