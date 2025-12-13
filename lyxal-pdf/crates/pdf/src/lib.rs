//! Point d’entrée minimal du moteur Lyxal PDF.

use lopdf::Document;

/// Ouvre un PDF à partir d’un buffer en mémoire.
pub fn open_pdf(bytes: &[u8]) -> Result<Document, lopdf::Error> {
    Document::load_mem(bytes)
}

#[cfg(test)]
mod tests {
    use super::open_pdf;
    use lopdf::{dictionary, Document, Object, ObjectId};

    fn build_minimal_pdf_bytes() -> Vec<u8> {
        let mut doc = Document::with_version("1.4");
        let pages_id: ObjectId = doc.new_object_id();
        let page_id: ObjectId = doc.new_object_id();

        // Page minimaliste avec media box et contents vide.
        doc.objects.insert(
            page_id,
            Object::Dictionary(dictionary! {
                "Type" => "Page",
                "Parent" => pages_id,
                "Contents" => Object::Array(vec![]),
                "MediaBox" => Object::Array(vec![0.into(), 0.into(), 100.into(), 100.into()]),
            }),
        );

        // Arbre des pages.
        doc.objects.insert(
            pages_id,
            Object::Dictionary(dictionary! {
                "Type" => "Pages",
                "Kids" => Object::Array(vec![Object::Reference(page_id)]),
                "Count" => Object::Integer(1),
            }),
        );

        // Catalog minimal.
        doc.trailer.set(
            "Root",
            Object::Dictionary(dictionary! {
                "Type" => "Catalog",
                "Pages" => Object::Reference(pages_id),
            }),
        );

        doc.compress();

        let mut buf = Vec::new();
        doc.save_to(&mut buf).expect("save pdf to memory");
        buf
    }

    #[test]
    fn open_valid_pdf_should_succeed() {
        let bytes = build_minimal_pdf_bytes();
        let parsed = open_pdf(&bytes).expect("should parse valid pdf");
        assert_eq!(parsed.version, "1.4");
    }

    #[test]
    fn open_invalid_pdf_should_fail() {
        let err = open_pdf(b"not a pdf").expect_err("should reject invalid pdf");
        let _ = err;
    }
}
