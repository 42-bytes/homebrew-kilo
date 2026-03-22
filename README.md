# Homebrew Tap for Kilo Remote

This is the official Homebrew tap for [Kilo Remote](https://kilo.42bytes.eu).

## Install

```bash
brew tap 42bytes/kilo
brew install kilo-remote-daemon
```

## Usage

1. Configure the daemon:

```bash
# Create config directory
mkdir -p /opt/homebrew/var/kilo-remote

# Edit configuration
nano /opt/homebrew/etc/kilo-remote-daemon.env
```

2. Pair with your iPhone:

```bash
kiloremote pair
```

3. Start as a background service:

```bash
brew services start 42bytes/kilo/kilo-remote-daemon
```

## Uninstall

```bash
brew services stop 42bytes/kilo/kilo-remote-daemon
brew uninstall kilo-remote-daemon
brew untap 42bytes/kilo
```
