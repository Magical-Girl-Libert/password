#!/bin/bash
shopt -s expand_aliases
passinfo.get(){
	IFS="$(echo -e '\t' )"
	local array=(`cat ~/.password/pass/$1`)
	unset IFS
	if [ $# -gt 1  ]; then
		case "${2,,}" in
			"all" 	  ) 
				echo "service   : ${array[0]}"
				echo "id        : ${array[1]}"
				echo "pass      : ${array[2]}"
				echo "memo      : ${array[3]}"
				echo "generated : ${array[4]:-nodata}"
			;;
			"service" ) echo "service:${array[0]}" ;;
			"id"  	  ) 
				echo "id     : ${array[1]}" 
				echo -e -n ${array[1]} | clip.exe && echo "idをクリップボードにコピーしました"
				;;
			"pass"    ) echo "pass   : ${array[2]}" ;;
			"show"    ) echo          "${array[2]}" ;;
			"memo"    ) echo "memo   : ${array[3]}" ;;
			"gen"     ) echo "generated : ${array[4]:-nodata}" ;;
			"regen"   )
				local BACKUP_PATH=~/".password/backup"
				mkdir -p ${BACKUP_PATH}"/pass/"
				mv ~/".password/pass/$1" ${BACKUP_PATH}"/pass/$1_`date "+%Y%m%d-%H%M%S"`.txt"
				passgen
			;;
			"del"     )
				local BACKUP_PATH=~/".password/backup"
				mkdir -p ${BACKUP_PATH}"/pass/"
				mv ~/".password/pass/$1" ${BACKUP_PATH}"/pass/$1_`date "+%Y%m%d-%H%M%S"`.txt"
				mkdir -p ${BACKUP_PATH}"/seed/"
				mv ~/".password/seed/$1" ${BACKUP_PATH}"/seed/$1_`date "+%Y%m%d-%H%M%S"`.txt"
				service_name=`echo ${array[0]} | sed 's/"//g'` 
				rm ~/".password/pass/${service_name}.profile"
				unset -f pass.$service_name
				echo "deleted $service_name"
			;;
			"-h" )
				echo "引数なし : パスワードをコピー"
				echo "service: サービス名を出力"
				echo "id     : IDを出力"
				echo "pass   : パスワードを出力"
				echo "show   : パスワードのみ出力"
				echo "memo   : 備考を出力"
				echo "gen    : 生成日時を出力"
				echo "regen  : seedファイルからパスワードを再生成します(backupあり)"
				echo "del    : 生成したseedとパスワードtxtを削除(backup)"
			;;
			* ) echo "-hでヘルプを表示できます" ;;
		esac
	else
		#linuxの場合はxselなどに書き換えて下さい。
		echo -e -n ${array[2]} | clip.exe && echo "パスワードをクリップボードにコピーしました"
	fi
}
