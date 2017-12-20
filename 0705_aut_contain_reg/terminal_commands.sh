#run a web container with env vars
docker run -d --net apps --name web1 \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=80 \
  dockercloud/hello-world

# Run 2 new register containers
# - expose the docker socket
# - add negative affinity so only one ends up on each node
docker run -d --net apps --name register1 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e constraint:type==apps \
  -e affinity:container!=register* \
  -e DEBUG=true \
  willrstern/docker-swarm-registrator

docker run -d --net apps --name register2 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e constraint:type==apps \
  -e affinity:container!=register* \
  -e DEBUG=true \
  willrstern/docker-swarm-registrator

# you can see that etcd receives a registration for web1
docker run --rm -it alpine /bin/sh
apk add --update curl
curl etcd:4001/v2/keys/services/web?recursive=true

#let's run 2 more web containers and an "api" container all with env vars
docker run -d --net apps --name web2 \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=80 \
  dockercloud/hello-world

docker run -d --net apps --name web3 \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=80 \
  dockercloud/hello-world

docker run -d --net apps --name api1 \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=api.com \
  -e SERVICE_NAME=api \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=80 \
  dockercloud/hello-world

