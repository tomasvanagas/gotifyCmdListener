#!/bin/bash


SERVER="http://ip_address:port"
USER_TOKEN="client token"
APP_TOKEN="application token"


ServerName="Ubuntu server"

curl -s --include --no-buffer --header "Sec-WebSocket-Key: x" --header "Connection: Upgrade" --header "Upgrade: websocket" --header "Sec-WebSocket-Version: 13" $SERVER/stream?token=$USER_TOKEN | while read in; 
do
	#echo "$in" # \x0a\x81\x6e
	json=$(echo "$in" | cut -b3-10000 | grep "message");
	echo "$json"
	if [ "$json" != "" ];
	then
		message=$(echo $json | jq -r ".message");
		title=$(echo $json | jq -r ".title");
		if [ "$title" == "cmd" ];
		then
			echo "Message: $message"
			resp=$(echo "$message" | bash)
			echo "$resp"
			curl "$SERVER/message?token=$APP_TOKEN" -F "title=$ServerName" -F "message=$resp" -F "priority=5"
		fi;
	fi;
done
