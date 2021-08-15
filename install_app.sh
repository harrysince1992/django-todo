#!/bin/bash
#Sample shell file to deploy app automatically using docker swarm and stack
#Author: Harpreet Singh
#Save script output to a file
current=$(date +%s)
if [ -d /opt/script-log/ ]
then	
	bash | tee /opt/script-log/install.log_${current}  2>&1 #this will save all output including errors until the bash session is ended
else
	mkdir -p /opt/script-log/
	bash | tee /opt/script-log/install.log-${current}
fi


#color definitions
RED='\033[0;31m'
GREEN='\033[0;32.'
NC='\033[0m'

# echo hostname and username
echo -e "${GREEN}Script is being run by $(whoami) on $(hostname)${NC}"

# pick the code and move it to prod app directory
sudo rm -rf /opt/prod/*
sudo mv /home/ubuntu/code.tar.gz /opt/prod/

# Unpack the tar file
cd /opt/prod/
tar -xvzf /opt/prod/code.tar.gz

# After unpacking, save tar file as backup to another folder
sudo mv code.tar.gz ../backup/code.tar.gz_${current}

# New image has to be created for application
cd /opt/prod/todo/
echo -e "${GREEN}Building new docker image for the application...${NC}"
sudo docker build -t django-img .

if [ $? -eq 0 ]
then
	echo -e "${GREEN} Building new docker image is successful.${NC}"
else
	echo -e "${RED} Building new image was unsuccessful.${NC}"
fi

# After image is built, tag it and push to docker hub private repo
sudo docker image tag django-img harrysince1992/devops:django-img

echo -e "${GREEN} Pushing to private docker repo...${NC}"
sudo docker push harrysince1992/devops:django-img

if [ $? -eq 0 ]
then
        echo -e "${GREEN} Image has been pushed to private docker repo.${NC}"
else
	echo -e "${RED} Image push failed. Please check logs in /opt/script-log/ directory.${NC}"
fi

# after image is pushed, deploy new stack
cd ../

sudo docker stack deploy --with-registry-auth -c docker-compose.yml webapp

if [ $? -eq 0 ]
then
        echo -e "${GREEN}Application deployment is successful.${NC}"
else
        echo -e "${RED}App deployment  was unsuccessful.${NC}"
fi

######################################################################################################

