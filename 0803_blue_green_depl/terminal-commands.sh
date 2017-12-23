# build our register, lb & web containers
docker build -t register ./register
docker build -t lb ./nginx-etcd
docker build -t web .

# run our registration pieces
docker run -d --name etcd --net apps elcolio/etcd
docker run -d --name register --net apps -e DEBUG=true -v /var/run/docker.sock:/var/run/docker.sock register

# set current "web" color to green
docker run --rm --net apps appropriate/curl \
  -X PUT etcd:4001/v2/keys/services/web/color -d "value=green"

# run an LB and 2 "green" web containers
docker run -d --restart always --name lb --net apps \
  -e NGINX_NAME=production \
  -p 80:80 \
  nginx-etcd-blue-green

docker run -d --restart always --net apps --name web1-green \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=3000 \
  -e SERVICE_COLOR=green \
  web

docker run -d --restart always --net apps --name web2-green \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=3000 \
  -e SERVICE_COLOR=green \
  web

# change server.js and rebuild web
docker build -t web .

# now we can run 2 "blue" containers
docker run -d --restart always --net apps --name web1-blue \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=3000 \
  -e SERVICE_COLOR=blue \
  web

docker run -d --restart always --net apps --name web2-blue \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=test.com \
  -e SERVICE_NAME=web \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=3000 \
  -e SERVICE_COLOR=blue \
  web

# toggling the color to blue will toggle between green and blue containers
docker run --rm --net apps appropriate/curl \
  -X PUT etcd:4001/v2/keys/services/web/color -d "value=blue"

# when we're satisfied with our update, we can remove the green containers
docker stop web1-green web2-green && docker rm web1-green web2-green

# out next deployment will be green

