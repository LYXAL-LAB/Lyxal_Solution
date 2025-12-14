use lyxal_pdf::parse_text_elements;
use lopdf::{
    content::{Content, Operation},
    dictionary, Document, Object, ObjectId, Stream,
};

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
fn test_parse_simple_tj() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), Object::Integer(12)]),
        Operation::new("Td", vec![100.into(), 200.into()]),
        Operation::new("Tj", vec![Object::string_literal("Hello")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);

    let elems = parse_text_elements(&doc, 0);
    assert_eq!(elems.len(), 1);
    assert_eq!(elems[0].content, "Hello");
    assert!((elems[0].x - 100.0).abs() < f32::EPSILON);
    assert!((elems[0].y - 200.0).abs() < f32::EPSILON);
    assert!((elems[0].font_size - 12.0).abs() < f32::EPSILON);
}

#[test]
fn test_parse_multiple_tj_same_page() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), Object::Integer(12)]),
        Operation::new("Td", vec![10.into(), 20.into()]),
        Operation::new("Tj", vec![Object::string_literal("First")]),
        Operation::new("Td", vec![50.into(), 0.into()]),
        Operation::new("Tj", vec![Object::string_literal("Second")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);

    let elems = parse_text_elements(&doc, 0);
    assert_eq!(elems.len(), 2);
    assert_eq!(elems[0].content, "First");
    assert!((elems[0].x - 10.0).abs() < f32::EPSILON);
    assert!((elems[0].y - 20.0).abs() < f32::EPSILON);
    assert!((elems[0].font_size - 12.0).abs() < f32::EPSILON);

    assert_eq!(elems[1].content, "Second");
    assert!(elems[1].x > elems[0].x); // avancement appliqué + Td
    assert!((elems[1].y - 20.0).abs() < f32::EPSILON);
}

#[test]
fn test_tm_absolute_position() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new(
            "Tm",
            vec![1.into(), 0.into(), 0.into(), 1.into(), 100.into(), 200.into()],
        ),
        Operation::new("Tj", vec![Object::string_literal("Hello")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 1);
    assert_eq!(elems[0].content, "Hello");
    assert!((elems[0].x - 100.0).abs() < f32::EPSILON);
    assert!((elems[0].y - 200.0).abs() < f32::EPSILON);
}

#[test]
fn test_td_relative_move() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new(
            "Tm",
            vec![1.into(), 0.into(), 0.into(), 1.into(), 100.into(), 200.into()],
        ),
        Operation::new("Td", vec![10.into(), (-20).into()]),
        Operation::new("Tj", vec![Object::string_literal("Hello")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 1);
    assert_eq!(elems[0].content, "Hello");
    assert!((elems[0].x - 110.0).abs() < f32::EPSILON);
    assert!((elems[0].y - 180.0).abs() < f32::EPSILON);
}

#[test]
fn test_multiple_td() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new(
            "Tm",
            vec![1.into(), 0.into(), 0.into(), 1.into(), 0.into(), 0.into()],
        ),
        Operation::new("Td", vec![10.into(), 5.into()]),
        Operation::new("Tj", vec![Object::string_literal("A")]),
        Operation::new("Td", vec![20.into(), (-5).into()]),
        Operation::new("Tj", vec![Object::string_literal("B")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 2);
    assert_eq!(elems[0].content, "A");
    assert!((elems[0].x - 10.0).abs() < f32::EPSILON);
    assert!((elems[0].y - 5.0).abs() < f32::EPSILON);

    assert_eq!(elems[1].content, "B");
    assert!(elems[1].x > elems[0].x); // avancement + Td
    assert!((elems[1].y - 0.0).abs() < f32::EPSILON); // 5 + (-5)
    assert!((elems[1].font_size - 12.0).abs() < f32::EPSILON);
}

#[test]
fn test_tf_sets_font_size() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new("Tf", vec![Object::Name(b"F1".to_vec()), 18.into()]),
        Operation::new(
            "Tm",
            vec![1.into(), 0.into(), 0.into(), 1.into(), 100.into(), 200.into()],
        ),
        Operation::new("Tj", vec![Object::string_literal("Hello")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 1);
    assert_eq!(elems[0].content, "Hello");
    assert!((elems[0].font_size - 18.0).abs() < f32::EPSILON);
}

#[test]
fn test_font_size_default() {
    let ops = vec![
        Operation::new("BT", vec![]),
        Operation::new(
            "Tm",
            vec![1.into(), 0.into(), 0.into(), 1.into(), 0.into(), 0.into()],
        ),
        Operation::new("Tj", vec![Object::string_literal("Default")]),
        Operation::new("ET", vec![]),
    ];
    let doc = make_page_with_ops(ops);
    let elems = parse_text_elements(&doc, 0);

    assert_eq!(elems.len(), 1);
    assert_eq!(elems[0].content, "Default");
    assert!((elems[0].font_size - 12.0).abs() < f32::EPSILON);
}

