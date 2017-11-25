# TERMINAL COMMANDS USED IN THIS LESSON

# mysqldump of a production database
docker run --net app --rm mysql:5.5 \
  mysqldump -h mysql -uproduction -pproduction production \
  > production.sql

# mysqldump ran remotely
ssh deploy@159.203.127.59 \
  docker run --net app --rm mysql:5.5 \
  mysqldump -h mysql -uproduction -pproduction production \
  > production.sql

# mysql restore of backup
docker run --net app -i --rm mysql:5.5 \
  mysql -h mysql -uproduction -pproduction production \
  < production.sql

# mysql restore ran remotely
ssh deploy@159.203.127.59 \
  docker run --net app -i --rm mysql:5.5 \
  mysql -h mysql -uproduction -pproduction production \
  < production.sql


## Backing up via data volume
# view volumes
docker inspect mysql
# connect a new container to mysql volumes
docker run --rm -it --volumes-from mysql ubuntu /bin/bash
# (inside container) backup /var/lib/mysql folder
tar cvf /backup.tar /var/lib/mysql
# (inside container) restore /var/lib/mysql folder
tar xpf /backup.tar

# remotely backing up volumes
ssh deploy@159.203.127.59 \
  docker run --rm -i --volumes-from mysql ubuntu \
  tar cv /var/lib/mysql \
  > backup.tar

# remotely restoring volumes
ssh deploy@159.203.127.59 \
  docker run --rm -i --volumes-from mysql ubuntu \
  tar xp \
  < backup.tar




