#!/bin/bash

# Function to check if a package is installed
package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# Check if docker is installed, and install if not present
if ! package_installed docker; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "Docker installed successfully."
fi

# Check if docker-compose is installed, and install if not present
if ! package_installed docker-compose; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
fi

# Function to create a WordPress site
create_wordpress_site() {
    site_name=$1

    # Create a directory for the site
    mkdir "$site_name"
    cd "$site_name"

    # Create a docker-compose.yml file
    cat <<EOT >> docker-compose.yml
version: '3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
volumes:
  db_data:

EOT

    # Create the site's entry in /etc/hosts
    sudo -- sh -c "echo '127.0.0.1 $site_name' >> /etc/hosts"

    # Start the containers
    docker-compose up -d

    echo "WordPress site created successfully. You can access it at http://$site_name"
}

# Function to open the site in a browser
open_in_browser() {
    site_name=$1
    if command -v xdg-open >/dev/null; then
        xdg-open "http://$site_name"
    elif command -v open >/dev/null; then
        open "http://$site_name"
    else
        echo "Please open http://$site_name in your browser."
    fi
}

# Function to enable or disable the site
toggle_site() {
    site_name=$1
    cd "$site_name"

    if docker-compose ps | grep -q "Up"; then
        echo "Disabling the site..."
        docker-compose stop
        echo "Site disabled."
    else
        echo "Enabling the site..."
        docker-compose start
        echo "Site enabled."
    fi
}

# Function to delete the site
delete_site() {
    site_name=$1
    cd "$site_name"

    echo "Stopping and removing containers..."
    docker-compose down

    echo "Removing site directory..."
    cd ..
    rm -rf "$site_name"

    echo "Removing site entry from /etc/hosts..."
    sudo sed -i "/^127\.0\.0\.1 $site_name/d" /etc/hosts

    echo "Site deleted successfully."
}

# Main script

# Check if a command-line argument is provided
if [ -z "$1" ]; then
    echo "Please provide a site name as a command-line argument."
    exit 1
fi

site_name=$1

# Check if the site exists
if [ -d "$site_name" ]; then
    echo "Site '$site_name' already exists."
    exit 1
fi

# Create the WordPress site
create_wordpress_site "$site_name"

# Open the site in a browser
open_in_browser "$site_name"

# Prompt the user to enable/disable the site or delete it
while true; do
    read -p "Do you want to enable/disable the site (e), delete the site (d), or exit (x)? " choice
    case "$choice" in
        [Ee]* )
            toggle_site "$site_name"
            ;;
        [Dd]* )
            delete_site "$site_name"
            exit 0
            ;;
        [Xx]* )
            exit 0
            ;;
        * )
            echo "Invalid choice. Please try again."
            ;;
    esac
done

