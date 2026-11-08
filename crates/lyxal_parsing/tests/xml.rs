//! Lecteur XML : entités décodées (A05), chemins, attributs, rejets, XML mal formé, DTD.

use lyxal_parsing::{
    Limits, ReadFailure, RejectionKind, SourceEncoding, XmlOptions, XmlReader, XmlRecord,
};

fn options(elements: &[&str]) -> XmlOptions {
    XmlOptions {
        record_elements: elements.iter().map(|e| e.to_string()).collect(),
        ..Default::default()
    }
}

fn read(source: &[u8], options: XmlOptions) -> Vec<Result<XmlRecord, ReadFailure>> {
    XmlReader::new(source, options).collect()
}

fn codes(items: &[Result<XmlRecord, ReadFailure>]) -> Vec<String> {
    items
        .iter()
        .map(|item| match item {
            Ok(record) => format!("ok:{}", record.position.record),
            Err(failure) => failure.code().to_string(),
        })
        .collect()
}

const BMECAT: &str = r#"<?xml version="1.0" encoding="UTF-8"?>
<BMECAT version="2005">
  <T_NEW_CATALOG>
    <ARTICLE mode="new">
      <SUPPLIER_AID>BA13&amp;co</SUPPLIER_AID>
      <ARTICLE_DETAILS>
        <DESCRIPTION_SHORT lang="fr">Plaque &lt;standard&gt; &#233;paisseur 12,5 &#x2014; &quot;A&quot;</DESCRIPTION_SHORT>
        <DESCRIPTION_LONG><![CDATA[Texte <brut> & non décodé]]></DESCRIPTION_LONG>
        <EAN>3017620422003</EAN>
        <KEYWORD>plâtre</KEYWORD>
        <KEYWORD>cloison</KEYWORD>
        <EMPTY/>
      </ARTICLE_DETAILS>
    </ARTICLE>
    <ARTICLE><SUPPLIER_AID>BA18</SUPPLIER_AID></ARTICLE>
  </T_NEW_CATALOG>
</BMECAT>
"#;

#[test]
fn entities_cdata_attributes_and_paths_are_decoded() {
    // A05 : les entités n'étaient pas décodées et les blocs repérés par recherche de texte
    let items = read(BMECAT.as_bytes(), options(&["ARTICLE"]));
    assert_eq!(codes(&items), vec!["ok:1", "ok:2"]);
    let article = items[0].as_ref().expect("article");
    assert_eq!(article.element, "ARTICLE");
    assert_eq!(article.position.line, Some(4));
    assert_eq!(article.get("@mode"), Some("new"));
    assert_eq!(article.get("SUPPLIER_AID"), Some("BA13&co"));
    assert_eq!(
        article.get("ARTICLE_DETAILS/DESCRIPTION_SHORT"),
        Some("Plaque <standard> épaisseur 12,5 — \"A\"")
    );
    assert_eq!(
        article.get("ARTICLE_DETAILS/DESCRIPTION_SHORT/@lang"),
        Some("fr")
    );
    assert_eq!(
        article.get("ARTICLE_DETAILS/DESCRIPTION_LONG"),
        Some("Texte <brut> & non décodé")
    );
    assert_eq!(
        article
            .get_all("ARTICLE_DETAILS/KEYWORD")
            .collect::<Vec<_>>(),
        vec!["plâtre", "cloison"]
    );
    assert_eq!(article.get("ARTICLE_DETAILS/EMPTY"), Some(""));
    assert_eq!(
        article.get("ARTICLE_DETAILS"),
        None,
        "élément à enfants sans texte propre"
    );
    let second = items[1].as_ref().expect("article");
    assert_eq!(second.get("SUPPLIER_AID"), Some("BA18"));
    assert_eq!(second.position.line, Some(15));
}

#[test]
fn several_record_elements_and_nested_ones() {
    let source = b"<c><PRODUCT id=\"1\"/><ITEM><ITEM>imbriqu\xC3\xA9</ITEM></ITEM></c>";
    let items = read(source, options(&["PRODUCT", "ITEM"]));
    assert_eq!(codes(&items), vec!["ok:1", "ok:2"]);
    assert_eq!(items[0].as_ref().expect("produit").get("@id"), Some("1"));
    assert_eq!(
        items[1].as_ref().expect("article").get("ITEM"),
        Some("imbriqué")
    );
}

#[test]
fn unknown_entity_is_rejected_and_reading_continues() {
    let source = b"<c><A><n>&nbsp;x</n></A><A><n>ok</n></A><A t=\"&inconnue;\"/></c>";
    let items = read(source, options(&["A"]));
    assert_eq!(
        codes(&items),
        vec!["PARSING_XML_ENTITY", "ok:2", "PARSING_XML_ENTITY"]
    );
}

#[test]
fn external_entities_are_never_resolved() {
    let source = br#"<?xml version="1.0"?>
<!DOCTYPE c [ <!ENTITY secret SYSTEM "file:///etc/passwd"> <!ENTITY interne "x"> ]>
<c><A><n>&secret;</n></A><A><n>&interne;</n></A><A><n>sain</n></A></c>"#;
    let items = read(source, options(&["A"]));
    assert_eq!(
        codes(&items),
        vec!["PARSING_XML_ENTITY", "PARSING_XML_ENTITY", "ok:3"]
    );
}

#[test]
fn malformed_xml_stops_reading_with_its_line() {
    let items = read(
        b"<c>\n<A><n>1</n></A>\n<A><n>2</x></A>\n</c>",
        options(&["A"]),
    );
    assert_eq!(codes(&items), vec!["ok:1", "PARSING_SYNTAX"]);
    let Some(Err(ReadFailure::Fatal(error))) = items.last() else {
        panic!("arrêt attendu");
    };
    assert!(error.to_string().contains("ligne 3"), "{error}");

    let items = read(b"<c><A><n>1</n></A>", options(&["A"]));
    assert_eq!(
        codes(&items),
        vec!["ok:1", "PARSING_SYNTAX"],
        "élément racine non fermé"
    );
    let items = read(b"<c><A><n>1</n>", options(&["A"]));
    assert_eq!(
        codes(&items),
        vec!["PARSING_SYNTAX"],
        "enregistrement non fermé"
    );
}

#[test]
fn limits_reject_deep_or_large_records() {
    let limits = Limits {
        max_depth: 3,
        max_fields: 2,
        ..Default::default()
    };
    let opts = XmlOptions {
        limits,
        ..options(&["A"])
    };
    let items = read(
        b"<c><A><b><c><d>x</d></c></b></A><A><b>1</b><c>2</c><d>3</d></A><A><b>ok</b></A></c>",
        opts,
    );
    assert_eq!(
        codes(&items),
        vec!["PARSING_TOO_DEEP", "PARSING_TOO_MANY_FIELDS", "ok:3"]
    );

    let limits = Limits {
        max_record_bytes: 1024,
        ..Default::default()
    };
    let opts = XmlOptions {
        limits,
        ..options(&["A"])
    };
    let mut source = b"<c><A><b>".to_vec();
    source.extend(std::iter::repeat_n(b'x', 512 * 1024));
    source.extend_from_slice(b"</b></A></c>");
    let items = read(&source, opts);
    assert_eq!(codes(&items), vec!["PARSING_LIMIT"]);
}

#[test]
fn declared_encoding_is_used() {
    let opts = XmlOptions {
        encoding: SourceEncoding::Windows1252,
        ..options(&["A"])
    };
    let items = read(
        b"<?xml version=\"1.0\" encoding=\"windows-1252\"?><c><A><p>5 \x80 caf\xE9</p></A></c>",
        opts,
    );
    assert_eq!(
        items[0].as_ref().expect("article").get("p"),
        Some("5 € café")
    );
}

#[test]
fn rejection_kind_codes() {
    assert_eq!(RejectionKind::XmlEntity.code(), "PARSING_XML_ENTITY");
    assert_eq!(RejectionKind::TooDeep.code(), "PARSING_TOO_DEEP");
}

#[test]
fn large_document_is_read_in_a_stream_with_a_small_record_limit() {
    let limits = Limits {
        max_record_bytes: 128,
        ..Default::default()
    };
    let opts = XmlOptions {
        limits,
        ..options(&["A"])
    };
    let mut source = b"<c>".to_vec();
    for i in 0..100_000 {
        source.extend_from_slice(format!("<A><r>REF_{i}</r></A>\n").as_bytes());
    }
    source.extend_from_slice(b"</c>");
    let items = read(&source, opts);
    assert_eq!(items.len(), 100_000);
    assert!(items.iter().all(|item| item.is_ok()));
    assert_eq!(
        items[99_999].as_ref().expect("dernier").position.line,
        Some(100_000)
    );
}

#[test]
fn complete_record_above_the_limit_is_rejected() {
    // Plus grand que la limite mais dans la marge de lecture anticipée : rejeté quand même
    let limits = Limits {
        max_record_bytes: 128,
        ..Default::default()
    };
    let opts = XmlOptions {
        limits,
        ..options(&["A"])
    };
    let source = format!("<c><A><b>{}</b></A><A><b>ok</b></A></c>", "x".repeat(1024));
    let items = read(source.as_bytes(), opts);
    assert_eq!(codes(&items), vec!["PARSING_RECORD_TOO_LARGE", "ok:2"]);
}

#[test]
fn deep_record_is_skipped_without_building_paths() {
    // 50 000 niveaux sous la limite d'octets : rejeté dès la profondeur maximale, le reste est
    // seulement compté (sans coût quadratique)
    let depth = 50_000;
    let mut source = String::from("<c><A>");
    source.push_str(&"<b>".repeat(depth));
    source.push_str(&"</b>".repeat(depth));
    source.push_str("</A><A><b>ok</b></A></c>");
    let started = std::time::Instant::now();
    let items = read(source.as_bytes(), options(&["A"]));
    assert_eq!(codes(&items), vec!["PARSING_TOO_DEEP", "ok:2"]);
    assert!(
        started.elapsed() < std::time::Duration::from_secs(5),
        "{:?}",
        started.elapsed()
    );
}
