# run nginx-etcd containers on both lb nodes
docker -H :4000 run -d --net apps --name lb1 -p 80:80 \
  -e affinity:container!=lb* \
  -e constraint:type==lb \
  -e NGINX_NAME=production \
  willrstern/nginx-etcd

docker -H :4000  run -d --net apps --name lb2 -p 80:80 \
  -e affinity:container!=lb* \
  -e constraint:type==lb \
  -e NGINX_NAME=production \
  willrstern/nginx-etcd

# now route your test.com and api.com to your LB nodes!

# or test it out now...
# curl -H "Host: api.com" <lb node>
# change /etc/hosts to test out DNS for test.com and api.com

# what if the API needs to scale?
docker -H :4000 run -d --net apps --name api2 \
  -e constraint:type==apps \
  -e SERVICE_VIRTUAL_HOST=api.com \
  -e SERVICE_NAME=api \
  -e SERVICE_TAGS=nginx:production \
  -e SERVICE_PORT=80 \
  dockercloud/hello-world
