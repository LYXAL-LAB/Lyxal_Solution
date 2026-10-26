use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};
use std::thread;

fn handle_client(mut client: TcpStream, target_addr: &str) {
    let client_peer = client.peer_addr().map(|p| p.to_string()).unwrap_or_default();
    println!(">>> [Bridge] New connection from {}", client_peer);
    let _ = client.set_nodelay(true);
    let mut server = match TcpStream::connect(target_addr) {
        Ok(s) => s,
        Err(e) => {
            eprintln!(">>> [Bridge] Failed to connect to {}: {}", target_addr, e);
            return;
        }
    };
    let _ = server.set_nodelay(true);

    // 1. Forward initial handshake request from client to server
    let mut buf = [0u8; 4096];
    let n = match client.read(&mut buf) {
        Ok(n) if n > 0 => n,
        Ok(_) => { println!(">>> [Bridge] Client closed on read"); return; }
        Err(e) => { eprintln!(">>> [Bridge] Client read error: {}", e); return; }
    };

    let client_req_str = String::from_utf8_lossy(&buf[..n]);
    let requested_proto = client_req_str.lines()
        .find(|l| l.to_lowercase().starts_with("sec-websocket-protocol:"))
        .and_then(|l| l.split(':').nth(1))
        .map(|s| s.trim().to_string());

    println!(">>> [Bridge] Client requested proto: {:?}", requested_proto);

    if let Err(e) = server.write_all(&buf[..n]) {
        eprintln!(">>> [Bridge] Server write error: {}", e);
        return;
    }
    let _ = server.flush();

    // 2. Read handshake response from server up to \r\n\r\n
    let mut header = Vec::new();
    let mut b = [0u8; 1];
    while let Ok(1) = server.read(&mut b) {
        header.push(b[0]);
        if header.ends_with(b"\r\n\r\n") {
            break;
        }
    }

    let header_str = String::from_utf8_lossy(&header);
    println!(">>> [Bridge] Server handshake response status: {}", header_str.lines().next().unwrap_or(""));

    // Inject requested subprotocol if present and not already returned
    let mut modified = header_str.trim_end().to_string();
    if let Some(ref proto) = requested_proto {
        if !header_str.to_lowercase().contains("sec-websocket-protocol:") {
            modified.push_str(&format!("\r\nsec-websocket-protocol: {proto}"));
        }
    }
    modified.push_str("\r\n\r\n");

    println!(">>> [Bridge] Modified header:\n{}", modified);

    if let Err(e) = client.write_all(modified.as_bytes()) {
        eprintln!(">>> [Bridge] Client write handshake error: {}", e);
        return;
    }
    let _ = client.flush();
    println!(">>> [Bridge] Handshake complete! Relaying stream...");

    // 3. Bi-directional real-time forwarding with immediate flush
    let mut s_read = match server.try_clone() {
        Ok(s) => s,
        Err(e) => { eprintln!(">>> [Bridge] Clone error: {}", e); return; }
    };
    let mut c_write = match client.try_clone() {
        Ok(c) => c,
        Err(e) => { eprintln!(">>> [Bridge] Clone error: {}", e); return; }
    };

    thread::spawn(move || {
        let mut buf = [0u8; 8192];
        loop {
            match s_read.read(&mut buf) {
                Ok(n) if n > 0 => {
                    println!(">>> [Bridge] Server -> Client ({} bytes): {:?}", n, String::from_utf8_lossy(&buf[..n]));
                    if c_write.write_all(&buf[..n]).is_err() || c_write.flush().is_err() {
                        println!(">>> [Bridge] Server -> Client write failed");
                        break;
                    }
                }
                Ok(_) => { println!(">>> [Bridge] Server closed stream"); break; }
                Err(e) => { println!(">>> [Bridge] Server read error: {}", e); break; }
            }
        }
    });

    let mut buf = [0u8; 8192];
    loop {
        match client.read(&mut buf) {
            Ok(n) if n > 0 => {
                println!(">>> [Bridge] Client -> Server ({} bytes): {:?}", n, String::from_utf8_lossy(&buf[..n]));
                if server.write_all(&buf[..n]).is_err() || server.flush().is_err() {
                    println!(">>> [Bridge] Client -> Server write failed");
                    break;
                }
            }
            Ok(_) => { println!(">>> [Bridge] Client closed stream"); break; }
            Err(e) => { println!(">>> [Bridge] Client read error: {}", e); break; }
        }
    }
}

fn main() {
    let listener = TcpListener::bind("127.0.0.1:8002").expect("Bind on 8002");
    println!(">>> WS Bridge actif sur 127.0.0.1:8002 -> 127.0.0.1:8001");
    for stream in listener.incoming() {
        if let Ok(stream) = stream {
            thread::spawn(move || handle_client(stream, "127.0.0.1:8001"));
        }
    }
}
