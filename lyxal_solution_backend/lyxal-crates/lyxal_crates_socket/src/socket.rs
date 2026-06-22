
use std::fmt;
use std::io::{self, Read, Write};
use std::mem::MaybeUninit;
use std::net;

use crate::telemetry::sys::{self, c_int, RawSocket};
use crate::{Domain, Protocol, SockAddr, Type};

/// Interface index or address.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InterfaceIndexOrAddress {
    /// Interface index.
    Index(u32),
    /// Interface address.
    Address(net::Ipv4Addr),
}

/// A socket.
pub struct Socket {
    inner: sys::Socket,
}

impl Socket {
    /// Create a new socket.
    pub fn new(domain: Domain, ty: Type, protocol: Option<Protocol>) -> io::Result<Socket> {
        let protocol = protocol.map(|p| p.into()).unwrap_or(0);
        sys::socket(domain.into(), ty.into(), protocol).map(|inner| Socket { inner: unsafe { sys::socket_from_raw(inner) } })
    }

    /// Bind the socket.
    pub fn bind(&self, addr: &SockAddr) -> io::Result<()> {
        sys::bind(self.as_raw(), addr)
    }

    /// Listen for connections.
    pub fn listen(&self, backlog: i32) -> io::Result<()> {
        sys::listen(self.as_raw(), backlog)
    }

    /// Accept a connection.
    pub fn accept(&self) -> io::Result<(Socket, SockAddr)> {
        sys::accept(self.as_raw()).map(|(raw, addr)| (Socket { inner: unsafe { sys::socket_from_raw(raw) } }, addr))
    }

    /// Connect to an address.
    pub fn connect(&self, addr: &SockAddr) -> io::Result<()> {
        sys::connect(self.as_raw(), addr)
    }

    /// Returns the raw socket.
    pub fn as_raw(&self) -> RawSocket {
        sys::socket_as_raw(&self.inner)
    }

    /// Returns the local address.
    pub fn local_addr(&self) -> io::Result<SockAddr> {
        sys::getsockname(self.as_raw())
    }

    /// Returns the peer address.
    pub fn peer_addr(&self) -> io::Result<SockAddr> {
        sys::getpeername(self.as_raw())
    }

    /// Sets the IPV6_V6ONLY option.
    pub fn set_only_v6(&self, only_v6: bool) -> io::Result<()> {
        unsafe { sys::setsockopt(self.as_raw(), sys::IPPROTO_IPV6, sys::IPV6_V6ONLY, only_v6 as c_int) }
    }

    /// Sets TCP keepalive.
    pub fn set_tcp_keepalive(&self, keepalive: &crate::TcpKeepalive) -> io::Result<()> {
        sys::set_tcp_keepalive(self.as_raw(), keepalive)
    }

    /// Receive data.
    pub fn recv(&self, buf: &mut [MaybeUninit<u8>], flags: i32) -> io::Result<usize> {
        sys::recv(self.as_raw(), buf, flags)
    }

    /// Send data.
    pub fn send(&self, buf: &[u8], flags: i32) -> io::Result<usize> {
        sys::send(self.as_raw(), buf, flags)
    }

    /// Returns the socket error.
    pub fn take_error(&self) -> io::Result<Option<io::Error>> {
        unsafe {
            let error: c_int = sys::getsockopt(self.as_raw(), sys::SOL_SOCKET, sys::SO_ERROR)?;
            if error == 0 {
                Ok(None)
            } else {
                Ok(Some(io::Error::from_raw_os_error(error)))
            }
        }
    }

    /// Create from raw socket.
    pub(crate) unsafe fn from_raw(raw: RawSocket) -> Socket {
        Socket { inner: sys::socket_from_raw(raw) }
    }

    /// Into raw socket.
    pub fn into_raw(self) -> RawSocket {
        sys::socket_into_raw(self.inner)
    }

    // Lyxal Solution Added Methods

    /// Returns the size of the receive buffer (SO_RCVBUF).
    pub fn recv_buffer_size(&self) -> io::Result<usize> {
        unsafe { sys::getsockopt::<c_int>(self.as_raw(), sys::SOL_SOCKET, sys::SO_RCVBUF).map(|n| n as usize) }
    }

    /// Returns the size of the send buffer (SO_SNDBUF).
    pub fn send_buffer_size(&self) -> io::Result<usize> {
        unsafe { sys::getsockopt::<c_int>(self.as_raw(), sys::SOL_SOCKET, sys::SO_SNDBUF).map(|n| n as usize) }
    }

    /// Returns the socket type (SO_TYPE).
    pub fn get_type(&self) -> io::Result<Type> {
        unsafe { sys::getsockopt::<c_int>(self.as_raw(), sys::SOL_SOCKET, sys::SO_TYPE).map(Type::from) }
    }

    /// Wrapper for recv that retries on EINTR.
    pub fn recv_with_retry(&self, buf: &mut [MaybeUninit<u8>]) -> io::Result<usize> {
        loop {
            match self.recv(buf, 0) {
                Err(ref e) if e.kind() == io::ErrorKind::Interrupted => continue,
                res => return res,
            }
        }
    }

    /// Wrapper for send that retries on EINTR.
    pub fn send_with_retry(&self, buf: &[u8]) -> io::Result<usize> {
        loop {
            match self.send(buf, 0) {
                Err(ref e) if e.kind() == io::ErrorKind::Interrupted => continue,
                res => return res,
            }
        }
    }
}

impl Read for Socket {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        let buf = unsafe { &mut *(buf as *mut [u8] as *mut [MaybeUninit<u8>]) };
        self.recv(buf, 0)
    }
}

impl Write for Socket {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        self.send(buf, 0)
    }
    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}

impl fmt::Debug for Socket {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Socket")
            .field("raw", &self.as_raw())
            .field("local_addr", &self.local_addr().ok())
            .field("peer_addr", &self.peer_addr().ok())
            .finish()
    }
}

impl From<net::TcpStream> for Socket {
    fn from(s: net::TcpStream) -> Socket {
        use std::os::windows::io::IntoRawSocket;
        Socket { inner: unsafe { sys::socket_from_raw(s.into_raw_socket() as RawSocket) } }
    }
}

impl From<Socket> for net::TcpStream {
    fn from(s: Socket) -> net::TcpStream {
        use std::os::windows::io::FromRawSocket;
        unsafe { net::TcpStream::from_raw_socket(sys::socket_into_raw(s.inner) as _) }
    }
}

impl From<net::TcpListener> for Socket {
    fn from(s: net::TcpListener) -> Socket {
        use std::os::windows::io::IntoRawSocket;
        Socket { inner: unsafe { sys::socket_from_raw(s.into_raw_socket() as RawSocket) } }
    }
}

impl From<Socket> for net::TcpListener {
    fn from(s: Socket) -> net::TcpListener {
        use std::os::windows::io::FromRawSocket;
        unsafe { net::TcpListener::from_raw_socket(sys::socket_into_raw(s.inner) as _) }
    }
}

impl From<net::UdpSocket> for Socket {
    fn from(s: net::UdpSocket) -> Socket {
        use std::os::windows::io::IntoRawSocket;
        Socket { inner: unsafe { sys::socket_from_raw(s.into_raw_socket() as RawSocket) } }
    }
}

impl From<Socket> for net::UdpSocket {
    fn from(s: Socket) -> net::UdpSocket {
        use std::os::windows::io::FromRawSocket;
        unsafe { net::UdpSocket::from_raw_socket(sys::socket_into_raw(s.inner) as _) }
    }
}
