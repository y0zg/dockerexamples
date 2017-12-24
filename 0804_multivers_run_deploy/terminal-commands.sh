# build our "api" containers and run them
docker build -t api-v1 ./api-v1
docker build -t api-v2 ./api-v2

docker run -d --net apps --name api-v1 api-v1
docker run -d --net apps --name api-v2 api-v2

# run a standard nginx container with our api.conf file
docker run -d --net apps --name lb -v '/<your-working-files-path>/0804/api.conf:/etc/nginx/conf.d/api.conf' -p 80:80 nginx
