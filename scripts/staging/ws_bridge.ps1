# Pont protocolaire WebSocket pour SurrealDB 3.2.0
# Corrige l'absence du header de subprotocol 'sec-websocket-protocol: surrealdb'
# dans le handshake HTTP 101 de SurrealDB 3.2.0 pour tokio-tungstenite / SurrealDB Rust SDK 2.x

param(
    [int]$ListenPort = 8002,
    [int]$TargetPort = 8001
)

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $ListenPort)
$listener.Start()
Write-Host ">>> WS Bridge actif sur 127.0.0.1:$ListenPort -> 127.0.0.1:$TargetPort"

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        [System.Threading.Tasks.Task]::Run({
            param($c, $targetPort)
            try {
                $target = New-Object System.Net.Sockets.TcpClient("127.0.0.1", $targetPort)
                $cStream = $c.GetStream()
                $tStream = $target.GetStream()

                # 1. Forward request from client to server
                $buf = New-Object byte[] 4096
                $read = $cStream.Read($buf, 0, $buf.Length)
                $tStream.Write($buf, 0, $read)
                $tStream.Flush()

                # 2. Read handshake response from server
                $tReader = New-Object System.IO.StreamReader($tStream, [System.Text.Encoding]::ASCII)
                $tWriter = New-Object System.IO.StreamWriter($cStream, [System.Text.Encoding]::ASCII)

                $headerBlock = ""
                while ($true) {
                    $line = $tReader.ReadLine()
                    if ($line -eq $null -or $line -eq "") {
                        break
                    }
                    $headerBlock += $line + "`r`n"
                }

                # Inject subprotocol header before final CRLF
                $headerBlock += "sec-websocket-protocol: surrealdb`r`n`r`n"
                $bytes = [System.Text.Encoding]::ASCII.GetBytes($headerBlock)
                $cStream.Write($bytes, 0, $bytes.Length)
                $cStream.Flush()

                # 3. Bi-directional raw streaming
                $t1 = [System.Threading.Tasks.Task]::Run({
                    $b = New-Object byte[] 16384
                    try {
                        while (($r = $cStream.Read($b, 0, $b.Length)) -gt 0) {
                            $tStream.Write($b, 0, $r)
                            $tStream.Flush()
                        }
                    } catch {}
                })
                $t2 = [System.Threading.Tasks.Task]::Run({
                    $b = New-Object byte[] 16384
                    try {
                        while (($r = $tStream.Read($b, 0, $b.Length)) -gt 0) {
                            $cStream.Write($b, 0, $r)
                            $cStream.Flush()
                        }
                    } catch {}
                })
                [System.Threading.Tasks.Task]::WaitAny(@($t1, $t2))
                $c.Close()
                $target.Close()
            } catch {}
        }.GetNewClosure(), @($client, $TargetPort))
    }
} finally {
    $listener.Stop()
}
