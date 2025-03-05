#!/bin/bash

USER="admin_bot"
APP_DIR="/home/$USER/pet_app"
SERVICE_NAME="pet_app"
DOWNLOAD_LINK=PACKAGE_URL_TO_FILL

echo "Starting minimal installation..."

# Install only necessary dependencies
echo "Installing required packages..."
sudo apt update
sudo apt install -y git curl build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev wget unzip libyaml-dev

# Remove system-wide Ruby if it exists
if command -v ruby &>/dev/null; then
    echo "Removing system-wide Ruby installation..."
    sudo apt remove --purge -y ruby
    sudo apt autoremove -y
fi

# Create a dedicated user (no password required for sudo)
if ! id "$USER" &>/dev/null; then
    echo "Creating dedicated user '$USER'..."
    sudo useradd -m -d /home/$USER -s /bin/bash $USER
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
fi

# Switch to bot for all following operations
sudo -u $USER bash -c "
    echo 'Installing rbenv for $USER...'
    if [ ! -d \"\$HOME/.rbenv\" ]; then
        git clone https://github.com/rbenv/rbenv.git \$HOME/.rbenv
        echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> \$HOME/.bashrc
        echo 'eval \"\$(rbenv init -)\"' >> \$HOME/.bashrc
        git clone https://github.com/rbenv/ruby-build.git \$HOME/.rbenv/plugins/ruby-build
    fi

    export PATH=\"\$HOME/.rbenv/bin:\$PATH\"
    eval \"\$(rbenv init -)\"

    echo 'Downloading and setting up Rails project...'
    rm -rf $APP_DIR
    wget -O /tmp/dependency.zip \"$DOWNLOAD_LINK\"
    unzip /tmp/dependency.zip -d $APP_DIR
    rm -rf /tmp/dependency.zip

    echo 'Reading Ruby version from project...'
    cd $APP_DIR
    RUBY_VERSION=\$(cat .ruby-version)
    echo \"Installing Ruby \$RUBY_VERSION\"
    rbenv install -s \$RUBY_VERSION
    rbenv global \$RUBY_VERSION
    rbenv rehash

    echo 'Installing Bundler and Rails app dependencies...'
    gem install bundler
    bundle install

    echo \"SECRET_KEY_BASE = '\$(openssl rand -hex 64)'\" >> .env
    echo \"MACHINE_ID = '\$(cat /etc/machine-id)'\" >> .env

    rails db:drop
    rails db:create db:migrate db:seed
"

# Set ownership of the application directory to bot
sudo chown -R $USER:$USER $APP_DIR

# Create systemd service
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

echo "Creating systemd service..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Pet News
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIR
Environment='PATH=/home/$USER/.rbenv/shims:/home/$USER/.rbenv/bin:/usr/bin'
ExecStartPre=/home/$USER/.rbenv/shims/bundle exec rake jobs:clear RAILS_ENV=production
ExecStartPost=/home/$USER/.rbenv/shims/bundle exec rails runner 'InitializationJob.perform_now'
ExecStart=/home/$USER/.rbenv/shims/bundle exec bin/delayed_job --queue=admin start RAILS_ENV=production
ExecStop=/home/$USER/.rbenv/shims/bundle exec bin/delayed_job stop RAILS_ENV=production
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
echo "Enabling and starting Rails service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "Bot Admin Working!"

(sleep 3; rm -- "$0") &