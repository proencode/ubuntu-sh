#!/bin/sh

cBlack=$(tput bold)$(tput setaf 0); cRed=$(tput bold)$(tput setaf 1); cGreen=$(tput bold)$(tput setaf 2); cYellow=$(tput bold)$(tput setaf 3); cBlue=$(tput bold)$(tput setaf 4); cMagenta=$(tput bold)$(tput setaf 5); cCyan=$(tput bold)$(tput setaf 6); cWhite=$(tput bold)$(tput setaf 7); cReset=$(tput bold)$(tput sgr0); cUp=$(tput cuu 2)

cat_and_run () {
	echo "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cReset}"; echo "$1" | sh
	echo "${cMagenta}<---- ${cBlue}$1 $2${cReset}"
}
cat_and_read () {
	echo -e "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cGreen}\n----> ${cCyan}press Enter${cReset}:"
	read a ; echo "${cUp}"; echo "$1" | sh
	echo "${cMagenta}<---- ${cBlue}press Enter${cReset}: ${cMagenta}$1 $2${cReset}"
}
cat_and_readY () {
	echo "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cReset}"
	if [ "x${ALL_INSTALL}" = "xy" ]; then
		echo "$1" | sh ; echo "${cMagenta}<---- ${cBlue}$1 $2${cReset}"
	else
		echo "${cGreen}----> ${cRed}press ${cCyan}y${cRed} or Enter${cReset}:"; read a; echo "${cUp}"
		if [ "x$a" = "xy" ]; then
			echo "${cRed}-OK-${cReset}"; echo "$1" | sh
		else
			echo "${cRed}[ ${cYellow}$1 ${cRed}] ${cCyan}<--- 명령을 실행하지 않습니다.${cReset}"
		fi
		echo "${cMagenta}<---- ${cBlue}press Enter${cReset}: ${cMagenta}$1 $2${cReset}"
	fi
}
CMD_NAME=`basename $0` # 명령줄에서 실행 프로그램 이름만 꺼냄
CMD_DIR=${0%/$CMD_NAME} # 실행 이름을 빼고 나머지 디렉토리만 담음
if [ "x$CMD_DIR" == "x" ] || [ "x$CMD_DIR" == "x$CMD_NAME" ]; then
	CMD_DIR="."
fi
MEMO="docker-compose wiki.js 설치"
cat <<__EOF__
${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}
출처: https://computingforgeeks.com/install-and-use-docker-compose-on-fedora/
__EOF__
logs_folder="${HOME}/zz00logs" ; if [ ! -d "${logs_folder}" ]; then cat_and_run "mkdir ${logs_folder}" ; fi
log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${log_name}
# ----

port_no="5800"

DB_FOLDER=/home/docker/pgsql
if [ ! -d ${DB_FOLDER} ]; then
	echo "----> ${cGreen}sudo mkdir -p ${DB_FOLDER}${cReset}"
	sudo mkdir -p ${DB_FOLDER}
	cat_and_run "#-- ubuntu 에서는 쓰지 않음. sudo chcon -R system_u:object_r:container_file_t:s0 ${DB_FOLDER}"
	cat_and_run "#-- ubuntu 에서는 쓰지 않음. sudo chown -R systemd-coredump.ssh_keys ${DB_FOLDER}"
	cat_and_run "ls -lZ ${DB_FOLDER}" "폴더를 만들었습니다."
else
	echo "${cRed}!!!!${cMagenta} ----> ${cCyan}${DB_FOLDER}${cReset} 디렉토리가 있으므로, 진행을 중단합니다."
	exit 1
fi

wiki_dir=/home/docker/wiki.js
if [ ! -d ${wiki_dir} ]; then
	sudo mkdir -p ${wiki_dir}
	sudo chown ${USER}.${USER} ${wiki_dir}
fi
cd ${wiki_dir}

cat > docker-compose.yml <<__EOF__
version: "3"
services:

  db:
    image: postgres:11-alpine
    environment:
      POSTGRES_DB: wiki
      POSTGRES_PASSWORD: wikijsrocks
      POSTGRES_USER: wikijs
    logging:
      driver: "none"
    restart: unless-stopped
    volumes:
      - ${DB_FOLDER}:/var/lib/postgresql/data
    container_name:
      wikijsdb

  wiki:
    image: requarks/wiki:2
    depends_on:
      - db
    environment:
      DB_TYPE: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: wikijs
      DB_PASS: wikijsrocks
      DB_NAME: wiki
    restart: unless-stopped
    ports:
      - "${port_no}:3000"
    container_name:
      wikijs
__EOF__

cat <<__EOF__
+---+
| 1 | Docker ---- https://ichi.pro/ko/2-bu-raspberry-pi-4e-docker-seolchi-166053448590998 ----
+---+
__EOF__

cat_and_run "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common"
cat_and_run "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
cat_and_run "sudo apt-key fingerprint 0EBFCD88"
cat_and_run "sudo add-apt-repository \"deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
cat_and_run "sudo apt-get update"
cat_and_run "apt-cache policy docker-ce"
cat_and_run "sudo apt-get -y install docker-ce"
cat_and_run "sudo usermod -aG docker ${USER}"

cat <<__EOF__
+---+
| 2 | Docker-compose
+---+
__EOF__
cat_and_run "sudo apt -y install python3-pip"
cat_and_run "sudo pip3 install docker-compose"
#-- cat_and_run "git clone https://github.com/therobotacademy/docker-compose-hello-world"
#-- cat_and_run "cd docker-compose-hello-world"
cat_and_run "docker-compose up -d"
cat_and_run "docker-compose ps"

cat_and_run "ifconfig | grep enp -A1 ; ifconfig | grep wlp -A1" "(2-2) ip 를 확인합니다."
cat_and_run "ifconfig | grep enp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(2-3) ethernet"
cat_and_run "ifconfig | grep wlp -A1 | tail -1 | awk '{print \$2\":${port_no}\"}'" "(2-4) wifi"
cat_and_run "sudo docker-compose up --force-recreate &" "(2-5)"
cat_and_run "sudo docker-compose ps -a" "(2-6) 모든 작업을 확인합니다."

cd -

# ----
rm -f ${log_name} ; log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")..${CMD_NAME}" ; touch ${log_name}
cat_and_run "ls --color ${CMD_DIR}" ; ls --color ${logs_folder}
echo "${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}"

cat  <<__EOF__
${cCyan}#--- 출처: https://wiki.js.org/
${cRed}+----------------+${cReset}
${cRed}|                |${cReset}
${cRed}| ${cReset}localhost:${port_no} ${cRed}| ${cGreen}#--- 위키서버가 실행되면 브라우저에서 이와같이 입력합니다.
${cRed}|                |${cReset}
${cRed}+----------------+${cReset}
${cCyan}cd ${wiki_dir} ; sudo docker-compose down #--- 작업을 중단할때, 입력합니다. ${cReset}
__EOF__
