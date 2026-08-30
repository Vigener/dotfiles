param(
    [string]$PlaylistUrl
)

# --- 設定・ログ準備 ---
$logFile = Join-Path $PSScriptRoot "debug_log.txt"
$chromePort = 9222
$endpoint = "http://localhost:$chromePort/json"

function Write-Log {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Write-Log "Script Started. URL: $PlaylistUrl"

try {
    # --- Chrome/YTM ターゲットの取得 ---
    $tabs = Invoke-RestMethod $endpoint -ErrorAction Stop | Where-Object { $_.title -match "YouTube Music" }

    if (-not $tabs) {
        Write-Log "Error: YouTube Music tab not found."
        exit
    }

    $wsUrl = $tabs.webSocketDebuggerUrl
    Write-Log "WebSocket URL found."

    # --- WebSocket 接続 ---
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $cts = New-Object System.Threading.CancellationTokenSource
    $uri = New-Object System.Uri($wsUrl)
    $ws.ConnectAsync($uri, $cts.Token).Wait()
    
    Write-Log "Connected to WebSocket."

    # --- ヘルパー関数: WebSocketへ送信 ---
    function Send-CDPMessage {
        param($method, $params)
        $id = Get-Random
        $payload = @{
            id = $id
            method = $method
            params = $params
        } | ConvertTo-Json -Compress

        $buffer = [System.Text.Encoding]::UTF8.GetBytes($payload)
        $segment = [System.ArraySegment[byte]]::new($buffer)
        
        $ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).Wait()
        Write-Log "Sent method: $method"
    }

    # 1. ページ遷移 (Navigate)
    Send-CDPMessage -method "Page.navigate" -params @{ url = $PlaylistUrl }
    
    # ロード待ち (簡易的に固定待機。本来はPage.loadEventFiredを待つが複雑になるためSleepで代用)
    Start-Sleep -Seconds 2

    # 2. 再生ボタンをクリック (Runtime.evaluate)
    # YouTube Musicの「シャッフル再生」や「再生」ボタンのセレクタを探してクリックするJS
    $jsCode = @"
        (function() {
            // プレイリストページの大きな再生ボタンを探す
            let playBtn = document.querySelector('ytmusic-responsive-header-renderer ytmusic-play-button-renderer button');
            if(playBtn) { 
                playBtn.click(); 
                return 'Clicked Play Button'; 
            }
            // 見つからない場合のフォールバック（最初の項目の再生ボタン）
            let firstItem = document.querySelector('ytmusic-responsive-list-item-renderer #play-button');
            if(firstItem) {
                firstItem.click();
                return 'Clicked List Item Button';
            }
            return 'Button Not Found';
        })();
"@
    
    Send-CDPMessage -method "Runtime.evaluate" -params @{ expression = $jsCode }

    Write-Log "Playback command sent."
    
    # 終了処理前に少し待つ
    Start-Sleep -Milliseconds 500
    $ws.Dispose()
    Write-Log "Script Finished successfully."

} catch {
    Write-Log "Critical Error: $($_.Exception.Message)"
}