#!/bin/sh

excalidraw.start(){
    docker run --rm -dit --name excalidraw -p 9280:80 excalidraw/excalidraw:latest
    _wait.for.containers excalidraw
    open "http://localhost:9280"
     docker container ls
}

excalidraw.stop(){
    docker stop excalidraw || true
}

drawio.start(){
    docker.start
    docker run --rm -dit --name drawio -p 9480:8080 -p 9484:8443 jgraph/drawio:latest
    _wait.for.containers drawio
    open "http://localhost:9480"
    docker container ls
}

drawio.stop(){
    docker stop drawio || true
}

mermaid.start(){
    docker run --rm -dit --name mermaid -p 9480:80 minlag/mermaid-cli:latest
    _wait.for.containers mermaid
    open "http://localhost:9480"
    docker container ls
}


mermaid.stop(){
    docker stop mermaid || true
}

swagger.start(){
    docker run --rm -dit --name swagger -p 9380:8080 swaggerapi/swagger-editor:latest
    _wait.for.containers swagger
    open "http://localhost:9380"
    docker container ls
}

swagger.stop(){
    docker stop swagger || true
}
