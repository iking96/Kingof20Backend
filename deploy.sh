
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

    # Extract application (clean JS files first to remove stale files)
    cd /opt/kingof20
    rm -rf app/javascript
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

    # Clean existing assets to ensure fresh compilation
    rm -rf public/packs
    rm -rf tmp/cache/webpacker

    # Set Node options and compile assets with proper environment
    export NODE_OPTIONS='--openssl-legacy-provider'
    export RAILS_ENV=production

    # Ensure CSS compilation happens
    bundle exec rails webpacker:clean
    bundle exec rails assets:precompile

    # Verify CSS was compiled
    if [ -f public/packs/manifest.json ]; then
        echo "📋 Checking manifest for CSS files..."
        if grep -q "application.css" public/packs/manifest.json; then
            echo "✅ CSS files found in manifest"
        else
            echo "⚠️  CSS files missing from manifest, attempting recompilation..."
            bundle exec rails webpacker:compile
            bundle exec rails assets:precompile
        fi
    else
        echo "❌ No manifest.json found"
    fi

    # Load environment variables and run migrations
    if [ -f .env.production ]; then
        export $(cat .env.production | grep -v '^#' | xargs)
        bundle exec rails db:migrate RAILS_ENV=production
        bundle exec rails db:seed RAILS_ENV=production
    fi

    # Kill any existing Rails processes to avoid port conflicts
    pkill -f "rails server" || true
    pkill -f "puma" || true

    # Wait for processes to fully terminate
    sleep 3

    # Start Rails server in production mode (in background)
    echo "🚀 Starting Rails server..."
    nohup bundle exec rails server -b 0.0.0.0 -p 3000 -e production > rails.log 2>&1 &

    # Wait a moment and check if server started
    echo "⏳ Checking if Rails server started..."
    RAILS_PID=""

    # Wait for "Listening on" message in logs which indicates successful startup
    for i in {1..20}; do
        sleep 10

        # Check if we can find the "Listening on" message in the log
        if grep -q "Listening on http://0.0.0.0:3000" rails.log 2>/dev/null; then
            RAILS_PID=$(pgrep -f "puma.*:3000" | head -1)
            break
        fi
    done

    if [ -n "$RAILS_PID" ]; then
        echo "✅ Rails server started successfully!"
        echo "📋 Server PID: $RAILS_PID"
        echo "📄 Logs available at: /opt/kingof20/rails.log"
    else
        echo "❌ Failed to start Rails server. Check logs:"
        tail -20 rails.log
    fi

    echo "✅ Deployment complete!"
EOF

# Cleanup
rm deploy.tar.gz

echo -e "${GREEN}🎉 Deployment finished!${NC}"
echo "Your app should be available at: http://$LIGHTSAIL_IP:3000"