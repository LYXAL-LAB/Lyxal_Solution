//! XML Parsing for XLSX files (SpreadsheetML)
//!
//! Uses quick-xml to parse Office Open XML for Excel.

use quick_xml::Reader;
use quick_xml::events::{Event, BytesStart};
use std::collections::HashMap;

use super::model::*;
use crate::parser::{ParseResult, ParseError};

// =============================================================================
// RELATIONSHIPS
// =============================================================================

pub fn parse_relationships(xml: &str) -> ParseResult<Vec<XlsxRelationship>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut rels = Vec::new();
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Empty(ref e)) | Ok(Event::Start(ref e)) => {
                if e.local_name().as_ref() == b"Relationship" {
                    if let (Some(id), Some(rel_type), Some(target)) = (
                        get_attr(e, b"Id"),
                        get_attr(e, b"Type"),
                        get_attr(e, b"Target"),
                    ) {
                        let parsed_type = parse_rel_type(&rel_type);
                        rels.push(XlsxRelationship {
                            id,
                            rel_type: parsed_type,
                            target,
                            target_mode: get_attr(e, b"TargetMode"),
                        });
                    }
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(rels)
}

fn parse_rel_type(type_str: &str) -> XlsxRelType {
    if type_str.contains("worksheet") {
        XlsxRelType::Worksheet
    } else if type_str.contains("sharedStrings") {
        XlsxRelType::SharedStrings
    } else if type_str.contains("styles") {
        XlsxRelType::Styles
    } else if type_str.contains("theme") {
        XlsxRelType::Theme
    } else if type_str.contains("drawing") {
        XlsxRelType::Drawing
    } else if type_str.contains("chart") {
        XlsxRelType::Chart
    } else if type_str.contains("image") {
        XlsxRelType::Image
    } else if type_str.contains("hyperlink") {
        XlsxRelType::Hyperlink
    } else if type_str.contains("comments") {
        XlsxRelType::Comments
    } else if type_str.contains("table") {
        XlsxRelType::Table
    } else if type_str.contains("vmlDrawing") {
        XlsxRelType::VmlDrawing
    } else {
        XlsxRelType::Other(type_str.to_string())
    }
}

// =============================================================================
// METADATA
// =============================================================================

pub fn parse_core_metadata(xml: &str, metadata: &mut XlsxMetadata) -> ParseResult<()> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut buf = Vec::new();
    let mut current_element = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                current_element = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if text.is_empty() { continue; }
                
                match current_element.as_str() {
                    "title" => metadata.title = Some(text),
                    "subject" => metadata.subject = Some(text),
                    "creator" => metadata.author = Some(text),
                    "description" => metadata.description = Some(text),
                    "keywords" => metadata.keywords = text.split(',').map(|s| s.trim().to_string()).collect(),
                    "category" => metadata.category = Some(text),
                    "created" => metadata.created = Some(text),
                    "modified" => metadata.modified = Some(text),
                    "lastModifiedBy" => metadata.last_modified_by = Some(text),
                    "revision" => metadata.revision = text.parse().ok(),
                    _ => {}
                }
            }
            Ok(Event::End(_)) => {
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(())
}

pub fn parse_app_metadata(xml: &str, metadata: &mut XlsxMetadata) {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut buf = Vec::new();
    let mut current_element = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                current_element = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if text.is_empty() { continue; }
                
                match current_element.as_str() {
                    "Application" => metadata.application = Some(text),
                    "AppVersion" => metadata.app_version = Some(text),
                    _ => {}
                }
            }
            Ok(Event::End(_)) => {
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            _ => {}
        }
        buf.clear();
    }
}

// =============================================================================
// WORKBOOK
// =============================================================================

pub fn parse_workbook(xml: &str) -> ParseResult<(Vec<(String, u32, XlsxSheetState, String)>, Vec<XlsxDefinedName>)> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut sheets = Vec::new();
    let mut defined_names = Vec::new();
    let mut buf = Vec::new();
    
    let mut in_defined_names = false;
    let mut current_name: Option<(String, Option<u32>, bool)> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"definedNames" => in_defined_names = true,
                    b"definedName" if in_defined_names => {
                        let name = get_attr(e, b"name").unwrap_or_default();
                        let sheet_id = get_attr(e, b"localSheetId").and_then(|s| s.parse().ok());
                        let hidden = get_attr(e, b"hidden").map(|s| s == "1").unwrap_or(false);
                        current_name = Some((name, sheet_id, hidden));
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                if e.local_name().as_ref() == b"sheet" {
                    let name = get_attr(e, b"name").unwrap_or_default();
                    let sheet_id = get_attr(e, b"sheetId")
                        .and_then(|s| s.parse().ok())
                        .unwrap_or(0);
                    let state = match get_attr(e, b"state").as_deref() {
                        Some("hidden") => XlsxSheetState::Hidden,
                        Some("veryHidden") => XlsxSheetState::VeryHidden,
                        _ => XlsxSheetState::Visible,
                    };
                    let rel_id = get_attr(e, b"r:id").unwrap_or_default();
                    sheets.push((name, sheet_id, state, rel_id));
                }
            }
            Ok(Event::Text(ref t)) => {
                if let Some((name, sheet_id, hidden)) = current_name.take() {
                    let value = t.unescape().unwrap_or_default().to_string();
                    defined_names.push(XlsxDefinedName {
                        name,
                        value,
                        sheet_id,
                        hidden,
                        comment: None,
                        function: false,
                        vb_procedure: false,
                    });
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"definedNames" => in_defined_names = false,
                    b"definedName" => current_name = None,
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok((sheets, defined_names))
}

// =============================================================================
// SHARED STRINGS
// =============================================================================

pub fn parse_shared_strings(xml: &str) -> ParseResult<Vec<XlsxSharedString>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut strings = Vec::new();
    let mut buf = Vec::new();
    
    let mut in_si = false;
    let mut current_text = String::new();
    let mut current_runs: Vec<XlsxRichTextRun> = Vec::new();
    let mut in_r = false;
    let mut current_run_text = String::new();
    let mut current_run_props: Option<XlsxRunProperties> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"si" => {
                        in_si = true;
                        current_text.clear();
                        current_runs.clear();
                    }
                    b"r" if in_si => {
                        in_r = true;
                        current_run_text.clear();
                        current_run_props = None;
                    }
                    b"rPr" if in_r => {
                        current_run_props = Some(XlsxRunProperties::default());
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                if let Some(ref mut props) = current_run_props {
                    match e.local_name().as_ref() {
                        b"b" => props.bold = Some(get_attr(e, b"val").map(|s| s != "0").unwrap_or(true)),
                        b"i" => props.italic = Some(get_attr(e, b"val").map(|s| s != "0").unwrap_or(true)),
                        b"u" => props.underline = Some(get_attr(e, b"val").unwrap_or_else(|| "single".to_string())),
                        b"strike" => props.strike = Some(get_attr(e, b"val").map(|s| s != "0").unwrap_or(true)),
                        b"sz" => props.font_size = get_attr(e, b"val").and_then(|s| s.parse().ok()),
                        b"rFont" => props.font_name = get_attr(e, b"val"),
                        b"family" => props.font_family = get_attr(e, b"val").and_then(|s| s.parse().ok()),
                        b"color" => {
                            props.color = Some(XlsxColor {
                                rgb: get_attr(e, b"rgb"),
                                theme: get_attr(e, b"theme").and_then(|s| s.parse().ok()),
                                tint: get_attr(e, b"tint").and_then(|s| s.parse().ok()),
                                indexed: get_attr(e, b"indexed").and_then(|s| s.parse().ok()),
                                auto: get_attr(e, b"auto").map(|s| s == "1").unwrap_or(false),
                            });
                        }
                        _ => {}
                    }
                }
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if in_r {
                    current_run_text.push_str(&text);
                } else if in_si {
                    current_text.push_str(&text);
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"si" => {
                        if current_runs.is_empty() {
                            strings.push(XlsxSharedString {
                                text: Some(current_text.clone()),
                                rich_text: None,
                            });
                        } else {
                            strings.push(XlsxSharedString {
                                text: None,
                                rich_text: Some(std::mem::take(&mut current_runs)),
                            });
                        }
                        in_si = false;
                    }
                    b"r" if in_r => {
                        current_runs.push(XlsxRichTextRun {
                            text: std::mem::take(&mut current_run_text),
                            properties: current_run_props.take(),
                        });
                        in_r = false;
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
    
    Ok(strings)
}

// =============================================================================
// STYLES
// =============================================================================

pub fn parse_styles(xml: &str) -> ParseResult<XlsxStyles> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut styles = XlsxStyles::default();
    let mut buf = Vec::new();
    
    let mut in_fonts = false;
    let mut in_fills = false;
    let mut in_borders = false;
    let mut in_cell_xfs = false;
    let mut in_num_fmts = false;
    
    let mut current_font: Option<XlsxFont> = None;
    let mut current_fill: Option<XlsxFill> = None;
    let mut current_border: Option<XlsxBorder> = None;
    let mut current_xf: Option<XlsxCellXf> = None;
    let mut current_border_side: Option<(String, XlsxBorderSide)> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"numFmts" => in_num_fmts = true,
                    b"fonts" => in_fonts = true,
                    b"fills" => in_fills = true,
                    b"borders" => in_borders = true,
                    b"cellXfs" => in_cell_xfs = true,
                    b"font" if in_fonts => {
                        current_font = Some(XlsxFont::default());
                    }
                    b"fill" if in_fills => {
                        current_fill = Some(XlsxFill {
                            pattern_type: None,
                            foreground_color: None,
                            background_color: None,
                            gradient: None,
                        });
                    }
                    b"border" if in_borders => {
                        current_border = Some(XlsxBorder::default());
                    }
                    b"xf" if in_cell_xfs => {
                        current_xf = Some(XlsxCellXf {
                            num_fmt_id: get_attr(e, b"numFmtId").and_then(|s| s.parse().ok()),
                            font_id: get_attr(e, b"fontId").and_then(|s| s.parse().ok()),
                            fill_id: get_attr(e, b"fillId").and_then(|s| s.parse().ok()),
                            border_id: get_attr(e, b"borderId").and_then(|s| s.parse().ok()),
                            xf_id: get_attr(e, b"xfId").and_then(|s| s.parse().ok()),
                            apply_number_format: get_attr(e, b"applyNumberFormat").map(|s| s == "1").unwrap_or(false),
                            apply_font: get_attr(e, b"applyFont").map(|s| s == "1").unwrap_or(false),
                            apply_fill: get_attr(e, b"applyFill").map(|s| s == "1").unwrap_or(false),
                            apply_border: get_attr(e, b"applyBorder").map(|s| s == "1").unwrap_or(false),
                            apply_alignment: get_attr(e, b"applyAlignment").map(|s| s == "1").unwrap_or(false),
                            apply_protection: get_attr(e, b"applyProtection").map(|s| s == "1").unwrap_or(false),
                            alignment: None,
                            protection: None,
                        });
                    }
                    b"left" | b"right" | b"top" | b"bottom" | b"diagonal" if current_border.is_some() => {
                        let side_name = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
                        current_border_side = Some((side_name, XlsxBorderSide {
                            style: get_attr(e, b"style"),
                            color: None,
                        }));
                    }
                    b"patternFill" if current_fill.is_some() => {
                        if let Some(ref mut fill) = current_fill {
                            fill.pattern_type = get_attr(e, b"patternType");
                        }
                    }
                    b"alignment" if current_xf.is_some() => {
                        if let Some(ref mut xf) = current_xf {
                            xf.alignment = Some(XlsxAlignment {
                                horizontal: get_attr(e, b"horizontal"),
                                vertical: get_attr(e, b"vertical"),
                                text_rotation: get_attr(e, b"textRotation").and_then(|s| s.parse().ok()),
                                wrap_text: get_attr(e, b"wrapText").map(|s| s == "1").unwrap_or(false),
                                shrink_to_fit: get_attr(e, b"shrinkToFit").map(|s| s == "1").unwrap_or(false),
                                indent: get_attr(e, b"indent").and_then(|s| s.parse().ok()),
                                reading_order: get_attr(e, b"readingOrder").and_then(|s| s.parse().ok()),
                            });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"numFmt" if in_num_fmts => {
                        if let (Some(id), Some(code)) = (
                            get_attr(e, b"numFmtId").and_then(|s| s.parse().ok()),
                            get_attr(e, b"formatCode"),
                        ) {
                            styles.number_formats.push(XlsxNumberFormat {
                                id,
                                format_code: code,
                            });
                        }
                    }
                    b"b" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.bold = get_attr(e, b"val").map(|s| s != "0").unwrap_or(true);
                        }
                    }
                    b"i" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.italic = get_attr(e, b"val").map(|s| s != "0").unwrap_or(true);
                        }
                    }
                    b"u" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.underline = Some(get_attr(e, b"val").unwrap_or_else(|| "single".to_string()));
                        }
                    }
                    b"strike" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.strike = get_attr(e, b"val").map(|s| s != "0").unwrap_or(true);
                        }
                    }
                    b"sz" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.size = get_attr(e, b"val").and_then(|s| s.parse().ok());
                        }
                    }
                    b"name" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.name = get_attr(e, b"val");
                        }
                    }
                    b"family" if current_font.is_some() => {
                        if let Some(ref mut font) = current_font {
                            font.family = get_attr(e, b"val").and_then(|s| s.parse().ok());
                        }
                    }
                    b"color" => {
                        let color = XlsxColor {
                            rgb: get_attr(e, b"rgb"),
                            theme: get_attr(e, b"theme").and_then(|s| s.parse().ok()),
                            tint: get_attr(e, b"tint").and_then(|s| s.parse().ok()),
                            indexed: get_attr(e, b"indexed").and_then(|s| s.parse().ok()),
                            auto: get_attr(e, b"auto").map(|s| s == "1").unwrap_or(false),
                        };
                        
                        if let Some((ref side, ref mut bs)) = current_border_side {
                            bs.color = Some(color);
                        } else if let Some(ref mut font) = current_font {
                            font.color = Some(color);
                        }
                    }
                    b"fgColor" if current_fill.is_some() => {
                        if let Some(ref mut fill) = current_fill {
                            fill.foreground_color = Some(XlsxColor {
                                rgb: get_attr(e, b"rgb"),
                                theme: get_attr(e, b"theme").and_then(|s| s.parse().ok()),
                                tint: get_attr(e, b"tint").and_then(|s| s.parse().ok()),
                                indexed: get_attr(e, b"indexed").and_then(|s| s.parse().ok()),
                                auto: get_attr(e, b"auto").map(|s| s == "1").unwrap_or(false),
                            });
                        }
                    }
                    b"bgColor" if current_fill.is_some() => {
                        if let Some(ref mut fill) = current_fill {
                            fill.background_color = Some(XlsxColor {
                                rgb: get_attr(e, b"rgb"),
                                theme: get_attr(e, b"theme").and_then(|s| s.parse().ok()),
                                tint: get_attr(e, b"tint").and_then(|s| s.parse().ok()),
                                indexed: get_attr(e, b"indexed").and_then(|s| s.parse().ok()),
                                auto: get_attr(e, b"auto").map(|s| s == "1").unwrap_or(false),
                            });
                        }
                    }
                    b"alignment" if current_xf.is_some() => {
                        if let Some(ref mut xf) = current_xf {
                            xf.alignment = Some(XlsxAlignment {
                                horizontal: get_attr(e, b"horizontal"),
                                vertical: get_attr(e, b"vertical"),
                                text_rotation: get_attr(e, b"textRotation").and_then(|s| s.parse().ok()),
                                wrap_text: get_attr(e, b"wrapText").map(|s| s == "1").unwrap_or(false),
                                shrink_to_fit: get_attr(e, b"shrinkToFit").map(|s| s == "1").unwrap_or(false),
                                indent: get_attr(e, b"indent").and_then(|s| s.parse().ok()),
                                reading_order: get_attr(e, b"readingOrder").and_then(|s| s.parse().ok()),
                            });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"numFmts" => in_num_fmts = false,
                    b"fonts" => in_fonts = false,
                    b"fills" => in_fills = false,
                    b"borders" => in_borders = false,
                    b"cellXfs" => in_cell_xfs = false,
                    b"font" if current_font.is_some() => {
                        styles.fonts.push(current_font.take().unwrap());
                    }
                    b"fill" if current_fill.is_some() => {
                        styles.fills.push(current_fill.take().unwrap());
                    }
                    b"border" if current_border.is_some() => {
                        styles.borders.push(current_border.take().unwrap());
                    }
                    b"xf" if current_xf.is_some() => {
                        styles.cell_xfs.push(current_xf.take().unwrap());
                    }
                    b"left" | b"right" | b"top" | b"bottom" | b"diagonal" if current_border_side.is_some() => {
                        if let (Some(ref mut border), Some((side_name, bs))) = (&mut current_border, current_border_side.take()) {
                            match side_name.as_str() {
                                "left" => border.left = Some(bs),
                                "right" => border.right = Some(bs),
                                "top" => border.top = Some(bs),
                                "bottom" => border.bottom = Some(bs),
                                "diagonal" => border.diagonal = Some(bs),
                                _ => {}
                            }
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
    
    Ok(styles)
}

// =============================================================================
// THEME
// =============================================================================

pub fn parse_theme(xml: &str) -> ParseResult<Option<XlsxTheme>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut theme = XlsxTheme::default();
    let mut buf = Vec::new();
    
    let mut in_clr_scheme = false;
    let mut current_color_name: Option<String> = None;
    let mut in_font_scheme = false;
    let mut in_major_font = false;
    let mut in_minor_font = false;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"theme" => {
                        theme.name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"clrScheme" => in_clr_scheme = true,
                    b"fontScheme" => in_font_scheme = true,
                    b"majorFont" => in_major_font = true,
                    b"minorFont" => in_minor_font = true,
                    b"dk1" | b"lt1" | b"dk2" | b"lt2" |
                    b"accent1" | b"accent2" | b"accent3" | b"accent4" | b"accent5" | b"accent6" |
                    b"hlink" | b"folHlink" if in_clr_scheme => {
                        current_color_name = Some(String::from_utf8_lossy(e.local_name().as_ref()).to_string());
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"srgbClr" if current_color_name.is_some() => {
                        if let Some(val) = get_attr(e, b"val") {
                            if let Some(ref name) = current_color_name {
                                theme.color_scheme.insert(name.clone(), val);
                            }
                        }
                    }
                    b"sysClr" if current_color_name.is_some() => {
                        if let Some(val) = get_attr(e, b"lastClr") {
                            if let Some(ref name) = current_color_name {
                                theme.color_scheme.insert(name.clone(), val);
                            }
                        }
                    }
                    b"latin" if in_font_scheme => {
                        if let Some(typeface) = get_attr(e, b"typeface") {
                            if in_major_font {
                                theme.font_scheme_major = typeface;
                            } else if in_minor_font {
                                theme.font_scheme_minor = typeface;
                            }
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"clrScheme" => in_clr_scheme = false,
                    b"fontScheme" => in_font_scheme = false,
                    b"majorFont" => in_major_font = false,
                    b"minorFont" => in_minor_font = false,
                    b"dk1" | b"lt1" | b"dk2" | b"lt2" |
                    b"accent1" | b"accent2" | b"accent3" | b"accent4" | b"accent5" | b"accent6" |
                    b"hlink" | b"folHlink" => {
                        current_color_name = None;
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
    
    Ok(Some(theme))
}

// =============================================================================
// SHEET
// =============================================================================

pub fn parse_sheet(
    xml: &str,
    name: String,
    sheet_id: u32,
    state: XlsxSheetState,
    _rels: &[XlsxRelationship],
) -> ParseResult<XlsxSheet> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut sheet = XlsxSheet {
        name,
        sheet_id,
        state,
        rows: Vec::new(),
        merge_cells: Vec::new(),
        columns: Vec::new(),
        properties: XlsxSheetProperties::default(),
        views: Vec::new(),
        protection: None,
        data_validations: Vec::new(),
        auto_filter: None,
        hyperlinks: Vec::new(),
        tables: Vec::new(),
        charts: Vec::new(),
        drawings: Vec::new(),
        comments: Vec::new(),
        page_setup: None,
        page_margins: None,
        header_footer: None,
        print_options: None,
    };
    
    let mut buf = Vec::new();
    let mut current_row: Option<XlsxRow> = None;
    let mut current_cell: Option<XlsxCell> = None;
    let mut cell_value_text = String::new();
    let mut cell_formula_text = String::new();
    let mut in_v = false;
    let mut in_f = false;
    let mut in_is = false;
    let mut inline_string = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"row" => {
                        let row_index = get_attr(e, b"r")
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(0);
                        current_row = Some(XlsxRow {
                            row_index,
                            cells: Vec::new(),
                            height: get_attr(e, b"ht").and_then(|s| s.parse().ok()),
                            custom_height: get_attr(e, b"customHeight").map(|s| s == "1").unwrap_or(false),
                            hidden: get_attr(e, b"hidden").map(|s| s == "1").unwrap_or(false),
                            outline_level: get_attr(e, b"outlineLevel").and_then(|s| s.parse().ok()).unwrap_or(0),
                            collapsed: get_attr(e, b"collapsed").map(|s| s == "1").unwrap_or(false),
                            style_index: get_attr(e, b"s").and_then(|s| s.parse().ok()),
                        });
                    }
                    b"c" if current_row.is_some() => {
                        let reference = get_attr(e, b"r").unwrap_or_default();
                        let cell_type = match get_attr(e, b"t").as_deref() {
                            Some("s") => XlsxCellType::SharedString,
                            Some("str") => XlsxCellType::String,
                            Some("inlineStr") => XlsxCellType::InlineString,
                            Some("b") => XlsxCellType::Boolean,
                            Some("e") => XlsxCellType::Error,
                            Some("d") => XlsxCellType::Date,
                            _ => XlsxCellType::Number,
                        };
                        current_cell = Some(XlsxCell {
                            reference,
                            cell_type,
                            value: XlsxCellValue::Empty,
                            formula: None,
                            style_index: get_attr(e, b"s").and_then(|s| s.parse().ok()),
                            metadata: None,
                        });
                        cell_value_text.clear();
                        cell_formula_text.clear();
                    }
                    b"v" if current_cell.is_some() => {
                        in_v = true;
                    }
                    b"f" if current_cell.is_some() => {
                        in_f = true;
                        if let Some(ref mut cell) = current_cell {
                            let formula_type = match get_attr(e, b"t").as_deref() {
                                Some("shared") => XlsxFormulaType::Shared,
                                Some("array") => XlsxFormulaType::Array,
                                Some("dataTable") => XlsxFormulaType::DataTable,
                                _ => XlsxFormulaType::Normal,
                            };
                            cell.formula = Some(XlsxFormula {
                                formula: String::new(),
                                formula_type,
                                shared_index: get_attr(e, b"si").and_then(|s| s.parse().ok()),
                                ref_cell: get_attr(e, b"ref"),
                                calculated: get_attr(e, b"ca").map(|s| s == "1").unwrap_or(false),
                            });
                        }
                    }
                    b"is" if current_cell.is_some() => {
                        in_is = true;
                        inline_string.clear();
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"col" => {
                        sheet.columns.push(XlsxColumn {
                            min: get_attr(e, b"min").and_then(|s| s.parse().ok()).unwrap_or(1),
                            max: get_attr(e, b"max").and_then(|s| s.parse().ok()).unwrap_or(1),
                            width: get_attr(e, b"width").and_then(|s| s.parse().ok()).unwrap_or(8.43),
                            style_index: get_attr(e, b"style").and_then(|s| s.parse().ok()),
                            hidden: get_attr(e, b"hidden").map(|s| s == "1").unwrap_or(false),
                            best_fit: get_attr(e, b"bestFit").map(|s| s == "1").unwrap_or(false),
                            outline_level: get_attr(e, b"outlineLevel").and_then(|s| s.parse().ok()).unwrap_or(0),
                            collapsed: get_attr(e, b"collapsed").map(|s| s == "1").unwrap_or(false),
                        });
                    }
                    b"mergeCell" => {
                        if let Some(reference) = get_attr(e, b"ref") {
                            sheet.merge_cells.push(XlsxMergeCell { reference });
                        }
                    }
                    b"hyperlink" => {
                        sheet.hyperlinks.push(XlsxHyperlink {
                            reference: get_attr(e, b"ref").unwrap_or_default(),
                            rel_id: get_attr(e, b"r:id"),
                            location: get_attr(e, b"location"),
                            display: get_attr(e, b"display"),
                            tooltip: get_attr(e, b"tooltip"),
                        });
                    }
                    b"pageMargins" => {
                        sheet.page_margins = Some(XlsxPageMargins {
                            left: get_attr(e, b"left").and_then(|s| s.parse().ok()).unwrap_or(0.7),
                            right: get_attr(e, b"right").and_then(|s| s.parse().ok()).unwrap_or(0.7),
                            top: get_attr(e, b"top").and_then(|s| s.parse().ok()).unwrap_or(0.75),
                            bottom: get_attr(e, b"bottom").and_then(|s| s.parse().ok()).unwrap_or(0.75),
                            header: get_attr(e, b"header").and_then(|s| s.parse().ok()).unwrap_or(0.3),
                            footer: get_attr(e, b"footer").and_then(|s| s.parse().ok()).unwrap_or(0.3),
                        });
                    }
                    b"pageSetup" => {
                        sheet.page_setup = Some(XlsxPageSetup {
                            paper_size: get_attr(e, b"paperSize").and_then(|s| s.parse().ok()),
                            scale: get_attr(e, b"scale").and_then(|s| s.parse().ok()),
                            fit_to_width: get_attr(e, b"fitToWidth").and_then(|s| s.parse().ok()),
                            fit_to_height: get_attr(e, b"fitToHeight").and_then(|s| s.parse().ok()),
                            orientation: get_attr(e, b"orientation"),
                            use_first_page_number: get_attr(e, b"useFirstPageNumber").map(|s| s == "1").unwrap_or(false),
                            first_page_number: get_attr(e, b"firstPageNumber").and_then(|s| s.parse().ok()),
                            horizontal_dpi: get_attr(e, b"horizontalDpi").and_then(|s| s.parse().ok()),
                            vertical_dpi: get_attr(e, b"verticalDpi").and_then(|s| s.parse().ok()),
                            black_and_white: get_attr(e, b"blackAndWhite").map(|s| s == "1").unwrap_or(false),
                            draft: get_attr(e, b"draft").map(|s| s == "1").unwrap_or(false),
                            cell_comments: get_attr(e, b"cellComments"),
                            page_order: get_attr(e, b"pageOrder"),
                        });
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if in_v {
                    cell_value_text.push_str(&text);
                } else if in_f {
                    cell_formula_text.push_str(&text);
                } else if in_is {
                    inline_string.push_str(&text);
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"row" if current_row.is_some() => {
                        sheet.rows.push(current_row.take().unwrap());
                    }
                    b"c" if current_cell.is_some() => {
                        let mut cell = current_cell.take().unwrap();
                        
                        // Set cell value based on type
                        if !cell_value_text.is_empty() {
                            cell.value = match cell.cell_type {
                                XlsxCellType::SharedString => {
                                    if let Ok(idx) = cell_value_text.parse::<u32>() {
                                        XlsxCellValue::SharedString(idx)
                                    } else {
                                        XlsxCellValue::String(cell_value_text.clone())
                                    }
                                }
                                XlsxCellType::Boolean => {
                                    XlsxCellValue::Boolean(cell_value_text == "1")
                                }
                                XlsxCellType::Error => {
                                    XlsxCellValue::Error(cell_value_text.clone())
                                }
                                _ => {
                                    if let Ok(num) = cell_value_text.parse::<f64>() {
                                        XlsxCellValue::Number(num)
                                    } else {
                                        XlsxCellValue::String(cell_value_text.clone())
                                    }
                                }
                            };
                        } else if !inline_string.is_empty() {
                            cell.value = XlsxCellValue::String(inline_string.clone());
                        }
                        
                        // Set formula
                        if let Some(ref mut formula) = cell.formula {
                            formula.formula = cell_formula_text.clone();
                        }
                        
                        if let Some(ref mut row) = current_row {
                            row.cells.push(cell);
                        }
                    }
                    b"v" => in_v = false,
                    b"f" => in_f = false,
                    b"is" => in_is = false,
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(sheet)
}

// =============================================================================
// HELPERS
// =============================================================================

fn get_attr(e: &BytesStart, name: &[u8]) -> Option<String> {
    e.attributes()
        .flatten()
        .find(|a| a.key.as_ref() == name)
        .map(|a| String::from_utf8_lossy(&a.value).to_string())
}
