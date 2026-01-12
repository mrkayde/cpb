echo "Removing old MongoDB repos (if any)"
sudo rm -f /etc/apt/sources.list.d/mongodb-org-*.list

echo "Adding MongoDB 4.4 repo for Ubuntu 20.04 (focal) on Ubuntu 22.04"
curl -fsSL https://pgp.mongodb.com/server-4.4.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-4.4.gpg

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

echo "Updating apt package lists"
sudo apt-get update

echo "Installing MongoDB 4.4"
sudo apt-get install -y mongodb-org=4.4.18 mongodb-org-server=4.4.18 mongodb-org-shell=4.4.18 mongodb-org-mongos=4.4.18 mongodb-org-tools=4.4.18
