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
        local file_name=`basename ${file} .txt`
        echo ${file_name}
        #passフォルダにseedフォルダと同じファイルがない場合は生成
        if [ ! -e ~/.password/pass/${file_name}.txt ]; then
            #seed設定を読み込み
            source $file
            #パスワードパターン選択
            local NO_GENERATE=false
            case "$PATTERN" in
                "PATTERN_NUMBER"     ) local PATTERN_STR=$PATTERN_NUMBER ;;
                "PATTERN_ALPHA"      ) local PATTERN_STR=$PATTERN_ALPHA  ;;
                "PATTERN_ALPHA_ADD"  ) local PATTERN_STR=$PATTERN_ALPHA_ADD  ;;
                "PATTERN_ASCII"      ) local PATTERN_STR=$PATTERN_ASCII  ;;
                "USER"               ) local PATTERN_STR=$PATTERN_USER   ;;
                *                    ) local NO_GENERATE=true           ;;
            esac

            if ! "$NO_GENERATE"; then
                #ハッシュ生成
                local sha=`echo -n ${USER_ID}${SALT}`
                for (( i=1; i <= ${HASH_LOOP}; i++ )); do
                    sha=`echo -n ${sha} | openssl ${ALGORITHM} | sed -e "s/(stdin)= //"`
                    echo "${i}回目のハッシュ化結果:${sha}"
                done
                local passwordstr=""
                for (( i=0; i < ${#sha}; i+=2 )); do
                    local hextodec=`printf "%d" 0x${sha:i:2}`
                    local ascii=$((${hextodec} % ${#PATTERN_STR}))
                    local passwordstr=${passwordstr}${PATTERN_STR:${ascii}:1}
                done
                local PASS_WORD=${passwordstr:0:${LENGTH}}
            fi
            #echo "password:${PASS_WORD}"
            #passフォルダにファイル生成
            local funcfile=~/.password/pass/${file_name}.profile
            local infofile=~/.password/pass/${file_name}.txt
            
            local passinfotxt="\"${SERVICE_NAME}\"\t${USER_ID}\t${PASS_WORD}\t\"${MEMO}\""
            #echo "password:${passinfotxt}"
            echo -e ${passinfotxt} >> $infofile

            cat << EOF > $funcfile
#!/bin/bash
pass.${file_name}(){
	passinfoshow ${file_name}.txt \$*
}
EOF

        fi
    done
    source ~/.password/loadprofile.sh
}