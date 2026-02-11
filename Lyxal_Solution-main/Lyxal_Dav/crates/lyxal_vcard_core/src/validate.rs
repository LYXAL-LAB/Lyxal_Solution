use crate::error::VCardError;
use crate::types::VCard;

pub fn validate(vcard: &VCard) -> Result<(), VCardError> {
    let version = vcard.get_property("VERSION")
        .ok_or_else(|| VCardError::ValidationError("Missing VERSION".into()))?;
        
    if version.value != "3.0" && version.value != "4.0" {
        return Err(VCardError::ValidationError(format!("Unsupported VERSION: {}", version.value)));
    }
    
    if vcard.get_property("FN").is_none() {
        return Err(VCardError::ValidationError("Missing FN".into()));
    }
    
    if vcard.get_property("N").is_none() {
        return Err(VCardError::ValidationError("Missing N".into()));
    }
    
    if vcard.get_property("UID").is_none() {
        return Err(VCardError::ValidationError("Missing UID".into()));
    }
    
    Ok(())
}

