//! PDF Security - Encryption and Decryption

use lopdf::{Document, Object, Dictionary};
use md5;

struct MyRc4 {
    s: [u8; 256],
    i: u8,
    j: u8,
}

impl MyRc4 {
    fn new(key: &[u8]) -> Self {
        let mut s = [0u8; 256];
        for i in 0..=255 { s[i as usize] = i as u8; }
        let mut j: u8 = 0;
        for i in 0..=255 {
            let i_usize = i as usize;
            j = j.wrapping_add(s[i_usize]).wrapping_add(key[i_usize % key.len()]);
            s.swap(i_usize, j as usize);
        }
        Self { s, i: 0, j: 0 }
    }
    
    fn apply(&mut self, data: &mut [u8]) {
        for b in data.iter_mut() {
            self.i = self.i.wrapping_add(1);
            let i_usize = self.i as usize;
            self.j = self.j.wrapping_add(self.s[i_usize]);
            let j_usize = self.j as usize;
            self.s.swap(i_usize, j_usize);
            let t = self.s[i_usize].wrapping_add(self.s[j_usize]);
            *b ^= self.s[t as usize];
        }
    }
}

#[derive(Debug, Clone)]
pub enum EncryptionMethod {
    None,
    V1, // RC4 40
    V2, // RC4 128
    AESV2, // AES 128
    AESV3, // AES 256
}

pub struct SecurityHandler {
    pub method: EncryptionMethod,
    pub encryption_key: Vec<u8>,
    pub file_id: Vec<u8>,
    pub o_value: Vec<u8>,
    pub u_value: Vec<u8>,
    pub p_value: i32,
    pub encrypt_metadata: bool,
}

impl SecurityHandler {
    pub fn from_dictionary(dict: &Dictionary, trailer: &Dictionary) -> Option<Self> {
        let filter = dict.get(b"Filter").and_then(|o| o.as_name()).unwrap_or(b"Standard");
        if filter != b"Standard" {
            return None; 
        }

        let v = dict.get(b"V").and_then(|o| o.as_i64()).unwrap_or(0);
        let r = dict.get(b"R").and_then(|o| o.as_i64()).unwrap_or(0);
        
        let o_val = dict.get(b"O").and_then(|o| o.as_str()).map(|s| s.to_vec()).unwrap_or_default();
        let u_val = dict.get(b"U").and_then(|o| o.as_str()).map(|s| s.to_vec()).unwrap_or_default();
        let p_val = dict.get(b"P").and_then(|o| o.as_i64()).unwrap_or(0) as i32;
        let encrypt_metadata = dict.get(b"EncryptMetadata").and_then(|o| o.as_bool()).unwrap_or(true);

        let id = trailer.get(b"ID").ok()
            .and_then(|o| o.as_array().ok())
            .and_then(|arr| arr.get(0))
            .and_then(|o| o.as_str().ok())
            .map(|s| s.to_vec())
            .unwrap_or_default();

        let method = match v {
            1 if r == 2 => EncryptionMethod::V1,
            2 if r == 3 => EncryptionMethod::V2,
            4 if r == 4 => EncryptionMethod::AESV2,
            5 if r == 5 || r == 6 => EncryptionMethod::AESV3,
            _ => EncryptionMethod::None,
        };

        if matches!(method, EncryptionMethod::None) {
            return None;
        }

        Some(SecurityHandler {
            method,
            encryption_key: Vec::new(),
            file_id: id,
            o_value: o_val,
            u_value: u_val,
            p_value: p_val,
            encrypt_metadata,
        })
    }

    pub fn authenticate(&mut self, password: &str) -> bool {
        match self.method {
            EncryptionMethod::V1 | EncryptionMethod::V2 => {
                let key_len = if matches!(self.method, EncryptionMethod::V1) { 5 } else { 16 };
                
                let encryption_key = compute_encryption_key(
                    password,
                    &self.o_value,
                    self.p_value,
                    &self.file_id,
                    self.encrypt_metadata,
                    key_len 
                );
                
                let mut test_u = PADDING.to_vec();
                if matches!(self.method, EncryptionMethod::V2) {
                    let mut hasher = md5::Context::new();
                    hasher.consume(&PADDING);
                    hasher.consume(&self.file_id);
                    test_u = hasher.compute().0.to_vec();
                }
                
                let mut rc4 = MyRc4::new(&encryption_key);
                rc4.apply(&mut test_u);
                
                if self.u_value.len() >= 16 && test_u.len() >= 16 {
                    if self.u_value[0..16] == test_u[0..16] {
                        self.encryption_key = encryption_key;
                        return true;
                    }
                }
                
                if self.u_value.is_empty() {
                     self.encryption_key = encryption_key;
                     return true;
                }
                
                false
            },
            _ => false,
        }
    }

    pub fn decrypt_object(&self, object_id: (u32, u16), data: &[u8]) -> Vec<u8> {
        if self.encryption_key.is_empty() {
            return data.to_vec();
        }

        match self.method {
            EncryptionMethod::V1 | EncryptionMethod::V2 => {
                let mut hasher = md5::Context::new();
                hasher.consume(&self.encryption_key);
                hasher.consume(&object_id.0.to_le_bytes()[0..3]);
                hasher.consume(&object_id.1.to_le_bytes()[0..2]);
                
                let key = hasher.compute().0;
                let obj_key_len = std::cmp::min(self.encryption_key.len() + 5, 16);
                let obj_key = &key[0..obj_key_len];
                
                let mut rc4 = MyRc4::new(obj_key);
                let mut out = data.to_vec();
                rc4.apply(&mut out);
                out
            }
            _ => data.to_vec(),
        }
    }

    pub fn decrypt_document(&self, doc: &mut Document) {
        for (id, object) in doc.objects.iter_mut() {
            match object {
                Object::String(data, _) => {
                    *data = self.decrypt_object(*id, data);
                }
                Object::Stream(stream) => {
                    stream.content = self.decrypt_object(*id, &stream.content);
                }
                _ => {}
            }
        }
    }
}

const PADDING: [u8; 32] = [
    0x28, 0xBF, 0x4E, 0x5E, 0x4E, 0x75, 0x8A, 0x41,
    0x64, 0x00, 0x4E, 0x56, 0xFF, 0xFA, 0x01, 0x08,
    0x2E, 0x2E, 0x00, 0xB6, 0xD0, 0x68, 0x3E, 0x80,
    0x2F, 0x0C, 0xA9, 0xFE, 0x64, 0x53, 0x69, 0x7A,
];

fn compute_encryption_key(
    password: &str,
    o_value: &[u8],
    p_value: i32,
    file_id: &[u8],
    encrypt_metadata: bool,
    key_len: usize,
) -> Vec<u8> {
    let mut padded = password.as_bytes().to_vec();
    if padded.len() < 32 {
        padded.extend_from_slice(&PADDING[padded.len()..]);
    } else {
        padded.truncate(32);
    }

    let mut hasher = md5::Context::new();
    hasher.consume(&padded);
    hasher.consume(o_value);
    hasher.consume(&p_value.to_le_bytes());
    hasher.consume(file_id);
    
    if !encrypt_metadata {
        hasher.consume(&[0xFF, 0xFF, 0xFF, 0xFF]);
    }
    
    let mut hash = hasher.compute().0.to_vec();
    
    if key_len > 5 {
        for _ in 0..50 {
            let mut hasher = md5::Context::new();
            hasher.consume(&hash[0..key_len]); 
            hash = hasher.compute().0.to_vec();
        }
    }
    
    hash.truncate(key_len);
    hash
}

pub fn check_encryption(doc: &Document) -> Result<(), String> {
    if let Ok(_encrypt_ref) = doc.trailer.get(b"Encrypt").and_then(|o| o.as_reference()) {
        return Err("Document is encrypted".to_string());
    }
    if doc.trailer.has(b"Encrypt") {
         return Err("Document is encrypted".to_string());
    }
    Ok(())
}
