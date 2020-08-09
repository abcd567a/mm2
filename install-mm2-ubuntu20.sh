#!/bin/bash

INSTALL_FOLDER=/usr/share/mm2

echo "Creating folder mm2"
sudo mkdir ${INSTALL_FOLDER}
echo "Downloading modeSMixer2 file from Google Drive"
sudo wget -O ${INSTALL_FOLDER}/modesmixer2_ubuntu_20.04_x86_64_20200714.tgz "https://drive.google.com/uc?export=download&id=1BH7zPxzk7qTMhhGOD6KPHMnM7qRf4_Dc" 

echo "Unzipping downloaded file"
sudo tar xvzf ${INSTALL_FOLDER}/modesmixer2_ubuntu_20.04_x86_64_20200714.tgz -C ${INSTALL_FOLDER}

echo "Creating symlink to modesmixer2 binary in folder /usr/bin/ "
sudo ln -s ${INSTALL_FOLDER}/modesmixer2 /usr/bin/modesmixer2

echo "Creating startup script file mm2.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/mm2.sh
sudo touch ${SCRIPT_FILE}
sudo chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file mm2.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/mm2.conf
${INSTALL_FOLDER}/modesmixer2 \${CONFIG}
EOM
sudo chmod +x ${SCRIPT_FILE}

echo "Creating config file mm2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/mm2.conf
sudo touch ${CONFIG_FILE}
sudo chmod 777 ${CONFIG_FILE}
echo "Writing code to config file mm2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--inConnectId 127.0.0.1:30005:ADSB
--inConnectId 127.0.0.1:30105:MLAT
--web 8787
EOM
sudo chmod 644 ${CONFIG_FILE}

echo "Creating Service file mm2.service"
SERVICE_FILE=/lib/systemd/system/mm2.service
sudo touch ${SERVICE_FILE}
sudo chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# modesmixer2 service for systemd
[Unit]
Description=ModeSMixer2
Wants=network.target
After=network.target
[Service]
RuntimeDirectory=modesmixer2
RuntimeDirectoryMode=0755
ExecStart=/bin/bash ${INSTALL_FOLDER}/mm2.sh
SyslogIdentifier=modesmixer2
Type=simple
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=64
Nice=-5
[Install]
WantedBy=default.target

EOM

sudo chmod 644 ${SERVICE_FILE}
sudo systemctl enable mm2
sudo systemctl restart mm2

echo " "
echo " "
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mPLEASE DO FOLLOWING:\e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8787 \e[39m"
echo " "
echo -e "\e[33m(2) Open file mm2.conf by following command:\e[39m"
echo -e "\e[39m     sudo nano "${INSTALL_FOLDER}"/mm2.conf \e[39m"
echo ""
echo -e "\e[33mAdd following line:\e[39m"
echo -e "\e[39m     --location xx.xxxx:yy.yyyy \e[39m"
echo ""
echo -e "\e[33m(Replace xx.xxxx and yy.yyyy \e[39m"
echo -e "\e[33mby your actual latitude and longitude) \e[39m"
echo -e "\e[33mSave (Ctrl+o) and Close (Ctrl+x) file mm2.conf \e[39m"
echo ""
echo -e "\e[33mthen restart mm2 by following command:\e[39m"
echo -e "\e[39m     sudo systemctl restart mm2 \e[39m"
echo " "

echo -e "\e[32mTo see status\e[39m sudo systemctl status mm2"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart mm2"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop mm2"


