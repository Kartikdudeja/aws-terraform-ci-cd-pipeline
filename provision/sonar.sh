#!/bin/bash

# Description: Install & Setup Sonarqube on Debain based OS

logger(){

    # variables
    LOG_FILE_PATH=/tmp
    LOG_FILE_NAME=script.log

    if [ $# -eq 2 ]
    then
        SEVERITY="$1"
        LOG_MESSAGE="$2"
    elif [ $# -eq 1 ]
    then
        SEVERITY="INFO"
        LOG_MESSAGE="$1"
    else
        SEVERITY="EXCEPTION"
        LOG_MESSAGE="Wrong Sytax used for logger function. Usage: logger <SEVERITY> <LOG_MESSAGE>"
    fi
    
    echo -e "$(date '+%Y-%m-%d %T') $SEVERITY: $LOG_MESSAGE" >> $LOG_FILE_PATH/$LOG_FILE_NAME

}

logger "$0 Started"

logger "changing sysctl parameter"

cp /etc/sysctl.conf /root/sysctl.conf_backup

cat << EOT > /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

cp /etc/security/limits.conf /root/sec_limit.conf_backup

cat << EOT > /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    409
EOT

logger "Installing Java"
sudo apt-get update -y
sudo apt-get install openjdk-11-jdk -y
sudo update-alternatives --config java

logger "Installing PostgreSQL"
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt install postgresql postgresql-contrib -y

logger "Starting & Enabling Postgres"
sudo systemctl enable postgresql.service
sudo systemctl start  postgresql.service

logger "Configuring PostreSQL for Sonarqube"
sudo echo "postgres:admin123" | chpasswd
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

systemctl restart  postgresql

logger "Installing Sonarqube"
sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/

logger "Configuring Sonarqube"
sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

cat << EOT > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

logger "Deamonizing Sonarqube Service"
cat << EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube.service

logger "Intalling & Configuring Nginx"
apt-get install nginx -y

rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default

cat << EOT > /etc/nginx/sites-available/sonarqube
server{
    listen      80;
    server_name sonarqube.groophy.in;
    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx.service

logger "Allowing Traffic over UFW"
sudo ufw allow 80,9000,9001/tcp

logger "System will reboot in 30 seconds"
logger "$0 Completed"

sleep 30
reboot
