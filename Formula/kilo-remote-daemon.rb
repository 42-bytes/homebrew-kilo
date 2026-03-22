class KiloRemoteDaemon < Formula
  desc "macOS daemon for Kilo Remote - control Kilo Code from your iPhone"
  homepage "https://kilo.42bytes.eu"
  url "https://github.com/42-bytes/kilo-remote-daemon/releases/download/v0.1.0/kilo-remote-daemon-0.1.0.tar.gz"
  sha256 "57865ae73f3963850c12a2d44cf4dce68b8f1de4bd9b9eab9703076d964d7a50"
  license "MIT"

  depends_on "node@22"
  depends_on :macos

  def install
    system "npm", "ci", "--omit=dev"
    system "npm", "rebuild", "node-pty", "--build-from-source"
    system "npx", "tsc"

    libexec.install Dir["dist/*"]
    libexec.install "node_modules"
    libexec.install "package.json"

    (bin/"kiloremote").write <<~SH
      #!/bin/bash
      exec "#{Formula["node@22"].opt_bin}/node" "#{libexec}/index.js" "$@"
    SH

    etc.install "com.kilo.remote-daemon.plist"
  end

  def caveats
    <<~EOS
      Configuration:
        Create #{etc}/kilo-remote-daemon.env with your settings:
          RELAY_URL=https://kilo-remote-relay.vercel.app
          RELAY_API_KEY=your-api-key
          ACCOUNT_EMAIL=your@email.com
          KILO_SERVER_HOST=127.0.0.1
          KILO_SERVER_PORT=4096

      Pairing:
        Run: kiloremote pair
        Then scan the QR code with the iOS app.

      To start the daemon as a background service:
        brew services start 42bytes/kilo/kilo-remote-daemon

      Or load the launchd plist manually:
        cp #{etc}/com.kilo.remote-daemon.plist ~/Library/LaunchAgents/
        launchctl load ~/Library/LaunchAgents/com.kilo.remote-daemon.plist
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
    assert_match "kilo-remote-daemon", shell_output("#{bin}/kiloremote --version 2>&1", 1)
  end
end
