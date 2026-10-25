# Monero Stagenet Faucet Bot using Sonos

Proof of Concept Monero Stagenet Faucet Bot using [Sonos](https://github.com/bvcxza/sonos). Proposed in [Documentation or tooling for nostr wallet bot setup](https://bounties.monero.social/posts/163/4-029m-documentation-or-tooling-for-nostr-wallet-bot-setup).

## Prerequisite

This project uses [Nix](https://nixos.org) as dependency manager. Follow [instructions](https://nixos.org/download) to install it.

## Create Nostr KeyPair and Monero Wallet

```
# create env
nix-shell -p podman monero-cli
# create and protecte dir
mkdir -p ~/.local/share/nostr-monero-bot
chmod go-rwx -R ~/.local/share/nostr-monero-bot
# generate nostr key pair
nix run 'git+https://github.com/bvcxza/sonos?submodules=1' --extra-experimental-features nix-command --extra-experimental-features flakes -- keypair | grep nsec1 > ~/.local/share/nostr-monero-bot/nsec
# generate monero stagenet wallet
monero-wallet-cli --stagenet --trusted-daemon --daemon-host 45.63.8.26 --generate-new-wallet ~/.local/share/nostr-monero-bot/wallet
# show wallet address
cat ~/.local/share/nostr-monero-bot/wallet.address.txt
```

## Build and run container image

```
podman build .
podman run -d --name nostr-monero-bot --replace -v ~/.local/share/nostr-monero-bot/:/nostr-monero-bot <image id>
```

## Podman command utils

```
podman container list
podman container logs -f nostr-monero-bot
podman container logs nostr-monero-bot | grep "Bot npub"
podman container kill nostr-monero-bot
```

## Fund bot wallet

- https://cypherfaucet.com/xmr-stagenet
- https://stagenet-faucet.xmr-tw.org

Or try my bot instance, if it is running, posting this text note on nostr:

```
hi nostr:npub16qj8ud2yl9dc3854k29duj3c2y9phnlmvh6rpav33fhzxlrz5cwswlerec

tip #xmr <xmr address 5.../7...>
```

## References

- https://docs.podman.io/en/latest/markdown/podman-image-trust.1.html
- https://hub.docker.com/r/nixos/nix
- https://docs.docker.com/reference/dockerfile/

