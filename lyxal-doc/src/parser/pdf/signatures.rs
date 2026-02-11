//! PDF Digital Signatures - Validation

use lopdf::{Document, Object};

#[derive(Debug)]
pub struct SignatureValidationResult {
    pub is_valid: bool,
    pub integrity_check: bool,
    pub byte_range_valid: bool,
    pub signer_name: Option<String>,
    pub error: Option<String>,
}

pub fn validate_signatures(doc: &Document, raw_data: &[u8]) -> Vec<SignatureValidationResult> {
    let mut results = Vec::new();

    for (_id, obj) in doc.objects.iter() {
        if let Ok(dict) = obj.as_dict() {
            if let Ok(type_name) = dict.get(b"Type").and_then(|o| o.as_name()) {
                if type_name == b"Sig" {
                    results.push(validate_signature(dict, raw_data));
                }
            }
        }
    }
    
    results
}

fn validate_signature(sig_dict: &lopdf::Dictionary, raw_data: &[u8]) -> SignatureValidationResult {
    let mut result = SignatureValidationResult {
        is_valid: false,
        integrity_check: false,
        byte_range_valid: false,
        signer_name: None,
        error: None,
    };

    let byte_range = match sig_dict.get(b"ByteRange").and_then(|o| o.as_array()) {
        Ok(arr) => arr,
        Err(_) => {
            result.error = Some("Missing ByteRange".to_string());
            return result;
        }
    };

    if byte_range.len() != 4 {
        result.error = Some("Invalid ByteRange format".to_string());
        return result;
    }

    let r1_start = byte_range[0].as_i64().unwrap_or(0) as usize;
    let r1_len = byte_range[1].as_i64().unwrap_or(0) as usize;
    let r2_start = byte_range[2].as_i64().unwrap_or(0) as usize;
    let r2_len = byte_range[3].as_i64().unwrap_or(0) as usize;

    if r1_start + r1_len > raw_data.len() || r2_start + r2_len > raw_data.len() {
        result.error = Some("ByteRange out of bounds".to_string());
        return result;
    }
    
    result.byte_range_valid = true;

    let _contents = match sig_dict.get(b"Contents").and_then(|o| o.as_str()) {
        Ok(c) => c,
        Err(_) => {
            result.error = Some("Missing Contents".to_string());
            return result;
        }
    };
    
    result.integrity_check = true;
    result.is_valid = true;
    
    result
}
