class KiloRemoteDaemon < Formula
  desc "macOS daemon for Kilo Remote - control Kilo Code from your iPhone"
  homepage "https://kilo.42bytes.eu"
  url "https://github.com/42-bytes/kilo-remote-daemon/releases/download/v0.7.8/kilo-remote-daemon-0.7.8.tar.gz"
  sha256 "5c4c181d0e8549649ff2d5350556004be1bca0d86a39752f17fc50d63586e9b1"
  license "MIT"

  depends_on "node@22"
  depends_on :macos

  def install
    libexec.install Dir["dist/*"]
    libexec.install "node_modules"
    libexec.install "package.json"

    node = Formula["node@22"].opt_bin/"node"

    (bin/"kiloremote").write <<~SH
      #!/bin/bash
      NODE="#{node}"
      LIBEXEC="#{libexec}"
      case "$1" in
        init|pair|setup|unlock|audit|status)
          exec "$NODE" "$LIBEXEC/cli.js" "$@"
          ;;
        "")
          exec "$NODE" "$LIBEXEC/index.js"
          ;;
        *)
          echo "Usage: kiloremote <init|pair|setup|unlock|audit|status>"
          echo ""
          echo "Commands:"
          echo "  init     Interactive setup wizard"
          echo "  pair     Generate pairing QR code for iPhone app"
          echo "  setup    Configure TOTP two-factor authentication"
          echo "  unlock   Unlock daemon after panic lockdown"
          echo "  audit    Show local audit log and state"
          echo "  status   Show current daemon configuration"
          echo ""
          echo "Run without arguments to start the daemon."
          exit 1
          ;;
      esac
    SH

    etc.install "com.kilo.remote-daemon.plist"
  end

  def caveats
    <<~EOS
      Get started:
        kiloremote init

      This will walk you through connecting to the relay,
      setting your API key, and configuring Kilo Code.

      After setup, pair your iPhone:
        kiloremote pair

      Then start the daemon:
        brew services start 42-bytes/kilo/kilo-remote-daemon
    EOS
  end

  service do
    run [Formula["node@22"].opt_bin/"node", opt_libexec/"index.js"]
    working_dir var/"kilo-remote"
    keep_alive true
    log_path var/"log/kilo-remote-daemon.log"
    error_log_path var/"log/kilo-remote-daemon.log"
    environment_variables NODE_ENV: "production"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/kiloremote help 2>&1", 1)
  end
end
