
https://docs.podman.io/en/latest/markdown/podman-image-trust.1.html
~/.config/containers/registries.conf

https://hub.docker.com/r/nixos/nix
https://docs.docker.com/reference/dockerfile/

nix-shell -p podman monero-cli

mkdir -p ~/.local/share/nostr-monero-bot
chmod go-rwx -R ~/.local/share/nostr-monero-bot
nix run 'git+https://github.com/bvcxza/sonos?submodules=1' --extra-experimental-features nix-command --extra-experimental-features flakes -- keypair | grep nsec1 > ~/.local/share/nostr-monero-bot/nsec
monero-wallet-cli --stagenet --trusted-daemon --daemon-host 45.63.8.26 --generate-new-wallet ~/.local/share/nostr-monero-bot/wallet

podman build .
podman run -d --name nostr-monero-bot --replace -v ~/.local/share/nostr-monero-bot/:/nostr-monero-bot 2b1cb2b16
podman container list
podman container logs -f nostr-monero-bot
podman container kill nostr-monero-bot
