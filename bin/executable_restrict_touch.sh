if [ "$1" = "" ]; then 
    exit 1
fi

ids=$(xinput --list | awk -v search="$1" \
    '$0 ~ search {match($0, /id=[0-9]+/);\
                  if (RSTART) \
                    print substr($0, RSTART+3, RLENGTH-3)\
                 }'\
     )

for i in $ids
do
    xinput map-to-output $i HDMI-A-0
done
