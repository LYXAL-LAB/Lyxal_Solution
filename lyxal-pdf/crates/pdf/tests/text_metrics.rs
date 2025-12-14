use lyxal_pdf::parse_text_elements;
use lopdf::{
    content::{Content, Operation},
    dictionary, Document, Object, ObjectId, Stream,
};

// Ces tests s'appuient sur la police Helvetica référencée mais sans TTF embarqué.
// parse_text_elements applique un fallback si les métriques TTF ne sont pas disponibles,
// mais l'objectif est de vérifier que l'avance horizontale n'est plus nulle et dépend de la taille.

fn make_page_with_ops(ops: Vec<Operation>) -> Document {
    let mut doc = Document::with_version("1.4");
    let pages_id: ObjectId = doc.new_object_id();
    let font_id: ObjectId = doc.new_object_id();
    let catalog_id: ObjectId = doc.new_object_id();
    let page_id: ObjectId = doc.new_object_id();
    let content_id: ObjectId = doc.new_object_id();

    doc.objects.insert(
        font_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Font".to_vec()),
            "Subtype" => Object::Name(b"Type1".to_vec()),
            "BaseFont" => Object::Name(b"Helvetica".to_vec()),
        }),
    );

    let content = Content { operations: ops };
    let encoded = content.encode().expect("encode content");
    doc.objects
        .insert(content_id, Object::Stream(Stream::new(dictionary! {}, encoded)));

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

    doc.objects.insert(
        pages_id,
        Object::Dictionary(dictionary! {
            "Type" => Object::Name(b"Pages".to_vec()),
            "Kids" => Object::Array(vec![Object::Reference(page_id)]),
            "Count" => Object::Integer(1),
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
    doc
}

#[test]
fn test_text_advances_with_ttf() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), 12.into()]),
        Operation::new("Tj", vec![Object::string_literal("Hello")]),
        Operation::new("Tj", vec![Object::string_literal("World")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 2);
    // Le second x doit être plus grand que le premier (avancement appliqué).
    assert!(elems[1].x > elems[0].x);
}

#[test]
fn test_font_size_affects_advance() {
    let ops_small = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), 10.into()]),
        Operation::new("Tj", vec![Object::string_literal("AA")]),
        Operation::new("Tj", vec![Object::string_literal("AA")]),
        Operation::new("ET", vec![]),
    ];
    let doc_small = make_page_with_ops(ops_small);
    let elems_small = parse_text_elements(&doc_small, 0);

    let ops_big = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), 20.into()]),
        Operation::new("Tj", vec![Object::string_literal("AA")]),
        Operation::new("Tj", vec![Object::string_literal("AA")]),
        Operation::new("ET", vec![]),
    ];
    let doc_big = make_page_with_ops(ops_big);
    let elems_big = parse_text_elements(&doc_big, 0);

    assert_eq!(elems_small.len(), 2);
    assert_eq!(elems_big.len(), 2);

    let advance_small = elems_small[1].x - elems_small[0].x;
    let advance_big = elems_big[1].x - elems_big[0].x;

    assert!(advance_big > advance_small);
}

