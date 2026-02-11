//! XML Parsing for ODT files
//!
//! Uses quick-xml to parse ODF XML files.

use quick_xml::Reader;
use quick_xml::events::{Event, BytesStart};
use std::collections::HashMap;

use super::model::*;
use crate::parser::{ParseResult, ParseError};

// =============================================================================
// NAMESPACES (ODF)
// =============================================================================

const _NS_OFFICE: &str = "urn:oasis:names:tc:opendocument:xmlns:office:1.0";
const _NS_TEXT: &str = "urn:oasis:names:tc:opendocument:xmlns:text:1.0";
const _NS_TABLE: &str = "urn:oasis:names:tc:opendocument:xmlns:table:1.0";
const _NS_DRAW: &str = "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0";
const _NS_STYLE: &str = "urn:oasis:names:tc:opendocument:xmlns:style:1.0";
const _NS_FO: &str = "urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0";
const _NS_SVG: &str = "urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0";
const _NS_DC: &str = "http://purl.org/dc/elements/1.1/";
const _NS_META: &str = "urn:oasis:names:tc:opendocument:xmlns:meta:1.0";
const _NS_XLINK: &str = "http://www.w3.org/1999/xlink";

// =============================================================================
// METADATA PARSER (meta.xml)
// =============================================================================

pub fn parse_metadata(xml: &str) -> ParseResult<OdtMetadata> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut metadata = OdtMetadata::default();
    let mut buf = Vec::new();
    let mut current_element = String::new();
    let mut in_user_defined = false;
    let mut user_field_name: Option<String> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                current_element = String::from_utf8_lossy(name.as_ref()).to_string();
                
                if current_element == "user-defined" {
                    in_user_defined = true;
                    user_field_name = get_attr(e, b"meta:name")
                        .or_else(|| get_attr(e, b"name"));
                }
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if text.is_empty() {
                    continue;
                }
                
                if in_user_defined {
                    if let Some(ref name) = user_field_name {
                        metadata.user_defined.insert(name.clone(), text);
                    }
                } else {
                    match current_element.as_str() {
                        "title" => metadata.title = Some(text),
                        "description" => metadata.description = Some(text),
                        "subject" => metadata.subject = Some(text),
                        "keyword" => metadata.keywords.push(text),
                        "initial-creator" => metadata.initial_creator = Some(text),
                        "creator" => metadata.creator = Some(text),
                        "creation-date" => metadata.creation_date = Some(text),
                        "date" => metadata.date = Some(text),
                        "language" => metadata.language = Some(text),
                        "generator" => metadata.generator = Some(text),
                        "editing-cycles" => metadata.editing_cycles = text.parse().ok(),
                        "editing-duration" => metadata.editing_duration = Some(text),
                        _ => {}
                    }
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"document-statistic" => {
                        metadata.page_count = get_attr(e, b"meta:page-count")
                            .and_then(|s| s.parse().ok());
                        metadata.word_count = get_attr(e, b"meta:word-count")
                            .and_then(|s| s.parse().ok());
                        metadata.character_count = get_attr(e, b"meta:character-count")
                            .and_then(|s| s.parse().ok());
                        metadata.paragraph_count = get_attr(e, b"meta:paragraph-count")
                            .and_then(|s| s.parse().ok());
                        metadata.table_count = get_attr(e, b"meta:table-count")
                            .and_then(|s| s.parse().ok());
                        metadata.image_count = get_attr(e, b"meta:image-count")
                            .and_then(|s| s.parse().ok());
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                if name.as_ref() == b"user-defined" {
                    in_user_defined = false;
                    user_field_name = None;
                }
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(metadata)
}

// =============================================================================
// STYLES PARSER (styles.xml)
// =============================================================================

pub fn parse_styles(xml: &str) -> ParseResult<(Vec<OdtStyle>, Vec<OdtMasterPage>)> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut styles = Vec::new();
    let mut master_pages = Vec::new();
    let mut buf = Vec::new();
    
    let mut in_styles = false;
    let mut in_master_styles = false;
    let mut current_style: Option<OdtStyle> = None;
    let mut current_master: Option<OdtMasterPage> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"styles" => in_styles = true,
                    b"master-styles" => in_master_styles = true,
                    b"style" if in_styles => {
                        current_style = Some(parse_style_start(e));
                    }
                    b"master-page" if in_master_styles => {
                        current_master = Some(OdtMasterPage {
                            name: get_attr(e, b"style:name").unwrap_or_default(),
                            page_layout_name: get_attr(e, b"style:page-layout-name"),
                            next_style_name: get_attr(e, b"style:next-style-name"),
                            header: None,
                            footer: None,
                            header_first: None,
                            footer_first: None,
                            header_left: None,
                            footer_left: None,
                        });
                    }
                    b"paragraph-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.paragraph_properties = Some(parse_paragraph_properties(e));
                        }
                    }
                    b"text-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.text_properties = Some(parse_text_properties(e));
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"style" if in_styles => {
                        styles.push(parse_style_start(e));
                    }
                    b"paragraph-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.paragraph_properties = Some(parse_paragraph_properties(e));
                        }
                    }
                    b"text-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.text_properties = Some(parse_text_properties(e));
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"styles" => in_styles = false,
                    b"master-styles" => in_master_styles = false,
                    b"style" if current_style.is_some() => {
                        if let Some(style) = current_style.take() {
                            styles.push(style);
                        }
                    }
                    b"master-page" if current_master.is_some() => {
                        if let Some(master) = current_master.take() {
                            master_pages.push(master);
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok((styles, master_pages))
}

fn parse_style_start(e: &BytesStart) -> OdtStyle {
    let family_str = get_attr(e, b"style:family").unwrap_or_default();
    let family = match family_str.as_str() {
        "paragraph" => OdtStyleFamily::Paragraph,
        "text" => OdtStyleFamily::Text,
        "section" => OdtStyleFamily::Section,
        "table" => OdtStyleFamily::Table,
        "table-column" => OdtStyleFamily::TableColumn,
        "table-row" => OdtStyleFamily::TableRow,
        "table-cell" => OdtStyleFamily::TableCell,
        "graphic" => OdtStyleFamily::Graphic,
        _ => OdtStyleFamily::Paragraph,
    };
    
    OdtStyle {
        name: get_attr(e, b"style:name").unwrap_or_default(),
        family,
        parent_style_name: get_attr(e, b"style:parent-style-name"),
        list_style_name: get_attr(e, b"style:list-style-name"),
        master_page_name: get_attr(e, b"style:master-page-name"),
        default_outline_level: get_attr(e, b"style:default-outline-level")
            .and_then(|s| s.parse().ok()),
        paragraph_properties: None,
        text_properties: None,
        table_properties: None,
        table_column_properties: None,
        table_row_properties: None,
        table_cell_properties: None,
        graphic_properties: None,
    }
}

fn parse_paragraph_properties(e: &BytesStart) -> OdtParagraphProperties {
    OdtParagraphProperties {
        text_align: get_attr(e, b"fo:text-align"),
        text_indent: get_attr(e, b"fo:text-indent"),
        margin_left: get_attr(e, b"fo:margin-left"),
        margin_right: get_attr(e, b"fo:margin-right"),
        margin_top: get_attr(e, b"fo:margin-top"),
        margin_bottom: get_attr(e, b"fo:margin-bottom"),
        line_height: get_attr(e, b"fo:line-height")
            .or_else(|| get_attr(e, b"style:line-height")),
        background_color: get_attr(e, b"fo:background-color"),
        border: get_attr(e, b"fo:border"),
        border_top: get_attr(e, b"fo:border-top"),
        border_bottom: get_attr(e, b"fo:border-bottom"),
        border_left: get_attr(e, b"fo:border-left"),
        border_right: get_attr(e, b"fo:border-right"),
        padding: get_attr(e, b"fo:padding"),
        keep_with_next: get_attr(e, b"fo:keep-with-next"),
        keep_together: get_attr(e, b"fo:keep-together"),
        break_before: get_attr(e, b"fo:break-before"),
        break_after: get_attr(e, b"fo:break-after"),
        widows: get_attr(e, b"fo:widows").and_then(|s| s.parse().ok()),
        orphans: get_attr(e, b"fo:orphans").and_then(|s| s.parse().ok()),
        tab_stops: Vec::new(),
        drop_cap: None,
    }
}

fn parse_text_properties(e: &BytesStart) -> OdtTextProperties {
    OdtTextProperties {
        font_name: get_attr(e, b"style:font-name"),
        font_family: get_attr(e, b"fo:font-family"),
        font_size: get_attr(e, b"fo:font-size"),
        font_style: get_attr(e, b"fo:font-style"),
        font_weight: get_attr(e, b"fo:font-weight"),
        font_variant: get_attr(e, b"fo:font-variant"),
        color: get_attr(e, b"fo:color"),
        background_color: get_attr(e, b"fo:background-color"),
        text_decoration: None,
        text_underline_style: get_attr(e, b"style:text-underline-style"),
        text_underline_type: get_attr(e, b"style:text-underline-type"),
        text_underline_color: get_attr(e, b"style:text-underline-color"),
        text_line_through_style: get_attr(e, b"style:text-line-through-style"),
        text_line_through_type: get_attr(e, b"style:text-line-through-type"),
        text_position: get_attr(e, b"style:text-position"),
        text_transform: get_attr(e, b"fo:text-transform"),
        letter_spacing: get_attr(e, b"fo:letter-spacing"),
        language: get_attr(e, b"fo:language"),
        country: get_attr(e, b"fo:country"),
        hyphenate: get_attr(e, b"fo:hyphenate").map(|s| s == "true"),
        text_shadow: get_attr(e, b"fo:text-shadow"),
        text_outline: get_attr(e, b"style:text-outline").map(|s| s == "true"),
    }
}

// =============================================================================
// CONTENT PARSER (content.xml)
// =============================================================================

pub fn parse_content(xml: &str) -> ParseResult<(Vec<OdtElement>, Vec<OdtStyle>, Vec<OdtFontDecl>)> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut elements = Vec::new();
    let mut automatic_styles = Vec::new();
    let mut font_declarations = Vec::new();
    let mut buf = Vec::new();
    
    // State
    let mut in_body = false;
    let mut in_text = false;
    let mut in_automatic_styles = false;
    let mut in_font_face_decls = false;
    let mut in_paragraph = false;
    let mut in_heading = false;
    let mut in_span = false;
    let mut in_list = false;
    let mut in_table = false;
    let mut in_table_row = false;
    let mut in_table_cell = false;
    let mut in_frame = false;
    let mut in_link = false;
    
    let mut current_paragraph = OdtParagraph::default();
    let mut current_heading: Option<OdtHeading> = None;
    let mut current_span: Option<OdtSpan> = None;
    let mut current_list: Option<OdtList> = None;
    let mut current_list_item: Option<OdtListItem> = None;
    let mut current_table: Option<OdtTable> = None;
    let mut current_row: Option<OdtTableRow> = None;
    let mut current_cell: Option<OdtTableCell> = None;
    let mut current_style: Option<OdtStyle> = None;
    let mut current_link: Option<OdtLink> = None;
    
    // Stack for nested lists
    let mut list_stack: Vec<OdtList> = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"automatic-styles" => in_automatic_styles = true,
                    b"font-face-decls" => in_font_face_decls = true,
                    b"body" => in_body = true,
                    b"text" if in_body => in_text = true,
                    
                    // Styles
                    b"style" if in_automatic_styles => {
                        current_style = Some(parse_style_start(e));
                    }
                    
                    // Font declarations
                    b"font-face" if in_font_face_decls => {
                        font_declarations.push(OdtFontDecl {
                            name: get_attr(e, b"style:name").unwrap_or_default(),
                            font_family: get_attr(e, b"svg:font-family"),
                            font_family_generic: get_attr(e, b"style:font-family-generic"),
                            font_pitch: get_attr(e, b"style:font-pitch"),
                            font_charset: get_attr(e, b"style:font-charset"),
                        });
                    }
                    
                    // Paragraphs
                    b"p" if in_text || in_table_cell => {
                        in_paragraph = true;
                        current_paragraph = OdtParagraph {
                            style_name: get_attr(e, b"text:style-name"),
                            content: Vec::new(),
                        };
                    }
                    
                    // Headings
                    b"h" if in_text => {
                        in_heading = true;
                        current_heading = Some(OdtHeading {
                            level: get_attr(e, b"text:outline-level")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1),
                            style_name: get_attr(e, b"text:style-name"),
                            outline_level: get_attr(e, b"text:outline-level")
                                .and_then(|s| s.parse().ok()),
                            content: Vec::new(),
                        });
                    }
                    
                    // Spans
                    b"span" if in_paragraph || in_heading => {
                        in_span = true;
                        current_span = Some(OdtSpan {
                            style_name: get_attr(e, b"text:style-name"),
                            content: Vec::new(),
                        });
                    }
                    
                    // Links
                    b"a" if in_paragraph || in_heading || in_span => {
                        in_link = true;
                        current_link = Some(OdtLink {
                            href: get_attr(e, b"xlink:href").unwrap_or_default(),
                            link_type: get_attr(e, b"xlink:type"),
                            name: get_attr(e, b"office:name"),
                            target_frame: get_attr(e, b"office:target-frame-name"),
                            content: Vec::new(),
                        });
                    }
                    
                    // Lists
                    b"list" if in_text || in_list => {
                        if in_list {
                            // Nested list - push current
                            if let Some(list) = current_list.take() {
                                list_stack.push(list);
                            }
                        }
                        in_list = true;
                        current_list = Some(OdtList {
                            style_name: get_attr(e, b"text:style-name"),
                            continue_list: get_attr(e, b"text:continue-list"),
                            items: Vec::new(),
                        });
                    }
                    
                    b"list-item" if in_list => {
                        current_list_item = Some(OdtListItem {
                            start_value: get_attr(e, b"text:start-value")
                                .and_then(|s| s.parse().ok()),
                            content: Vec::new(),
                        });
                    }
                    
                    // Tables
                    b"table" if in_text || in_table_cell => {
                        in_table = true;
                        current_table = Some(OdtTable {
                            name: get_attr(e, b"table:name"),
                            style_name: get_attr(e, b"table:style-name"),
                            columns: Vec::new(),
                            rows: Vec::new(),
                            header_rows: Vec::new(),
                        });
                    }
                    
                    b"table-row" if in_table => {
                        in_table_row = true;
                        current_row = Some(OdtTableRow {
                            style_name: get_attr(e, b"table:style-name"),
                            cells: Vec::new(),
                            number_rows_repeated: get_attr(e, b"table:number-rows-repeated")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1),
                        });
                    }
                    
                    b"table-cell" if in_table_row => {
                        in_table_cell = true;
                        current_cell = Some(OdtTableCell {
                            style_name: get_attr(e, b"table:style-name"),
                            number_columns_spanned: get_attr(e, b"table:number-columns-spanned")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1),
                            number_rows_spanned: get_attr(e, b"table:number-rows-spanned")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1),
                            content: Vec::new(),
                            covered: false,
                            value: parse_cell_value(e),
                            formula: get_attr(e, b"table:formula"),
                        });
                    }
                    
                    b"covered-table-cell" if in_table_row => {
                        // Covered cell (part of merge)
                        if let Some(ref mut row) = current_row {
                            row.cells.push(OdtTableCell {
                                style_name: None,
                                number_columns_spanned: 1,
                                number_rows_spanned: 1,
                                content: Vec::new(),
                                covered: true,
                                value: None,
                                formula: None,
                            });
                        }
                    }
                    
                    // Frames
                    b"frame" if in_paragraph || in_text => {
                        in_frame = true;
                    }
                    
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    // Self-closing font-face
                    b"font-face" if in_font_face_decls => {
                        font_declarations.push(OdtFontDecl {
                            name: get_attr(e, b"style:name").unwrap_or_default(),
                            font_family: get_attr(e, b"svg:font-family"),
                            font_family_generic: get_attr(e, b"style:font-family-generic"),
                            font_pitch: get_attr(e, b"style:font-pitch"),
                            font_charset: get_attr(e, b"style:font-charset"),
                        });
                    }
                    
                    // Tab
                    b"tab" if in_paragraph || in_heading => {
                        let inline = OdtInline::Tab;
                        add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                    }
                    
                    // Line break
                    b"line-break" if in_paragraph || in_heading => {
                        let inline = OdtInline::LineBreak;
                        add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                    }
                    
                    // Space
                    b"s" if in_paragraph || in_heading => {
                        let count = get_attr(e, b"text:c")
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(1);
                        let inline = OdtInline::Space(count);
                        add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                    }
                    
                    // Soft page break
                    b"soft-page-break" if in_text => {
                        // Ignore soft page breaks
                    }
                    
                    // Table column
                    b"table-column" if in_table => {
                        if let Some(ref mut table) = current_table {
                            table.columns.push(OdtTableColumn {
                                style_name: get_attr(e, b"table:style-name"),
                                number_columns_repeated: get_attr(e, b"table:number-columns-repeated")
                                    .and_then(|s| s.parse().ok())
                                    .unwrap_or(1),
                                default_cell_style: get_attr(e, b"table:default-cell-style-name"),
                            });
                        }
                    }
                    
                    // Covered cell
                    b"covered-table-cell" if in_table_row => {
                        if let Some(ref mut row) = current_row {
                            let repeat = get_attr(e, b"table:number-columns-repeated")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1);
                            for _ in 0..repeat {
                                row.cells.push(OdtTableCell {
                                    style_name: None,
                                    number_columns_spanned: 1,
                                    number_rows_spanned: 1,
                                    content: Vec::new(),
                                    covered: true,
                                    value: None,
                                    formula: None,
                                });
                            }
                        }
                    }
                    
                    // Style properties
                    b"paragraph-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.paragraph_properties = Some(parse_paragraph_properties(e));
                        }
                    }
                    b"text-properties" if current_style.is_some() => {
                        if let Some(ref mut style) = current_style {
                            style.text_properties = Some(parse_text_properties(e));
                        }
                    }
                    
                    // Image in frame
                    b"image" if in_frame => {
                        if let Some(href) = get_attr(e, b"xlink:href") {
                            let inline = OdtInline::Frame(OdtFrame {
                                name: None,
                                style_name: None,
                                anchor_type: OdtAnchorType::AsCharacter,
                                x: None,
                                y: None,
                                width: None,
                                height: None,
                                z_index: None,
                                content: OdtFrameContent::Image(OdtImageRef {
                                    href,
                                    mime_type: None,
                                    alt: None,
                                    title: None,
                                }),
                            });
                            add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                        }
                    }
                    
                    // Bookmark
                    b"bookmark" if in_paragraph || in_heading => {
                        if let Some(name) = get_attr(e, b"text:name") {
                            let inline = OdtInline::Bookmark(OdtBookmark { name, is_start: true });
                            add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                        }
                    }
                    b"bookmark-start" if in_paragraph || in_heading => {
                        if let Some(name) = get_attr(e, b"text:name") {
                            let inline = OdtInline::Bookmark(OdtBookmark { name, is_start: true });
                            add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                        }
                    }
                    b"bookmark-end" if in_paragraph || in_heading => {
                        if let Some(name) = get_attr(e, b"text:name") {
                            let inline = OdtInline::Bookmark(OdtBookmark { name, is_start: false });
                            add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                        }
                    }
                    
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if text.is_empty() {
                    continue;
                }
                
                if in_paragraph || in_heading {
                    let inline = OdtInline::Text(text);
                    add_inline_content(&mut current_paragraph, &mut current_heading, &mut current_span, &mut current_link, inline);
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"automatic-styles" => in_automatic_styles = false,
                    b"font-face-decls" => in_font_face_decls = false,
                    b"body" => in_body = false,
                    b"text" => in_text = false,
                    
                    b"style" if current_style.is_some() => {
                        if let Some(style) = current_style.take() {
                            automatic_styles.push(style);
                        }
                    }
                    
                    b"p" if in_paragraph => {
                        if in_table_cell {
                            if let Some(ref mut cell) = current_cell {
                                cell.content.push(OdtElement::Paragraph(std::mem::take(&mut current_paragraph)));
                            }
                        } else if in_list && current_list_item.is_some() {
                            if let Some(ref mut item) = current_list_item {
                                item.content.push(OdtListContent::Paragraph(std::mem::take(&mut current_paragraph)));
                            }
                        } else {
                            elements.push(OdtElement::Paragraph(std::mem::take(&mut current_paragraph)));
                        }
                        in_paragraph = false;
                    }
                    
                    b"h" if in_heading => {
                        if let Some(heading) = current_heading.take() {
                            if in_list && current_list_item.is_some() {
                                if let Some(ref mut item) = current_list_item {
                                    item.content.push(OdtListContent::Heading(heading));
                                }
                            } else {
                                elements.push(OdtElement::Heading(heading));
                            }
                        }
                        in_heading = false;
                    }
                    
                    b"span" if in_span => {
                        if let Some(span) = current_span.take() {
                            let inline = OdtInline::Span(span);
                            if in_link {
                                if let Some(ref mut link) = current_link {
                                    link.content.push(inline);
                                }
                            } else if in_heading {
                                if let Some(ref mut heading) = current_heading {
                                    heading.content.push(inline);
                                }
                            } else {
                                current_paragraph.content.push(inline);
                            }
                        }
                        in_span = false;
                    }
                    
                    b"a" if in_link => {
                        if let Some(link) = current_link.take() {
                            let inline = OdtInline::Link(link);
                            if in_span {
                                if let Some(ref mut span) = current_span {
                                    span.content.push(inline);
                                }
                            } else if in_heading {
                                if let Some(ref mut heading) = current_heading {
                                    heading.content.push(inline);
                                }
                            } else {
                                current_paragraph.content.push(inline);
                            }
                        }
                        in_link = false;
                    }
                    
                    b"list-item" if current_list_item.is_some() => {
                        if let Some(item) = current_list_item.take() {
                            if let Some(ref mut list) = current_list {
                                list.items.push(item);
                            }
                        }
                    }
                    
                    b"list" if in_list => {
                        if let Some(list) = current_list.take() {
                            if let Some(mut parent_list) = list_stack.pop() {
                                // Nested list - add to parent item
                                if let Some(ref mut item) = current_list_item {
                                    item.content.push(OdtListContent::List(list));
                                }
                                current_list = Some(parent_list);
                            } else {
                                elements.push(OdtElement::List(list));
                                in_list = false;
                            }
                        }
                    }
                    
                    b"table-cell" if in_table_cell => {
                        if let Some(cell) = current_cell.take() {
                            if let Some(ref mut row) = current_row {
                                row.cells.push(cell);
                            }
                        }
                        in_table_cell = false;
                    }
                    
                    b"table-row" if in_table_row => {
                        if let Some(row) = current_row.take() {
                            if let Some(ref mut table) = current_table {
                                table.rows.push(row);
                            }
                        }
                        in_table_row = false;
                    }
                    
                    b"table" if in_table => {
                        if let Some(table) = current_table.take() {
                            elements.push(OdtElement::Table(table));
                        }
                        in_table = false;
                    }
                    
                    b"frame" => {
                        in_frame = false;
                    }
                    
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok((elements, automatic_styles, font_declarations))
}

fn add_inline_content(
    paragraph: &mut OdtParagraph,
    heading: &mut Option<OdtHeading>,
    span: &mut Option<OdtSpan>,
    link: &mut Option<OdtLink>,
    inline: OdtInline,
) {
    if let Some(ref mut l) = link {
        l.content.push(inline);
    } else if let Some(ref mut s) = span {
        s.content.push(inline);
    } else if let Some(ref mut h) = heading {
        h.content.push(inline);
    } else {
        paragraph.content.push(inline);
    }
}

fn parse_cell_value(e: &BytesStart) -> Option<OdtCellValue> {
    let value_type = get_attr(e, b"office:value-type")?;
    
    match value_type.as_str() {
        "float" => {
            let val = get_attr(e, b"office:value")?.parse().ok()?;
            Some(OdtCellValue::Float(val))
        }
        "currency" => {
            let val = get_attr(e, b"office:value")?.parse().ok()?;
            let currency = get_attr(e, b"office:currency").unwrap_or_default();
            Some(OdtCellValue::Currency(val, currency))
        }
        "date" => {
            let val = get_attr(e, b"office:date-value")?;
            Some(OdtCellValue::Date(val))
        }
        "time" => {
            let val = get_attr(e, b"office:time-value")?;
            Some(OdtCellValue::Time(val))
        }
        "boolean" => {
            let val = get_attr(e, b"office:boolean-value")? == "true";
            Some(OdtCellValue::Boolean(val))
        }
        "string" => {
            let val = get_attr(e, b"office:string-value").unwrap_or_default();
            Some(OdtCellValue::String(val))
        }
        "percentage" => {
            let val = get_attr(e, b"office:value")?.parse().ok()?;
            Some(OdtCellValue::Percentage(val))
        }
        _ => None,
    }
}

// =============================================================================
// SETTINGS PARSER (settings.xml)
// =============================================================================

pub fn parse_settings(xml: &str) -> ParseResult<OdtSettings> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut settings = OdtSettings::default();
    let mut buf = Vec::new();
    
    let mut in_view = false;
    let mut in_config = false;
    let mut current_name: Option<String> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"config-item-set" => {
                        let set_name = get_attr(e, b"config:name").unwrap_or_default();
                        if set_name.contains("view") {
                            in_view = true;
                        } else {
                            in_config = true;
                        }
                    }
                    b"config-item" => {
                        current_name = get_attr(e, b"config:name");
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) => {
                if let Some(ref name) = current_name {
                    let value = t.unescape().unwrap_or_default().to_string();
                    if in_view {
                        settings.view_settings.insert(name.clone(), value);
                    } else if in_config {
                        settings.configuration_settings.insert(name.clone(), value);
                    }
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"config-item-set" => {
                        in_view = false;
                        in_config = false;
                    }
                    b"config-item" => {
                        current_name = None;
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(settings)
}

// =============================================================================
// HELPER
// =============================================================================

fn get_attr(e: &BytesStart, name: &[u8]) -> Option<String> {
    e.attributes()
        .flatten()
        .find(|a| a.key.as_ref() == name)
        .map(|a| String::from_utf8_lossy(&a.value).to_string())
}
