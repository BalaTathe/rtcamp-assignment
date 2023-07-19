# WordPress Site Creation Script

This command-line script allows you to easily create, manage, and delete WordPress sites using a LEMP stack running inside Docker containers.

## Requirements

- Docker
- Docker Compose

## Usage

1. Clone or download this repository to your local machine.
2. Open a terminal and navigate to the directory where the script (`wordpress.sh`) is located.
3. Make the script executable: `chmod +x wordpress.sh`.
4. Run the script with a site name as a command-line argument: `./wordpress.sh example.com`.
5. Follow the instructions provided by the script to enable/disable the site or delete it.

## Features

- Checks if Docker and Docker Compose are installed and installs them if necessary.
- Creates a WordPress site using the latest WordPress version, running on a LEMP stack inside Docker containers.
- Adds an entry to the `/etc/hosts` file to associate the site name with `localhost`.
- Prompts the user to open the site in a browser.
- Provides options to enable/disable the site (start/stop containers) and delete the site (remove containers and files).


