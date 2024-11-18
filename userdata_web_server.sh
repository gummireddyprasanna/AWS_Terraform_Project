#!/bin/bash
# Update the package list
sudo apt-get update -y

# Install Apache web server
sudo apt-get install -y apache2

# Create a simple HTML file
echo "<html><body><h1>Hello Cloud from Cristian</h1></body></html>" | sudo tee /var/www/html/index.html

# Ensure Apache is enabled and running
sudo systemctl enable apache2
sudo systemctl start apache2
