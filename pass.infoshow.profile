#!/bin/bash
shopt -s expand_aliases
passinfoshow(){
	local array=(`cat ~/.password/pass/$1`)
	if [ $# -gt 1  ]; then
		case "${2,,}" in
			"all" 	  ) 
				echo "service: ${array[0]}"
				echo "id     : ${array[1]}"
				echo "pass   : ${array[2]}"
				echo "memo   : ${array[3]}"
			;;
			"service" ) echo "service:${array[0]}" ;;
			"id"  	  ) 
				echo "id     : ${array[1]}" 
				echo -e -n ${array[1]} | clip.exe && echo "idをクリップボードにコピーしました"
				;;
			"pass"    ) echo "pass   : ${array[2]}" ;;
			"show"    ) echo          "${array[2]}" ;;
			"memo"    ) echo "memo   : ${array[3]}" ;;
			"-h" )
				echo "service: サービス名を出力"
				echo "id     : IDを出力"
				echo "pass   : パスワードを出力"
				echo "show   : パスワードのみ出力"
				echo "memo   : 備考を出力"
				echo "引数なし : パスワードをコピー"
			;;
			* ) echo "-hでヘルプを表示できます" ;;
		esac
	else
		#linuxの場合はxselなどに書き換えて下さい。
		echo -e -n ${array[2]} | clip.exe && echo "パスワードをクリップボードにコピーしました"
	fi
}