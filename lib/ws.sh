# Full rewrite



until read line; line=`tr -d '\r\n'<<<$line`; test -z "$line"; do
   test "${line:0:18}" = "Sec-WebSocket-Key:" && key=${line:19}
   test "${line:0:22}" = "Sec-WebSocket-Version:" && ver=$line
done <&0

rkey=`echo -n ${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11|openssl dgst -sha1 -binary|base64`
echo -ne "HTTP/1.1 101 Switching Protocols\r\n"
echo -ne "Upgrade: websocket\r\nConnection: Upgrade\r\n"
echo -ne "Sec-WebSocket-Accept: $rkey\r\n$ver\r\n\r\n"

doasync() {
   echo "$1" | while read line; do
       while [ "${#line}" -gt 0 ]; do
           l2=${line:0:80}
           len=`echo -n "$l2" | wc -c | tr -d ' '`
           echo -ne "\x81\x`printf '%02x' $len`$l2"
           line=${line:80}
       done
   done &
}

while true; do
   reclen=$(od -j 1 -N 1 -t dI -A n <&0 | tr -d '\ \r\n')
   reclen=$(($reclen - 128))
   [ "$reclen" = "-128" ] && break
   for i in `seq 0 3`; do
       mk[$i]=`od -N 1 -t dI -A n <&0`
   done
   msg=""
   for i in `seq 0 $(($reclen - 1))`; do
       bt=`od -N 1 -t dI -A n <&0`
       bt=$(($bt ^ ${mk[$(($i % 4))]}))
       msg="$msg$(echo -e "\x`printf '%02x' $bt`")"
   done
   (>&2 echo $msg)
   test "$msg" = "vehbo" && doasync "I love Dicks"
   test "$msg" = "lav" && doasync "I love Chicks"
   test "$msg" = "exit" && break
done
echo >&1-
socat TCP4-LISTEN:2048,fork SYSTEM:./ws.sh
