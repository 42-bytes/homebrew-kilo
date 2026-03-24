class KiloRemoteDaemon < Formula
  desc "macOS daemon for Kilo Remote - control Kilo Code from your iPhone"
  homepage "https://kilo.42bytes.eu"
  url "https://github.com/42-bytes/kilo-remote-daemon/releases/download/v0.9.0/kilo-remote-daemon-0.9.0.tar.gz"
  sha256 "025f0a35ae3b09b56a80b2aac7e0fe80c92fd0288737476b1346d8343e3fe505"
  license "MIT"

  depends_on "node@22"
  depends_on :macos

  def install
    libexec.install Dir["dist/*"]
    libexec.install "node_modules"
    libexec.install "package.json"

    if File.directory?("KiloRemote.app")
      prefix.install "KiloRemote.app"
    end

    node = Formula["node@22"].opt_bin/"node"

    (bin/"kiloremote").write <<~SH
      #!/bin/bash
      NODE="#{node}"
      LIBEXEC="#{libexec}"
      case "$1" in
        init|start|stop|pair|setup|revoke|unlock|audit|status|logs)
          exec "$NODE" "$LIBEXEC/cli.js" "$@"
          ;;
        "")
          exec "$NODE" "$LIBEXEC/index.js"
          ;;
        *)
          echo "Usage: kiloremote <command>"
          echo ""
          echo "Commands:"
          echo "  init     Interactive setup wizard"
          echo "  start    Start daemon, kilo serve, and menu bar app"
          echo "  stop     Stop daemon and kilo serve"
          echo "  pair     Generate pairing QR code for iPhone app"
          echo "  setup    Configure TOTP two-factor authentication"
          echo "  revoke   Revoke all device keys and disconnect iOS app"
          echo "  unlock   Unlock daemon after panic lockdown"
          echo "  audit    Show local audit log and state"
          echo "  status   Show current daemon configuration"
          echo "  logs     Show recent daemon log output"
          exit 1
          ;;
      esac
    SH
  end

  def caveats
    <<~EOS
      Get started:
        kiloremote init

      This will walk you through connecting to the relay,
      setting your API key, and configuring Kilo Code.

      After setup, pair your iPhone:
        kiloremote pair

      Then start everything:
        kiloremote start
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/kiloremote help 2>&1", 1)
  end
end
