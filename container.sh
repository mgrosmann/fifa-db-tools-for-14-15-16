#!/bin/bash
set -e  # Stoppe le script en cas d'erreur
echo "🚀 Mise à jour du système..."
apt update -y
apt install -y git openssh-server curl gpg lsb-release dos2unix
curl -fsSL https://mgrosmann.onrender.com/script/projet/docker.sh -o docker.sh
chmod +x docker.sh
bash docker.sh
echo "🧩 Installation de MariaDB client..."
apt install -y mariadb-client-compat
echo "🐬 Lancement du conteneur MySQL Docker (port 5000)..."
echo 'version: "3.9"

services:
  mysql:
    image: mysql:8
    container_name: fifa
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
    command: [
      "--local-infile=1",
      "--secure-file-priv="
    ]
    ports:
      - "5000:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - fifa-net

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: pma
    restart: always
    environment:
      PMA_HOST: fifa
      PMA_PORT: 3306
    ports:
      - "8080:80"
    networks:
      - fifa-net

volumes:
  mysql_data:

networks:
  fifa-net:
' > compose.yaml
docker compose up -d
echo "alias sql='mysql -u root -proot -h127.0.0.1 -P5000 -A'" >> ~/.bashrc
echo "alias sql14='mysql -u root -proot -h127.0.0.1 -DFIFA14 -P5000 -A'" >> ~/.bashrc
echo "alias sql15='mysql -u root -proot -h127.0.0.1 -DFIFA15 -P5000 -A'" >> ~/.bashrc
echo "alias sql16='mysql -u root -proot -h127.0.0.1 -DFIFA16 -P5000 -A'" >> ~/.bashrc
echo "alias sql18='mysql -u root -proot -h127.0.0.1 -DFIFA1518 -P5000 -A'" >> ~/.bashrc
echo "alias vide='>'" >> ~/.bashrc
echo "alias fifa='cd /mnt/c/github/fifa'" >> ~/.bashrc
echo "alias home='cd /mnt/c/Users/PC'" >> ~/.bashrc
echo "alias regen='source ~/.bashrc'" >> ~/.bashrc
echo "alias dump='mysqldump -uroot -proot -h127.0.0.1 -P5000'" >> ~/.bashrc
echo "penser à faire 'source ~/.bashrc'"
apt install python3.11-venv -y
apt install python3-full -y
python3 -m venv venv
apt install pip -y
pip install pandas datetime mysql.connector
echo faire " source venv/bin/activate"
