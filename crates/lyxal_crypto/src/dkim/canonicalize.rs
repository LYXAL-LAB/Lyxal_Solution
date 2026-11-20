/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: Apache-2.0 OR MIT
 */

//! DKIM header and body canonicalization (RFC 6376 §3.4).
//!
//! Ported from `mail-auth` 0.16.0 (commit `c862df2`), `src/dkim/canonicalize.rs`, under its
//! `Apache-2.0 OR MIT` licence (notice kept above and in `SOURCES.md`). Changes made by the port:
//!
//! * the SWAR searches, `slice::as_chunks` (Rust 1.88) and `memchr` replaced by plain byte scans
//!   (MSRV 1.85 of `lyxal_crypto`, no new dependency); the output is byte-identical;
//! * header values are passed **without** their final CRLF (it is appended by the caller in
//!   `super::DkimHeaderCanonicalizer`), so the "value ends with LF" branch of
//!   `write_relaxed_value` is gone;
//! * the `l=` limit is applied by the sink of `super::DkimBodyHasher` to the *canonicalized*
//!   bytes (RFC 6376 §3.5), not to the raw input as `mail-auth` does;
//! * selection of the headers listed in `h=` and the `DKIM-Signature` parsing stay in the mail
//!   crates (CTO decision C4) and are not ported.
//!
//! Line endings, as in `mail-auth`: in the body, a bare LF counts as a line end and a bare CR is
//! dropped, with both algorithms (the SMTP receiver of lot 5 refuses bare line endings in `DATA`
//! beforehand).

/// Destination of canonicalized bytes.
pub(super) trait Sink {
    fn write(&mut self, bytes: &[u8]);
}

impl Sink for Vec<u8> {
    fn write(&mut self, bytes: &[u8]) {
        self.extend_from_slice(bytes);
    }
}

/// Position of the first CR or LF.
fn find_line_break(haystack: &[u8]) -> Option<usize> {
    haystack.iter().position(|&ch| ch == b'\r' || ch == b'\n')
}

/// Position of the first byte that is a space, a control character or a line break (any byte
/// up to `0x20`).
fn find_wsp_or_break(haystack: &[u8]) -> Option<usize> {
    haystack.iter().position(|&ch| ch <= b' ')
}

/// End of the longest prefix that the simple algorithm copies verbatim: plain bytes and CRLF
/// followed by a byte that is neither CR nor LF.
fn simple_run_end(chunk: &[u8]) -> usize {
    let mut offset = 0;
    while let Some(pos) = find_line_break(&chunk[offset..]) {
        let start = offset + pos;
        match &chunk[start..] {
            [b'\r', b'\n', next, ..] if *next != b'\r' && *next != b'\n' => offset = start + 2,
            _ => return start,
        }
    }
    chunk.len()
}

/// End of the longest prefix that the relaxed algorithm copies verbatim: plain bytes, single
/// spaces between plain bytes and CRLF followed by a plain byte.
fn relaxed_run_end(chunk: &[u8]) -> usize {
    let mut offset = 0;
    while let Some(pos) = find_wsp_or_break(&chunk[offset..]) {
        let start = offset + pos;
        match &chunk[start..] {
            [b' ', next, ..] if start != 0 && *next > b' ' => offset = start + 2,
            [b'\r', b'\n', next, ..] if start != 0 && *next > b' ' => offset = start + 2,
            [b'\t' | b'\n' | b'\r' | b' ', ..] => return start,
            _ => offset = start + 1,
        }
    }
    chunk.len()
}

/// Canonicalization state of a body fed in chunks: the result does not depend on where the
/// chunks are cut.
pub(super) struct BodyState {
    /// Line ends seen and not yet written (dropped if they end the body).
    crlf_seq: u64,
    last_ch: u8,
    is_empty: bool,
}

impl BodyState {
    pub(super) fn new() -> Self {
        Self {
            crlf_seq: 0,
            last_ch: 0,
            is_empty: true,
        }
    }

    pub(super) fn write(&mut self, relaxed: bool, chunk: &[u8], sink: &mut impl Sink) {
        if relaxed {
            self.write_relaxed(chunk, sink);
        } else {
            self.write_simple(chunk, sink);
        }
    }

    /// Final line end: simple always ends with one CRLF (an empty body is a single CRLF,
    /// RFC 6376 §3.4.3); relaxed ends with one CRLF unless the body is empty (§3.4.4).
    pub(super) fn finish(&mut self, relaxed: bool, sink: &mut impl Sink) {
        if !relaxed || !self.is_empty {
            sink.write(b"\r\n");
        }
    }

    fn flush_breaks(&mut self, sink: &mut impl Sink) {
        while self.crlf_seq != 0 {
            sink.write(b"\r\n");
            self.crlf_seq -= 1;
        }
    }

    fn write_simple(&mut self, chunk: &[u8], sink: &mut impl Sink) {
        let mut rest = chunk;
        while !rest.is_empty() {
            let (run, tail) = rest.split_at(simple_run_end(rest));
            if !run.is_empty() {
                self.flush_breaks(sink);
                sink.write(run);
                self.is_empty = false;
            }
            let mut consumed = 0;
            for &ch in tail {
                match ch {
                    b'\n' => self.crlf_seq += 1,
                    b'\r' => {}
                    _ => break,
                }
                consumed += 1;
            }
            rest = &tail[consumed..];
        }
    }

    fn write_relaxed(&mut self, chunk: &[u8], sink: &mut impl Sink) {
        let mut rest = chunk;
        while !rest.is_empty() {
            let (run, tail) = rest.split_at(relaxed_run_end(rest));
            if let Some(&last_ch) = run.last() {
                self.flush_breaks(sink);
                if self.last_ch == b' ' || self.last_ch == b'\t' {
                    sink.write(b" ");
                }
                sink.write(run);
                self.is_empty = false;
                self.last_ch = last_ch;
            }
            let mut consumed = 0;
            for &ch in tail {
                match ch {
                    b'\n' => self.crlf_seq += 1,
                    b' ' | b'\t' | b'\r' => {}
                    _ => break,
                }
                consumed += 1;
                self.last_ch = ch;
            }
            rest = &tail[consumed..];
        }
    }
}

/// Relaxed header name (RFC 6376 §3.4.2): lower case, whitespace removed, then `:`.
pub(super) fn write_relaxed_name(name: &[u8], out: &mut Vec<u8>) {
    out.extend(
        name.iter()
            .filter(|ch| !ch.is_ascii_whitespace())
            .map(u8::to_ascii_lowercase),
    );
    out.push(b':');
}

/// Relaxed header value (RFC 6376 §3.4.2): folding removed, each run of whitespace turned into
/// one space, whitespace at both ends removed. The final CRLF is not part of `value`.
pub(super) fn write_relaxed_value(value: &[u8], out: &mut Vec<u8>) {
    let mut rest = value;
    let mut first = true;
    while let Some(start) = rest.iter().position(|ch| !ch.is_ascii_whitespace()) {
        let end = rest[start..]
            .iter()
            .position(u8::is_ascii_whitespace)
            .map_or(rest.len(), |len| start + len);
        let (spaces, token) = (&rest[..start], &rest[start..end]);
        // Whitespace ending with CR, LF or form feed (folding without WSP) joins the tokens
        if !first && matches!(spaces.last(), Some(b' ' | b'\t')) {
            out.push(b' ');
        }
        first = false;
        out.extend_from_slice(token);
        rest = &rest[end..];
    }
}

/// Simple header (RFC 6376 §3.4.1): name, `:` and value unchanged.
pub(super) fn write_simple_header(name: &[u8], value: &[u8], out: &mut Vec<u8>) {
    out.extend_from_slice(name);
    out.push(b':');
    out.extend_from_slice(value);
}

/// Value of a signature header (`DKIM-Signature`, `ARC-Message-Signature`, `ARC-Seal`) with the
/// value of each `b=` tag deleted, surrounding whitespace included (RFC 6376 §3.7). Everything
/// else is kept byte for byte, including the whitespace before the tag name and around `=`.
/// Tag names are case-sensitive (RFC 6376 §3.2): `bh=` and `B=` are kept. Written for this crate
/// (not ported: `mail-auth` also strips an upper-case `B=`).
pub(super) fn strip_signature_value(value: &[u8], out: &mut Vec<u8>) {
    let mut segments = value.split(|&ch| ch == b';').peekable();
    while let Some(segment) = segments.next() {
        let name_start = segment
            .iter()
            .position(|ch| !ch.is_ascii_whitespace())
            .unwrap_or(segment.len());
        let after_name = &segment[name_start..];
        let is_b = after_name.first() == Some(&b'b') && {
            let rest = &after_name[1..];
            let equals = rest
                .iter()
                .position(|ch| !ch.is_ascii_whitespace())
                .unwrap_or(rest.len());
            rest.get(equals) == Some(&b'=')
        };
        match is_b.then(|| segment.iter().position(|&ch| ch == b'=')) {
            Some(Some(equals)) => out.extend_from_slice(&segment[..=equals]),
            _ => out.extend_from_slice(segment),
        }
        if segments.peek().is_some() {
            out.push(b';');
        }
    }
}
