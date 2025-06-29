#!/bin/bash

docker.start() {
  if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Attempting to start Docker..."
    open --background -a Docker

    echo "Waiting for Docker to start..."
    while ! docker info >/dev/null 2>&1; do
      sleep 2
    done

    echo "Docker is now running."
  else
    echo "Docker is already running."
  fi
}

docker.stop() {
  DOCKER_PIDS=$(pgrep -f "/Applications/Docker.app/Contents/MacOS/Docker")

  if [ -n "$DOCKER_PIDS" ]; then
      echo "Stopping Docker..."
      
      # Kill all Docker-related processes
      echo "$DOCKER_PIDS" | xargs kill

      # Wait for all Docker processes to stop
      while pgrep -f "/Applications/Docker.app/Contents/MacOS/Docker" > /dev/null; do
          sleep 1
      done

      echo "Docker has been stopped."
  else
      echo "Docker is not running."
  fi

}

_wait.for.containers() {
  local containers=("$@")
  local timeout=60

  for container in "${containers[@]}"; do
    echo "Waiting for container $container to be up..."

    start_time=$(date +%s)
    while : ; do
      dockerstatus=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)

      if [[ "$dockerstatus" == "running" ]]; then
        echo "Container $container is up!"
        break
      fi

      current_time=$(date +%s)
      elapsed_time=$((current_time - start_time))

      if [[ $elapsed_time -ge $timeout ]]; then
        echo " "
        echo "Timed out waiting for container $container to be up."
        echo " "
        return 1
      fi

      sleep 2
    done
  done

  echo "All containers are up!"
  return 0
}


docker.cleanup(){
  echo "[INFO] Started cleaning up stopped or exited containers .... " 
  echo "" 
  echo "[INFO] List if exited or created continer not running .."
  echo " "
  docker ps -aq -f status=exited -f status=created
  docker rm $(docker ps -aq -f status=exited -f status=created)
  echo " "
  echo "[INFO] Running containers afetr cleanup ..."
  docker container ls
  echo "[INFO] Completed cleaning up stopped or exited containers .... " 
}

docker.plugin.install(){
    PLUGIN_NAME="grafana/loki-docker-driver:latest"
    ALIAS="loki"

    # Check if the plugin is already installed
    if ! docker plugin ls --format '{{.Name}}' | grep -q "$PLUGIN_NAME"; then
        echo "Installing $PLUGIN_NAME..."
        docker plugin install "$PLUGIN_NAME" --alias "$ALIAS" --grant-all-permissions
    else
        echo "$PLUGIN_NAME is already installed."
    fi
}
