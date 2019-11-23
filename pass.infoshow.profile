#!/bin/bash
shopt -s expand_aliases
passinfoshow(){
	local array=(`cat ~/.password/pass/$1`)
	if [ $# -gt 1  ]; then
		case "$2" in
			"ALL" 	  ) 
				echo "SERVICE: ${array[0]}"
				echo "ID     : ${array[1]}"
				echo "PASS   : ${array[2]}"
				echo "MEMO   : ${array[3]}"
			;;
			"SERVICE" ) echo "SERVICE:${array[0]}" ;;
			"ID"  	  ) 
				echo "ID     : ${array[1]}" 
				echo -E ${array[1]} | clip.exe && echo "IDをクリップボードにコピーしました"
				;;
			"PASS"    ) echo "PASS   : ${array[2]}" ;;
			"SHOW"    ) echo          "${array[2]}" ;;
			"MEMO"    ) echo "MEMO   : ${array[3]}" ;;
			"-h" )
				echo "SERVICE: サービス名を出力"
				echo "ID     : IDを出力"
				echo "PASS   : パスワードを出力"
				echo "SHOW   : パスワードのみ出力"
				echo "MEMO   : 備考を出力"
				echo "引数なし : パスワードをコピー"
			;;
			* ) echo "-hでヘルプを表示できます" ;;
		esac
	else
		#linuxの場合はxselなどに書き換えて下さい。
		echo -E ${array[2]} | clip.exe && echo "パスワードをクリップボードにコピーしました"
	fi
}