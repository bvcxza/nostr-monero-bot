#!/usr/bin/env bash

# Run monero-wallet-rpc
monero-wallet-rpc --stagenet --trusted-daemon --daemon-host 45.63.8.26 --wallet-file /nostr-monero-bot/wallet --password "" --rpc-bind-port 28088 --disable-rpc-login &

# Proof of Concept Bot

# bot private key (nsec)
bot_nsec=$(cat /nostr-monero-bot/nsec)
# bot write relays
bot_w_relays="nos.lol:443 nostr.mom:443 relay.monostr.com:443"
default_r_relays="$bot_w_relays relay.damus.io:443 relay.primal.net:433 xmr.usenostr.org:443"
#default_r_relays="$bot_w_relays"

bot_npub=$(sonos keypair $bot_nsec | head -n1)
echo "Bot npub: $bot_npub"
bot_pubkey=$(sonos convert $bot_npub npub)
script="/tmp/${bot_pubkey}_script.sh"
relays_stage="/tmp/${bot_pubkey}_relays_stage"


cat > $script << EOF0
event_id=\$(jq -r '.id' \$1)
pubkey=\$(jq -r '.pubkey' \$1)
npub=\$(sonos convert \$pubkey npub)
xmr_address=\$(jq -r '.content' \$1 | grep tip | sed -n -e 's/\(^\|\(.*\s\)\)#xmr\s\(.\+\)\(\(\s.*\)\|$\)/\3/pi')
[ -z \$xmr_address ] && exit 0

out_json=\$(curl -s -X POST http://127.0.0.1:28088/json_rpc -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer\",\"params\":{\"destinations\":[{\"amount\":0100000000000,\"address\":\"\$xmr_address\"}],\"get_tx_key\": true}}" -H "Content-Type: application/json")
[ -z "\$out_json" ] && exit 1
echo "\$out_json"
tx_key=\$(echo \$out_json | jq -r '.result.tx_key')
[ \$tx_key == "null" ] && exit 1

printf '%s\n' $bot_w_relays > $relays_stage
sonos relays read \$npub $default_r_relays >> $relays_stage
relays=\$(sort $relays_stage | uniq | xargs echo)
tags="[\"e\",\"\$event_id\",\"\",\"reply\"],[\"p\",\"\$pubkey\",\"\",\"mention\"]"
sonos event $bot_nsec 1 \$tags \$relays << EOF
Hi nostr:\$npub !!
I am Monero StageNet Faucet Bot using Sonos (https://github.com/bvcxza/nostr-monero-bot).
I transfered 0.1 XMR to \$xmr_address
tx_key: \$tx_key
Bye
EOF
EOF0

echo $script
echo $default_r_relays
sonos req "{\"kinds\":[1],\"#p\":[\"$bot_pubkey\"],\"limit\":0}" "bash $script" $default_r_relays

