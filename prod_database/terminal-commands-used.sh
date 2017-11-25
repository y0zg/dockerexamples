# TERMINAL COMMANDS USED IN THIS LESSON

# ping a server
docker run --rm ubuntu ping <address to ping>

# create a network
docker network create <network name>

# run ping on that network
docker run --net <network name> --rm ubuntu ping <address to ping>

# start your production database
docker run --net app -d --restart=always --name mysql \
  -e MYSQL_ROOT_PASSWORD=production \
  -e MYSQL_DATABASE=production \
  -e MYSQL_USER=production \
  -e MYSQL_PASSWORD=production \
  mysql:5.5

# run a mysql cli against a database container
docker run --rm -it --net app mysql:5.5 /bin/bash
mysql -h mysql -uproduction -pproduction

# execute migrations against a database
docker run --net app --rm willrstern/test-db-migrations
