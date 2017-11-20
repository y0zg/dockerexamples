#create a "deploy" user with Docker privileges
useradd --user-group --create-home --shell /bin/bash deploy
usermod -aG docker deploy

#copy root authorized_keys to "deploy" user
mkdir /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown deploy /home/deploy/.ssh/authorized_keys
