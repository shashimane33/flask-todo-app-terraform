#!/bin/bash
apt update -y
apt install -y git npm
cd /home/ubuntu
git clone https://github.com/shashimane33/flask-todo-app-terraform
cd flask-todo-app-terraform/frontend
echo "BACKEND_URL=http://{backend_ip}:5000" > .env
npm install
nohup npm start > frontend.log 2>&1 &
