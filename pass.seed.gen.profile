#!/bin/bash

function passgen.seed(){
    local configfile=~/.password/default.conf
    if [ -e ${configfile} ]; then
        source ${configfile}
    else
        echo "${configfile}が見つかりません"
        return
    fi
    
    exdir=~/.password/seed
    #seedファイルが存在するか
    if [ ! -d $exdir ]; then
        mkdir seed
    fi

    seedarray=();

    echo -n "サービス名(ファイル名)を入力して下さい："
    read servicename
    seedarray+="SERVICE_NAME=\"${servicename}\"\n"

    echo -n "ユーザーIDを入力して下さい："
    read userid
    seedarray+="USER_ID=\"${userid}\"\n"

    # echo -n "ソルトを入力しますか？(n):"
    # read saltagree;
    if [ "${saltagree,,}" = "y" ]; then
        echo -n "ソルトを入力して下さい："
        read salt
    else
        now="`date`"
        salt="@`echo -n ${now} | openssl ${ALGORITHM} | sed -e "s/(stdin)= //"`"
    fi
    seedarray+="SALT=\"${salt}\"\n"

    echo -n "このパスワードのメモを入力して下さい："
    read memo
    seedarray+="MEMO=\"${memo}\"\n"

    exprresult=2
    length=0
    while [ ${exprresult} -ge 2 ] || [ ${length} -gt 32 ] || [ ${length} -lt 1 ]
    do
        echo -n "パスワードの長さを入力して下さい(最大32)："
        read length
        length=${length:-32}
        expr ${length} + 1 >&/dev/null
        exprresult=$?
        if [ ${exprresult} -eq 2 ]; then
            length=0
        fi
    done
    seedarray+="LENGTH=\"${length}\"\n"

    patternresult=2
    pattern=2
    while [ ${patternresult} -ge 2 ] || [ ${pattern} -gt 4 ] || [ ${pattern} -lt 1 ]
    do
        cat <<- EOL
		0:NO_GENERATE       パスワード生成しない
		1:PATTERN_NUMBER    数値のみ(非推奨)       10進数
		2:PATTERN_ALPHA     数値とアルファベット     62進数
		3:PATTERN_ASCII     数値とアルファベットと記号 94進数
		4:PATTERN_ALPHA_ADD 数値とアルファベットに加えADD_ASCIIの記号も追加
EOL
        echo -n "パスワードの生成パターンを選択して下さい(2):"
        read pattern
        pattern=${pattern:-2}
        expr ${pattern} + 1 >&/dev/null
        patternresult=$?
        if [ ${patternresult} -eq 2 ]; then
            pattern=0
        fi
    done
    patternarray=(
        "NO_GENERATE" \
        "PATTERN_NUMBER" \
        "PATTERN_ALPHA" \
        "PATTERN_ASCII" \
        "PATTERN_ALPHA_ADD" )

    seedarray+="PATTERN=\"${patternarray[pattern]}\"\n"

    if [ ${pattern} -eq 4 ]; then
        echo "4:PATTERN_ALPHA_ADDが選択されました"
        echo "ダブルクォーテーションを追加する場合は\\\"としてください"
        echo "追加で入れる記号を入力して下さい:"
        read addascii
    fi
    seedarray+="ADD_ASCII=\"${addascii}\"\n"

    hashresult=2
    hashloop=32
    while [ ${hashresult} -ge 2 ] || [ ${hashloop} -lt 1 ]
    do
        echo -n "ハッシュ化する回数を選択して下さい(${hashloop}):"
        read hashloop
        hashloop=${hashloop:-32}
        expr ${hashloop} + 1 >&/dev/null
        hashresult=$?
        if [ ${hashresult} -eq 2 ]; then
            hashloop=32
        fi
    done
    seedarray+="HASH_LOOP=\"${hashloop}\"\n"

    echo "入力された情報は以下の通りです"

    for l in ${seedarray[@]}
    do
        echo -e -n "${l}"
    done

    echo -n -e "以上の内容で作成します\nよろしければy:"
    read agree

    if [ "${agree,,}" != "y" ]; then
        return ;
    fi

    exseed=$exdir/${servicename}.txt
    if [ -f ${exseed} ]; then
        echo "ファイルが既に存在するためバックアップします。";
        if [ ! -d seedbak ]; then
            mkdir seedbak
        fi
        mv ${exseed} seedbak/`date "+%Y%m%d-%H%M%S"`_${servicename}.txt
    fi
    for l in "${seedarray[@]}"
    do
        echo -e ${l} >> $exseed
    done

    echo "seedファイルの生成が完了しました"
    echo  -n "passwordを生成しますか？:"
    read passagree
    if [ "${passagree,,}" == "y" ]; then
        passgen
    fi
}
