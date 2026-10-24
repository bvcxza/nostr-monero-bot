FROM nixos/nix

RUN nix-channel --update
RUN echo "extra-experimental-features = flakes nix-command" >> /etc/nix/nix.conf
RUN nix profile add nixpkgs\#monero-cli nixpkgs\#jq 'git+https://github.com/bvcxza/sonos?submodules=1'
#RUN nix profile add 'git+https://github.com/bvcxza/sonos?submodules=1'
COPY run.sh ./
CMD ["./run.sh"]
