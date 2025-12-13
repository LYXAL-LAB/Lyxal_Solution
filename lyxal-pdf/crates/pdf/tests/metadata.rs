use lyxal_pdf::{extract_metadata, page_count};
use lopdf::{dictionary, Document, Object, ObjectId};

fn build_doc_with_pages(count: usize) -> Document {
    let mut doc = Document::with_version("1.4");
    let pages_id: ObjectId = doc.new_object_id();
    let mut kids = Vec::new();

    for _ in 0..count {
        let page_id = doc.new_object_id();
        doc.objects.insert(
            page_id,
            Object::Dictionary(dictionary! {
                "Type" => Object::Name(b"Page".to_vec()),
                "Parent" => pages_id,
                "Contents" => Object::Array(vec![]),
                "MediaBox" => Object::Array(vec![0.into(), 0.into(), 100.into(), 100.into()]),
            }),
        );
        kids.push(Object::Reference(page_id));
    }

    doc.objects.insert(
        pages_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Pages".to_vec()),
            "Kids" => Object::Array(kids),
            "Count" => Object::Integer(count as i64),
        }),
    );

    doc.trailer.set(
        "Root",
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Catalog".to_vec()),
            "Pages" => Object::Reference(pages_id),
        }),
    );

    doc
}

fn build_doc_with_info() -> Document {
    let mut doc = build_doc_with_pages(1);
    doc.trailer.set(
        "Info",
        Object::Dictionary(dictionary! {
            "Title" => Object::string_literal("My Title"),
            "Author" => Object::string_literal("Alice"),
            "Creator" => Object::string_literal("UnitTest"),
            "Producer" => Object::string_literal("lopdf"),
        }),
    );
    doc
}

#[test]
fn test_page_count_single_page() {
    let doc = build_doc_with_pages(1);
    assert_eq!(page_count(&doc), 1);
}

#[test]
fn test_page_count_multiple_pages() {
    let doc = build_doc_with_pages(3);
    assert_eq!(page_count(&doc), 3);
}

#[test]
fn test_metadata_present() {
    let doc = build_doc_with_info();
    let meta = extract_metadata(&doc);
    assert_eq!(meta.title.as_deref(), Some("My Title"));
    assert_eq!(meta.author.as_deref(), Some("Alice"));
    assert_eq!(meta.creator.as_deref(), Some("UnitTest"));
    assert_eq!(meta.producer.as_deref(), Some("lopdf"));
}

#[test]
fn test_metadata_absent() {
    let doc = build_doc_with_pages(1);
    let meta = extract_metadata(&doc);
    assert!(meta.title.is_none());
    assert!(meta.author.is_none());
    assert!(meta.creator.is_none());
    assert!(meta.producer.is_none());
}
