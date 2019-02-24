#! /bin/bash

function initialize_worker() {
    printf "***************************************************\n\t\tSetting up host \n***************************************************\n"
    # Update packages
    echo ======= Updating packages ========
    sudo apt-get update

    # Export language locale settings
    echo ======= Exporting language locale settings =======
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8

    # Install pip3
    echo ======= Installing pip3 =======
    sudo apt-get install -y python3-pip
}

function setup_python_venv() {
    printf "***************************************************\n\t\tSetting up Venv \n***************************************************\n"
    # Install virtualenv
    echo ======= Installing virtualenv =======
    pip3 install virtualenv

    # Create virtual environment and activate it
    echo ======== Creating and activating virtual env =======
    virtualenv venv
    source ./venv/bin/activate
}

function clone_app_repository() {
    printf "***************************************************\n\t\tFetching App \n***************************************************\n"
    # Clone and access project directory
    echo ======== Cloning and accessing project directory ========
    if [[ -d ~/flask-dog-api ]]; then
        sudo rm -rf ~/flask-dog-api
        git clone https://github.com/c-silber/flask-dog-api.git ~/flask-dog-api
        cd ~/flask-dog-api/
    else
        git clone https://github.com/c-silber/flask-dog-api.git ~/flask-dog-api
        cd ~/flask-dog-api/
    fi
}

function setup_app() {
    printf "***************************************************\n    Installing App dependencies and Env Variables \n***************************************************\n"
    setup_env
    # Install required packages
    echo ======= Installing required packages ========
    pip install -r requirements.txt

    echo ======= Downloading dog images ========
    wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/dogImages.zip
    unzip dogImages.zip

    echo ======= Downloading bottleneck_features ========
    mkdir bottleneck_features
    cd bottleneck_features/
    wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/DogInceptionV3Data.npz
    cd ../

}

# Create and Export required environment variable
function setup_env() {
    echo ======= Exporting the necessary environment variables ========
    sudo cat > ~/.env << EOF
    export S3_BUCKET=flask-dog-project
    export S3_KEY=AKIAIFL7DO2KU2TBT4HA
    export S3_SECRET_ACCESS_KEY=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
    export FLASK_APP=wsgi.py
EOF
    echo ======= Exporting the necessary environment variables ========
    source ~/.env
}

# Install and configure nginx
function setup_nginx() {
    printf "***************************************************\n\t\tSetting up nginx \n***************************************************\n"
    echo ======= Installing nginx =======
    sudo apt-get install -y nginx

    # Configure nginx routing
    echo ======= Configuring nginx =======
    echo ======= Removing default config =======
    sudo rm -rf /etc/nginx/sites-available/default
    sudo rm -rf /etc/nginx/sites-enabled/default
    echo ======= Replace config file =======
    sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/default
    server {
            listen 80 default_server;
            listen [::]:80 default_server;
            server_name _;
            location / {
                    # reverse proxy and serve the app
                    # running on the localhost:8000
                    proxy_pass http://127.0.0.1:8000/;
                    proxy_set_header HOST \$host;
                    proxy_set_header X-Forwarded-Proto \$scheme;
                    proxy_set_header X-Real-IP \$remote_addr;
                    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            }
    }
EOF'

    echo ======= Create a symbolic link of the file to sites-enabled =======
    sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

    # Ensure nginx server is running
    echo ====== Checking nginx server status ========
    sudo systemctl restart nginx
    sudo nginx -t
}

# Add a launch script
function create_launch_script () {
    printf "***************************************************\n\t\tCreating a Launch script \n***************************************************\n"

    sudo cat > /home/ubuntu/launch.sh <<EOF
    #!/bin/bash
    cd ~/flask-dog-api
    source ~/.env
    source ~/venv/bin/activate
    gunicorn app:APP -D
EOF
    sudo chmod 744 /home/ubuntu/launch.sh
    echo ====== Ensuring script is executable =======
    ls -la ~/launch.sh
}

function configure_startup_service () {
    printf "***************************************************\n\t\tConfiguring startup service \n***************************************************\n"

    sudo bash -c 'cat > /etc/systemd/system/flask-dog-api.service <<EOF
    [Unit]
    Description=flask-dog-api startup service
    After=network.target
    [Service]
    User=ubuntu
    ExecStart=/bin/bash /home/ubuntu/launch.sh
    [Install]
    WantedBy=multi-user.target
EOF'

    sudo chmod 664 /etc/systemd/system/flask-dog-api.service
    sudo systemctl daemon-reload
    sudo systemctl enable flask-dog-api.service
    sudo systemctl start flask-dog-api.service
    sudo service flask-dog-api status
}

Serve the web app through gunicorn
function launch_app() {
    printf "***************************************************\n\t\tServing the App \n***************************************************\n"
    sudo bash /home/ubuntu/launch.sh
}

######################################################################
########################      RUNTIME       ##########################
######################################################################

initialize_worker
setup_python_venv
clone_app_repository
setup_app
setup_nginx
create_launch_script
configure_startup_service
launch_app
