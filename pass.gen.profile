#!/bin/bash

function pass.gen(){
    local configfile=~/.password/default.conf
    if [ -e ${configfile} ]; then
        source ${configfile}
    else
        echo "${configfile}が見つかりません"
        return
    fi

    #seedフォルダのファイルを１つずつ読む
    local basedir=~/.password/seed
    for file in `find ${basedir} -follow -type f -name '*.txt'`; do
        file_name=`basename ${file} .txt`
        echo ${file_name}
        #passフォルダにseedフォルダと同じファイルがない場合は生成
        if [ ! -e ~/.password/pass/${file_name}.txt ]; then
            #seed設定を読み込み
            source $file
            #ハッシュ生成
            local sha=`echo -n ${USER_ID}${SALT}`
            for (( i=1; i <= ${HASH_LOOP}; i++ )); do
                sha=`echo -n ${sha} | openssl ${ALGORITHM} | sed -e "s/(stdin)= //"`
                echo "${i}回目のハッシュ化結果:${sha}"
            done
            #ハッシュをパスワードに変換
            case "$PATTERN" in
                "PATTERN_NUMBER"     ) local PATTERN_STR=$PATTERN_NUMBER ;;
                "PATTERN_ALPHA"      ) local PATTERN_STR=$PATTERN_ALPHA  ;;
                "PATTERN_ALPHA_ADD"  ) local PATTERN_STR=$ADD_ASCII$PATTERN_ALPHA  ;;
                "PATTERN_ASCII"      ) local PATTERN_STR=$PATTERN_ASCII  ;;
                "USER"               ) local PATTERN_STR=$PATTERN_USER   ;;
            esac
            local passwordstr=""
            for (( i=0; i < ${#sha}; i+=2 )); do
                hextodec=`printf "%d" 0x${sha:i:2}`
                ascii=$((${hextodec} % ${#PATTERN_STR}))
                passwordstr=${passwordstr}${PATTERN_STR:${ascii}:1}
            done
            PASS_WORD=${passwordstr:0:${LENGTH}}
            #echo "password:${PASS_WORD}"
            #passフォルダにファイル生成
            passfile=~/.password/pass/${file_name}.profile
            infofile=~/.password/pass/${file_name}.txt
            cp ~/.password/pass.temp $passfile

            sedstr="\"${SERVICE_NAME}\"\t${USER_ID}\t${PASS_WORD}\t\"${MEMO}\""
            #echo "password:${sedstr}"
            sed -i -e "s/func_name/${file_name}/" $passfile
            echo -e ${sedstr} >> $infofile
        fi
    done
    source ~/.password/loadprofile.sh
}