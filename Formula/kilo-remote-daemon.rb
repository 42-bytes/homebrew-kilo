class KiloRemoteDaemon < Formula
  desc "macOS daemon for Kilo Remote - control Kilo Code from your iPhone"
  homepage "https://kilo.42bytes.eu"
  url "https://github.com/42-bytes/kilo-remote-daemon/releases/download/v0.8.2/kilo-remote-daemon-0.8.2.tar.gz"
  sha256 "cf0b891bf53c56177d3be5c6252ea8cff58a162722966dfa00ea2791bae951c6"
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
        init|start|stop|pair|setup|revoke|unlock|audit|status)
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
