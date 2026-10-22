# 全ての zsh（非対話・エージェント起動のシェル含む）が読む。対話専用の .zshrc / mac.zsh では届かない。
# eMudhra 中間CA侵害 (2026-10-20): macOS の /etc/ssl/cert.pem は署名済みボリューム上で更新できず、
# /usr/bin/curl や mise Python が古い根を信頼し続ける。Homebrew の最新バンドルに向ける。
# 注意: /usr/bin/python3 (LibreSSL) は SSL_CERT_FILE を無視する → コード側で cafile 指定が必要。
# git は ~/.gitconfig の http.sslCAInfo で別途指定。Apple が cert.pem を更新したら不要になる。
if [[ -f /opt/homebrew/etc/ca-certificates/cert.pem ]]; then
  export CURL_CA_BUNDLE=/opt/homebrew/etc/ca-certificates/cert.pem
  export SSL_CERT_FILE="$CURL_CA_BUNDLE"
fi
