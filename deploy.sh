
#!/bin/bash

# Lightsail Deployment Script for King of 20
set -e

echo "🚀 Starting deployment to Lightsail..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if LIGHTSAIL_IP is set
if [ -z "$LIGHTSAIL_IP" ]; then
    echo -e "${RED}Error: LIGHTSAIL_IP environment variable not set${NC}"
    echo "Please set it with: export LIGHTSAIL_IP=your-instance-ip"
    exit 1
fi

echo -e "${YELLOW}Deploying to: $LIGHTSAIL_IP${NC}"

# Create deployment archive
echo "📦 Creating deployment package..."
tar -czf deploy.tar.gz \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='tmp' \
    --exclude='log' \
    --exclude='public/assets' \
    --exclude='deploy.tar.gz' \
    .

# Copy files to server
echo "📤 Copying files to server..."
scp -i ~/.ssh/lightsail_key.pem deploy.tar.gz bitnami@$LIGHTSAIL_IP:/home/bitnami/

# Deploy on server
echo "🏗️  Setting up application on server..."
ssh -i ~/.ssh/lightsail_key.pem bitnami@$LIGHTSAIL_IP << 'EOF'
    # Create app directory
    sudo mkdir -p /opt/kingof20
    sudo chown bitnami:bitnami /opt/kingof20

    # Extract application
    cd /opt/kingof20
    tar -xzf /home/bitnami/deploy.tar.gz

    # Install system dependencies
    sudo apt update
    sudo apt install -y build-essential postgresql-client git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison libyaml-dev libncurses5-dev libffi-dev libgdbm-dev

    # Install rbenv and Ruby 3.3.5 (if not already installed)
    if ! command -v rbenv &> /dev/null; then
        echo "Installing rbenv and Ruby 3.3.5..."
        curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi

    # Load rbenv
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

    # Install Ruby 3.3.5 if not present
    if ! rbenv versions | grep -q "3.3.5"; then
        rbenv install 3.3.5
    fi
    rbenv global 3.3.5

    # Install nvm and Node.js 23+ (if not already installed)
    if ! command -v nvm &> /dev/null; then
        echo "Installing nvm and Node.js 23..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    fi

    # Load nvm and install Node.js 23
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 23
    nvm use 23

    # Install gems with proper Ruby version
    gem install bundler
    bundle install --deployment --without development test

    # Install Node.js dependencies and build assets with proper environment
    npm install
    export NODE_OPTIONS='--openssl-legacy-provider'
    bundle exec rails assets:precompile RAILS_ENV=production

    # Load environment variables and run migrations
    if [ -f .env.production ]; then
        export $(cat .env.production | grep -v '^#' | xargs)
        bundle exec rails db:migrate RAILS_ENV=production
    fi

    echo "✅ Deployment complete!"
EOF

# Cleanup
rm deploy.tar.gz

echo -e "${GREEN}🎉 Deployment finished!${NC}"
echo "Your app should be available at: http://$LIGHTSAIL_IP:3000"