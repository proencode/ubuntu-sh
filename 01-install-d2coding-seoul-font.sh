#!/bin/sh

cBlack=$(tput bold)$(tput setaf 0); cRed=$(tput bold)$(tput setaf 1); cGreen=$(tput bold)$(tput setaf 2); cYellow=$(tput bold)$(tput setaf 3); cBlue=$(tput bold)$(tput setaf 4); cMagenta=$(tput bold)$(tput setaf 5); cCyan=$(tput bold)$(tput setaf 6); cWhite=$(tput bold)$(tput setaf 7); cReset=$(tput bold)$(tput sgr0); cUp=$(tput cuu 2)

cat_and_run () {
	echo "${cGreen}----> ${cYellow}$1 ${cCyan}$2${cReset}"; echo "$1" | sh
	echo "${cMagenta}<---- ${cBlue}$1 $2${cReset}"
}
CMD_NAME=`basename $0` # 명령줄에서 실행 프로그램 이름만 꺼냄
CMD_DIR=${0%/$CMD_NAME} # 실행 이름을 빼고 나머지 디렉토리만 담음
if [ "x$CMD_DIR" == "x" ] || [ "x$CMD_DIR" == "x$CMD_NAME" ]; then
	CMD_DIR="."
fi
MEMO="한글 폰트파일 설치"
echo "${cMagenta}>>>>>>>>>>${cGreen} $0 ${cMagenta}||| ${cCyan}${MEMO} ${cMagenta}>>>>>>>>>>${cReset}"
logs_folder="${HOME}/zz00-logs" ; if [ ! -d "${logs_folder}" ]; then cat_and_run "mkdir ${logs_folder}" ; fi
log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")__RUNNING_${CMD_NAME}" ; touch ${log_name}
# ----

if [ "x$1" = "x" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue} 프로그램 이름 다음에 ${cCyan}저장하기 위해 ${cYellow}/media/sf_Downloads/ 등 ${cBlue}폴더 이름을 지정해야 합니다.${cReset}"
	echo "----> ${cYellow}${0} [임시파일을 저장할 폴더이름]${cReset}"
	exit
fi
if [ ! -d "$1" ]; then
	echo "${cRed}!!!! ${cMagenta}----> ${cBlue} 저장하기 위한 ${cCyan}( ${cYellow}$1 ${cCyan})${cBlue} 폴더가 없습니다.${cReset}"
	echo "----> ${cYellow}${0} [임시파일을 저장할 폴더이름]${cReset}"
	exit
fi


echo "${cYellow}# ---> ${cGreen}(1) D2Coding 폰트 설치${cReset}"

TEMPfontDIR="$1/temp_fonts"
WGET="wget --no-check-certificate --content-disposition"

cat_and_run "rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "임시로 쓰는 폴더를 새로 만듭니다."

FONT_HOST="https://github.com/naver/d2codingfont/releases/download/VER1.3.2"
FONT_NAME="D2Coding-Ver1.3.2-20180524.zip"
FONT_DIR="/usr/share/fonts"
LOCAL_DIR="${FONT_DIR}/D2Coding"

cat_and_run "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "폰트 내려받기"
cat_and_run "sudo rm -rf ${LOCAL_DIR}*" "기존 폴더 삭제"
cat_and_run "cd ${TEMPfontDIR} ; 7za x ${FONT_NAME}" "폰트 압축해제"
cat_and_run "cd ${TEMPfontDIR} ; sudo chown -R root.root D2Coding ; sudo mv D2Coding ${FONT_DIR}/ ; sudo chmod 755 -R ${LOCAL_DIR} ; sudo chmod 644 ${LOCAL_DIR}/*" "폰트 설치"
cat_and_run "cd ${LOCAL_DIR} ; sudo mv D2Coding-Ver1.3.2-20180524.ttc D2Coding.ttc ; sudo mv D2Coding-Ver1.3.2-20180524.ttf D2Coding.ttf ; sudo mv D2CodingBold-Ver1.3.2-20180524.ttf D2CodingBold.ttf" "폰트 파일이름을 수정합니다."


echo "${cYellow}# ---> ${cGreen}(2) seoul 폰트 설치${cReset}"

cat_and_run "sudo rm -rf ${TEMPfontDIR} ; mkdir ${TEMPfontDIR}" "임시폴더 다시만들고,"

FONT_HOST="https://www.seoul.go.kr/upload/seoul/font"
FONT_NAME="seoul_font.zip" #-- 파일을 한글코드로 된 폴더에 담아서 압축했기 때문에, 풀면 fedora35 에서 깨진 글자로 나온다.
LOCAL_DIR="${FONT_DIR}/seoul"

cat_and_run "cd ${TEMPfontDIR} ; ${WGET} ${FONT_HOST}/${FONT_NAME}" "폰트 내려받기"
cat_and_run "sudo rm -rf ${LOCAL_DIR} ; sudo mkdir ${LOCAL_DIR}" "폴더 만들기"
cat_and_run "cd ${TEMPfontDIR} ; ls -l ; 7za x ${FONT_NAME}" "폰트 압축해제"
cat_and_run "cd ${TEMPfontDIR} ; sudo mv */Seoul*.ttf ${LOCAL_DIR}/ ; sudo chmod 644 ${LOCAL_DIR}/*" "폰트 설치"


echo "${cYellow}# ---> ${cGreen}(3) 폰트 설치 확인${cReset}"

cat_and_run "ls -ltr --color ${FONT_DIR}" "시간역순 font 디렉토리"
cat_and_run "ls --color ${FONT_DIR}/D2Coding*" "d2coding 설치 확인"
cat_and_run "ls --color ${FONT_DIR}/seoul*" "seoul 설치 확인"

cat_and_run "sudo rm -rf ${TEMPfontDIR}" "임시폴더 삭제"

# ----
rm -f ${log_name} ; log_name="${logs_folder}/zz.$(date +"%y%m%d-%H%M%S")..${CMD_NAME}" ; touch ${log_name}
cat_and_run "ls --color ${CMD_DIR}" ; ls --color ${logs_folder}
echo "${cRed}<<<<<<<<<<${cBlue} $0 ${cRed}||| ${cMagenta}${MEMO} ${cRed}<<<<<<<<<<${cReset}"
