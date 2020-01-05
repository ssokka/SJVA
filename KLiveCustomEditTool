#!/bin/bash
# UTF-8 / LF

echo

title="SJVA >> KLive >> Custom 편집"

# 변수
dbFile=${1}
dbTable=plugin_klive_custom
chName=${2}
chNumber=${3}
chGroup=${4}

# 함수 - 색깔 문자
Color() {
	case ${1} in
		b) num=34;; #blue
		r) num=31;; #red
		y) num=33;; #yellow
		*) num=39;; #white
	esac
	echo "\e[${num}m${2}\e[0m"
}

# 함수 - 현재 라인 삭제
ClearLine() {
	echo -en "\r\033[K"
}

# 함수 - 종료
Exit() {
	echo
	exit
}

# 함수 - 파일 확인
CheckFile() {
	if [ ! -f "${1}" ]; then
		echo -e $(Color r "[오류] ${1} 파일이 존재하지 않습니다.")
		Exit
	fi
}

# 함수 - 패키지 설치 및 확인
Install() {
	if [ ! -f "${1}" ]; then
		name=$(basename ${1})
		echo "[설치] ${name}"
		sudo apt-get -y install ${name}
		echo
		CheckFile "${1}"
	fi
}

# 도움말
if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] || [ ${#} != 4 ]; then
	echo -e $(Color y "[사용] bash ${0} \"SJVA DB 파일 경로\" \"채널\" \"번호\" \"그룹\"")
	echo -e $(Color y "[예시] bash ${0} \"/opt/sjva/db/sjva.db\" \"EBS\" \"3\" \"지상파\"")
	Exit
fi

# DB 파일 확인
CheckFile "${dbFile}"

# sqlite3 설치 및 확인
sql="/usr/bin/sqlite3"
Install "${sql}"

# uni2ascii 설치 및 확인
Install "/usr/bin/uni2ascii"

# 채널 이름 확인
str="${title} >> Name = ${chName}"
echo -n "[확인중] ${str}"
query=$(${sql} "${dbFile}" "select * from ${dbTable} where title = '${chName}';")
ClearLine
if [ "${query}" == "" ]; then
	echo -e $(Color r "[오류] ${str} 채널이 존재하지 않습니다.")
	Exit
fi

# 채널 그룹 to HEX
hex="$(echo ${chGroup} | uni2ascii -a U -qsl)"

# DB 적용
str="${str} | Number = ${chNumber} | Group = ${chGroup}"
echo -n "[적용중] ${str}"
query=$(${sql} "${dbFile}" "update ${dbTable} set json = '{\"group\": \"$hex\", \"group2\": \"$hex\"}', number = '${chNumber}' where title = '${chName}';")
ClearLine
if [ "${query}" == "" ]; then
	echo -e $(Color b "[적용] ${str}")
else
	echo -e $(Color r "[실패] ${str}")
	echo -e $(Color r "[오류] ${query}")
fi

Exit
