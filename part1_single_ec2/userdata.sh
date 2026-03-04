#!/bin/bash
apt update -y
apt install -y git python3-pip python3-venv nodejs npm
cd /home/ubuntu
git clone https://github.com/shashimane33/flask-todo-app-terraform
cd flask-todo-app-terraform
# backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
nohup python3 app.py > backend.log 2>&1 &
# frontend
cd ../frontend
npm install
nohup npm start > frontend.log 2>&1 &