use lyxal_pdf::{extract_text, extract_text_by_page};
use lopdf::{content::{Content, Operation}, dictionary, Document, Object, ObjectId, Stream};

const PAGE_BREAK: &str = "\n\n--- PAGE BREAK ---\n\n";

fn build_doc_with_texts(texts: &[&str]) -> Document {
    let mut doc = Document::with_version("1.4");
    let pages_id: ObjectId = doc.new_object_id();
    let font_id: ObjectId = doc.new_object_id();
    let catalog_id: ObjectId = doc.new_object_id();

    // Police standard Type1 (Helvetica).
    doc.objects.insert(
        font_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Font".to_vec()),
            "Subtype" => Object::Name(b"Type1".to_vec()),
            "BaseFont" => Object::Name(b"Helvetica".to_vec()),
        }),
    );

    let mut kids = Vec::new();

    for text in texts {
        let page_id = doc.new_object_id();
        let content_id = doc.new_object_id();

        let mut content = Content { operations: Vec::new() };
        content.operations.push(Operation::new("BT", vec![]));
        content.operations.push(Operation::new(
            "Tf",
            vec![Object::Name(b"F1".to_vec()), Object::Integer(12)],
        ));
        content.operations.push(Operation::new("Td", vec![50.into(), 700.into()]));
        content.operations.push(Operation::new(
            "Tj",
            vec![Object::string_literal((*text).to_string())],
        ));
        content.operations.push(Operation::new("ET", vec![]));

        let encoded = content.encode().expect("encode content");
        doc.objects.insert(
            content_id,
            Object::Stream(Stream::new(dictionary! {}, encoded)),
        );

        doc.objects.insert(
            page_id,
            Object::Dictionary(dictionary! {
                "Type" => Object::Name(b"Page".to_vec()),
                "Parent" => pages_id,
                "Contents" => Object::Reference(content_id),
                "Resources" => Object::Dictionary(dictionary! {
                    "Font" => Object::Dictionary(dictionary! {
                        "F1" => Object::Reference(font_id),
                    }),
                }),
                "MediaBox" => Object::Array(vec![0.into(), 0.into(), 300.into(), 300.into()]),
            }),
        );

        kids.push(Object::Reference(page_id));
    }

    doc.objects.insert(
        pages_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Pages".to_vec()),
            "Kids" => Object::Array(kids),
            "Count" => Object::Integer(texts.len() as i64),
        }),
    );

    doc.objects.insert(
        catalog_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Catalog".to_vec()),
            "Pages" => Object::Reference(pages_id),
        }),
    );

    doc.trailer.set("Root", Object::Reference(catalog_id));

    doc.compress();
    doc
}

#[test]
fn test_extract_text_simple() {
    let doc = build_doc_with_texts(&["Hello PDF"]);
    let txt = extract_text(&doc);
    assert!(txt.contains("Hello PDF"));
    assert!(!txt.contains(PAGE_BREAK));
}

#[test]
fn test_extract_text_multi_page() {
    let doc = build_doc_with_texts(&["Page One", "Page Two"]);
    let txt = extract_text(&doc);
    assert!(txt.contains(PAGE_BREAK));

    let pages = extract_text_by_page(&doc);
    assert_eq!(pages.len(), 2);
    assert!(pages[0].contains("Page One"));
    assert!(pages[1].contains("Page Two"));
}

#[test]
fn test_extract_text_no_text() {
    let doc = build_doc_with_texts(&[""]);
    let txt = extract_text(&doc);
    assert!(txt.trim().is_empty());

    let pages = extract_text_by_page(&doc);
    assert_eq!(pages.len(), 1);
    assert!(pages[0].trim().is_empty());
}
