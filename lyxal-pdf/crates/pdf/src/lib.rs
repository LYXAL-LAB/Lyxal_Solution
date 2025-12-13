//! Point d'entree minimal du moteur Lyxal PDF.

mod model;

use lopdf::{Document, Object};
pub use model::{PdfDocument, PdfPage};

/// Metadonnees simples extraites d'un PDF.
pub struct PdfMetadata {
    pub title: Option<String>,
    pub author: Option<String>,
    pub creator: Option<String>,
    pub producer: Option<String>,
}

impl PdfMetadata {
    fn empty() -> Self {
        Self {
            title: None,
            author: None,
            creator: None,
            producer: None,
        }
    }
}

const PAGE_BREAK: &str = "\n\n--- PAGE BREAK ---\n\n";

/// Ouvre un PDF a partir d'un buffer en memoire.
pub fn open_pdf(bytes: &[u8]) -> Result<Document, lopdf::Error> {
    Document::load_mem(bytes)
}

/// Compte le nombre de pages en scannant les objets /Page.
pub fn page_count(doc: &Document) -> usize {
    doc.objects
        .values()
        .filter_map(|obj| obj.as_dict().ok())
        .filter(|dict| {
            dict.get(b"Type")
                .ok()
                .and_then(|t| object_to_name_bytes(doc, t))
                .map(|name| name == b"Page")
                .unwrap_or(false)
        })
        .count()
}

/// Extrait les metadonnees simples du dictionnaire /Info (si present).
pub fn extract_metadata(doc: &Document) -> PdfMetadata {
    let mut meta = PdfMetadata::empty();

    if let Ok(info_obj) = doc.trailer.get(b"Info") {
        if let Some(resolved) = resolve_ref(doc, info_obj) {
            if let Ok(dict) = resolved.as_dict() {
                meta.title = dict.get(b"Title").ok().and_then(|o| object_to_string(doc, o));
                meta.author = dict.get(b"Author").ok().and_then(|o| object_to_string(doc, o));
                meta.creator = dict.get(b"Creator").ok().and_then(|o| object_to_string(doc, o));
                meta.producer = dict.get(b"Producer").ok().and_then(|o| object_to_string(doc, o));
            }
        }
    }

    meta
}

/// Extrait le texte brut de chaque page. Pas de panic en cas d'erreur.
pub fn extract_text_by_page(doc: &Document) -> Vec<String> {
    let pages = doc.get_pages();
    if pages.is_empty() {
        return Vec::new();
    }

    let mut numbers: Vec<u32> = pages.keys().copied().collect();
    numbers.sort_unstable();

    numbers
        .into_iter()
        .map(|page_num| doc.extract_text(&[page_num]).unwrap_or_default())
        .collect()
}

/// Extrait le texte brut du document, avec un separateur clair entre pages.
pub fn extract_text(doc: &Document) -> String {
    let per_page = extract_text_by_page(doc);
    if per_page.is_empty() {
        String::new()
    } else {
        per_page.join(PAGE_BREAK)
    }
}

/// Construit un modele minimal de document avec metadonnees et texte brut par page.
pub fn build_document(doc: &Document) -> PdfDocument {
    let metadata = extract_metadata(doc);
    let pages = extract_text_by_page(doc)
        .into_iter()
        .enumerate()
        .map(|(index, text)| PdfPage { index, text })
        .collect();

    PdfDocument { metadata, pages }
}

fn resolve_ref<'a>(doc: &'a Document, obj: &'a Object) -> Option<&'a Object> {
    match obj {
        Object::Reference(id) => doc.get_object(*id).ok(),
        _ => Some(obj),
    }
}

fn object_to_name_bytes(doc: &Document, obj: &Object) -> Option<Vec<u8>> {
    match obj {
        Object::Name(n) => Some(n.clone()),
        Object::String(bytes, _) => Some(bytes.clone()),
        Object::Reference(id) => doc.get_object(*id).ok().and_then(|o| object_to_name_bytes(doc, o)),
        _ => None,
    }
}

fn object_to_string(doc: &Document, obj: &Object) -> Option<String> {
    match obj {
        Object::String(bytes, _) => String::from_utf8(bytes.clone()).ok(),
        Object::Name(n) => String::from_utf8(n.clone()).ok(),
        Object::Reference(id) => doc.get_object(*id).ok().and_then(|o| object_to_string(doc, o)),
        _ => None,
    }
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
                "Type" => Object::Name(b"Page".to_vec()),
                "Parent" => pages_id,
                "Contents" => Object::Array(vec![]),
                "MediaBox" => Object::Array(vec![0.into(), 0.into(), 100.into(), 100.into()]),
            }),
        );

        // Arbre des pages.
        doc.objects.insert(
            pages_id,
            Object::Dictionary(dictionary! {
                "Type" => Object::Name(b"Pages".to_vec()),
                "Kids" => Object::Array(vec![Object::Reference(page_id)]),
                "Count" => Object::Integer(1),
            }),
        );

        // Catalog minimal.
        doc.trailer.set(
            "Root",
            Object::Dictionary(dictionary! {
                "Type" => Object::Name(b"Catalog".to_vec()),
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
