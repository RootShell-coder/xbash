# XBASH test container

[![xbash](https://github.com/RootShell-coder/xbash/actions/workflows/xbash.yml/badge.svg)](https://github.com/RootShell-coder/xbash/actions/workflows/xbash.yml)[![xbash](https://github.com/RootShell-coder/xbash/actions/workflows/xbash.yml/badge.svg?event=schedule)](https://github.com/RootShell-coder/xbash/actions/workflows/xbash.yml)

```bash
docker run --rm -ti ghcr.io/rootshell-coder/xbash bash
```

or

```bash
docker run --rm -ti --network ${net-name} -v ${volume_name}:/home/xbash ghcr.io/rootshell-coder/xbash bash
```

Installed packages available `jq`, `git`, `curl`, `openssh-client`, `tree`, `rsync`, `nmap`, `bind-tools`, `ca-certificates`
