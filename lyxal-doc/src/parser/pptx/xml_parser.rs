//! XML Parsing for PPTX files (PresentationML)
//!
//! Uses quick-xml to parse Office Open XML for PowerPoint.

use quick_xml::Reader;
use quick_xml::events::{Event, BytesStart};
use std::collections::HashMap;

use super::model::*;
use crate::parser::{ParseResult, ParseError};

// =============================================================================
// NAMESPACES
// =============================================================================

const _NS_A: &str = "http://schemas.openxmlformats.org/drawingml/2006/main";
const _NS_R: &str = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
const _NS_P: &str = "http://schemas.openxmlformats.org/presentationml/2006/main";

// =============================================================================
// RELATIONSHIPS
// =============================================================================

pub fn parse_relationships(xml: &str) -> ParseResult<Vec<PptxRelationship>> {
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
                        rels.push(PptxRelationship {
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

fn parse_rel_type(type_str: &str) -> PptxRelType {
    if type_str.contains("slide") && !type_str.contains("Master") && !type_str.contains("Layout") {
        PptxRelType::Slide
    } else if type_str.contains("slideMaster") {
        PptxRelType::SlideMaster
    } else if type_str.contains("slideLayout") {
        PptxRelType::SlideLayout
    } else if type_str.contains("theme") {
        PptxRelType::Theme
    } else if type_str.contains("notesMaster") {
        PptxRelType::NotesMaster
    } else if type_str.contains("notesSlide") {
        PptxRelType::NotesSlide
    } else if type_str.contains("image") {
        PptxRelType::Image
    } else if type_str.contains("audio") {
        PptxRelType::Audio
    } else if type_str.contains("video") {
        PptxRelType::Video
    } else if type_str.contains("hyperlink") {
        PptxRelType::Hyperlink
    } else if type_str.contains("chart") {
        PptxRelType::Chart
    } else if type_str.contains("oleObject") {
        PptxRelType::OleObject
    } else if type_str.contains("comments") {
        PptxRelType::Comments
    } else {
        PptxRelType::Other(type_str.to_string())
    }
}

// =============================================================================
// METADATA
// =============================================================================

pub fn parse_core_metadata(xml: &str, metadata: &mut PptxMetadata) -> ParseResult<()> {
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

pub fn parse_app_metadata(xml: &str, metadata: &mut PptxMetadata) {
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
                    "Slides" => metadata.slide_count = text.parse().ok(),
                    "Paragraphs" => metadata.paragraph_count = text.parse().ok(),
                    "Words" => metadata.word_count = text.parse().ok(),
                    "Notes" => metadata.notes_count = text.parse().ok(),
                    "HiddenSlides" => metadata.hidden_slide_count = text.parse().ok(),
                    "PresentationFormat" => metadata.presentation_format = Some(text),
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
// PRESENTATION PROPERTIES
// =============================================================================

pub fn parse_presentation_properties(xml: &str) -> ParseResult<PptxPresentationProperties> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut props = PptxPresentationProperties::default();
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) | Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"sldSz" => {
                        props.slide_width = get_attr(e, b"cx")
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(9144000); // Default: 10" in EMUs
                        props.slide_height = get_attr(e, b"cy")
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(6858000); // Default: 7.5" in EMUs
                    }
                    b"notesSz" => {
                        // Notes size - just skip for now
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
    
    Ok(props)
}

// =============================================================================
// THEME
// =============================================================================

pub fn parse_theme(xml: &str) -> ParseResult<Option<PptxTheme>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut theme = PptxTheme {
        name: String::new(),
        color_scheme: PptxColorScheme::default(),
        font_scheme: PptxFontScheme::default(),
        format_scheme: None,
    };
    
    let mut buf = Vec::new();
    let mut in_clr_scheme = false;
    let mut in_font_scheme = false;
    let mut current_color_name: Option<String> = None;
    let mut in_major_font = false;
    let mut in_minor_font = false;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"theme" => {
                        theme.name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"clrScheme" => {
                        in_clr_scheme = true;
                        theme.color_scheme.name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"fontScheme" => {
                        in_font_scheme = true;
                        theme.font_scheme.name = get_attr(e, b"name").unwrap_or_default();
                    }
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
                                theme.color_scheme.colors.insert(name.clone(), val);
                            }
                        }
                    }
                    b"sysClr" if current_color_name.is_some() => {
                        if let Some(val) = get_attr(e, b"lastClr") {
                            if let Some(ref name) = current_color_name {
                                theme.color_scheme.colors.insert(name.clone(), val);
                            }
                        }
                    }
                    b"latin" if in_font_scheme => {
                        if let Some(typeface) = get_attr(e, b"typeface") {
                            if in_major_font {
                                theme.font_scheme.major_font.latin = typeface;
                            } else if in_minor_font {
                                theme.font_scheme.minor_font.latin = typeface;
                            }
                        }
                    }
                    b"ea" if in_font_scheme => {
                        if let Some(typeface) = get_attr(e, b"typeface") {
                            if in_major_font {
                                theme.font_scheme.major_font.east_asian = Some(typeface);
                            } else if in_minor_font {
                                theme.font_scheme.minor_font.east_asian = Some(typeface);
                            }
                        }
                    }
                    b"cs" if in_font_scheme => {
                        if let Some(typeface) = get_attr(e, b"typeface") {
                            if in_major_font {
                                theme.font_scheme.major_font.complex_script = Some(typeface);
                            } else if in_minor_font {
                                theme.font_scheme.minor_font.complex_script = Some(typeface);
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
// SLIDE MASTER
// =============================================================================

pub fn parse_slide_master(xml: &str, rel_id: &str) -> ParseResult<PptxSlideMaster> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut master = PptxSlideMaster {
        rel_id: rel_id.to_string(),
        name: None,
        shapes: Vec::new(),
        color_map: PptxColorMap::default(),
        slide_layouts: Vec::new(),
        text_styles: PptxTextStyles::default(),
        theme_rel_id: None,
    };
    
    let mut buf = Vec::new();
    let mut in_sp_tree = false;
    let mut shape_stack: Vec<PptxShapeBuilder> = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"spTree" => in_sp_tree = true,
                    b"sp" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_shape());
                    }
                    b"pic" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_picture());
                    }
                    b"nvSpPr" | b"nvPicPr" if !shape_stack.is_empty() => {
                        // Non-visual properties coming
                    }
                    b"cNvPr" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.id = get_attr(e, b"id").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.name = get_attr(e, b"name").unwrap_or_default();
                            builder.description = get_attr(e, b"descr");
                            builder.title = get_attr(e, b"title");
                        }
                    }
                    b"clrMap" => {
                        master.color_map = parse_color_map(e);
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"cNvPr" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.id = get_attr(e, b"id").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.name = get_attr(e, b"name").unwrap_or_default();
                        }
                    }
                    b"off" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.transform.x = get_attr(e, b"x").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.transform.y = get_attr(e, b"y").and_then(|s| s.parse().ok()).unwrap_or(0);
                        }
                    }
                    b"ext" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.transform.cx = get_attr(e, b"cx").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.transform.cy = get_attr(e, b"cy").and_then(|s| s.parse().ok()).unwrap_or(0);
                        }
                    }
                    b"ph" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.placeholder = Some(parse_placeholder(e));
                        }
                    }
                    b"clrMap" => {
                        master.color_map = parse_color_map(e);
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"spTree" => in_sp_tree = false,
                    b"sp" | b"pic" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.pop() {
                            if let Some(shape) = builder.build() {
                                master.shapes.push(shape);
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
    
    Ok(master)
}

fn parse_color_map(e: &BytesStart) -> PptxColorMap {
    PptxColorMap {
        bg1: get_attr(e, b"bg1"),
        tx1: get_attr(e, b"tx1"),
        bg2: get_attr(e, b"bg2"),
        tx2: get_attr(e, b"tx2"),
        accent1: get_attr(e, b"accent1"),
        accent2: get_attr(e, b"accent2"),
        accent3: get_attr(e, b"accent3"),
        accent4: get_attr(e, b"accent4"),
        accent5: get_attr(e, b"accent5"),
        accent6: get_attr(e, b"accent6"),
        hlink: get_attr(e, b"hlink"),
        fol_hlink: get_attr(e, b"folHlink"),
    }
}

fn parse_placeholder(e: &BytesStart) -> PptxPlaceholder {
    let type_str = get_attr(e, b"type").unwrap_or_default();
    let placeholder_type = match type_str.as_str() {
        "body" => PptxPlaceholderType::Body,
        "title" => PptxPlaceholderType::Title,
        "ctrTitle" => PptxPlaceholderType::CenteredTitle,
        "subTitle" => PptxPlaceholderType::Subtitle,
        "dt" => PptxPlaceholderType::DateAndTime,
        "ftr" => PptxPlaceholderType::Footer,
        "sldNum" => PptxPlaceholderType::SlideNumber,
        "hdr" => PptxPlaceholderType::Header,
        "obj" => PptxPlaceholderType::Object,
        "chart" => PptxPlaceholderType::Chart,
        "tbl" => PptxPlaceholderType::Table,
        "clipArt" => PptxPlaceholderType::ClipArt,
        "dgm" => PptxPlaceholderType::Diagram,
        "media" => PptxPlaceholderType::Media,
        "sldImg" => PptxPlaceholderType::SlideImage,
        "pic" => PptxPlaceholderType::Picture,
        other => PptxPlaceholderType::Other(other.to_string()),
    };
    
    PptxPlaceholder {
        placeholder_type,
        idx: get_attr(e, b"idx").and_then(|s| s.parse().ok()),
        size: get_attr(e, b"sz"),
        has_custom_prompt: get_attr(e, b"hasCustomPrompt").map(|s| s == "1").unwrap_or(false),
    }
}

// =============================================================================
// SLIDE LAYOUT
// =============================================================================

pub fn parse_slide_layout(xml: &str, rel_id: &str) -> ParseResult<PptxSlideLayout> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut layout = PptxSlideLayout {
        rel_id: rel_id.to_string(),
        name: None,
        layout_type: None,
        shapes: Vec::new(),
        master_rel_id: String::new(),
        show_master_shapes: true,
        show_master_placeholders: true,
    };
    
    let mut buf = Vec::new();
    let mut in_sp_tree = false;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"sldLayout" => {
                        layout.name = get_attr(e, b"name");
                        layout.layout_type = get_attr(e, b"type");
                        layout.show_master_shapes = get_attr(e, b"showMasterSp")
                            .map(|s| s != "0")
                            .unwrap_or(true);
                    }
                    b"spTree" => in_sp_tree = true,
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"spTree" {
                    in_sp_tree = false;
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(layout)
}

// =============================================================================
// SLIDE
// =============================================================================

pub fn parse_slide(xml: &str, index: usize, rels: &[PptxRelationship]) -> ParseResult<PptxSlide> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut slide = PptxSlide {
        index,
        layout_rel_id: None,
        name: None,
        hidden: false,
        shapes: Vec::new(),
        background: None,
        timing: None,
        transition: None,
    };
    
    let mut buf = Vec::new();
    let mut in_sp_tree = false;
    let mut shape_stack: Vec<PptxShapeBuilder> = Vec::new();
    let mut current_para: Option<PptxParagraph> = None;
    let mut current_run: Option<PptxRun> = None;
    let mut in_txBody = false;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                match e.local_name().as_ref() {
                    b"sld" => {
                        slide.hidden = get_attr(e, b"show").map(|s| s == "0").unwrap_or(false);
                    }
                    b"spTree" => in_sp_tree = true,
                    b"sp" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_shape());
                    }
                    b"pic" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_picture());
                    }
                    b"graphicFrame" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_graphic_frame());
                    }
                    b"grpSp" if in_sp_tree => {
                        shape_stack.push(PptxShapeBuilder::new_group());
                    }
                    b"cNvPr" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.id = get_attr(e, b"id").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.name = get_attr(e, b"name").unwrap_or_default();
                            builder.description = get_attr(e, b"descr");
                            builder.title = get_attr(e, b"title");
                        }
                    }
                    b"txBody" if !shape_stack.is_empty() => {
                        in_txBody = true;
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.text_body = Some(PptxTextBody {
                                properties: PptxBodyProperties::default(),
                                paragraphs: Vec::new(),
                                list_style: None,
                            });
                        }
                    }
                    b"p" if in_txBody => {
                        current_para = Some(PptxParagraph {
                            properties: PptxParagraphProperties::default(),
                            runs: Vec::new(),
                            end_para_rpr: None,
                        });
                    }
                    b"r" if current_para.is_some() => {
                        current_run = Some(PptxRun {
                            properties: None,
                            text: String::new(),
                        });
                    }
                    b"pPr" if current_para.is_some() => {
                        if let Some(ref mut para) = current_para {
                            para.properties.align = get_attr(e, b"algn");
                            para.properties.level = get_attr(e, b"lvl")
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(0);
                            para.properties.indent = get_attr(e, b"indent")
                                .and_then(|s| s.parse().ok());
                            para.properties.margin_left = get_attr(e, b"marL")
                                .and_then(|s| s.parse().ok());
                        }
                    }
                    b"rPr" if current_run.is_some() => {
                        if let Some(ref mut run) = current_run {
                            run.properties = Some(PptxRunProperties {
                                font_size: get_attr(e, b"sz").and_then(|s| s.parse().ok()),
                                bold: get_attr(e, b"b").map(|s| s == "1"),
                                italic: get_attr(e, b"i").map(|s| s == "1"),
                                underline: get_attr(e, b"u"),
                                strike: get_attr(e, b"strike"),
                                ..Default::default()
                            });
                        }
                    }
                    b"tbl" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.table = Some(PptxTable {
                                rows: Vec::new(),
                                grid_cols: Vec::new(),
                                properties: None,
                            });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                match e.local_name().as_ref() {
                    b"cNvPr" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.id = get_attr(e, b"id").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.name = get_attr(e, b"name").unwrap_or_default();
                            builder.description = get_attr(e, b"descr");
                        }
                    }
                    b"off" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.transform.x = get_attr(e, b"x").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.transform.y = get_attr(e, b"y").and_then(|s| s.parse().ok()).unwrap_or(0);
                        }
                    }
                    b"ext" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.transform.cx = get_attr(e, b"cx").and_then(|s| s.parse().ok()).unwrap_or(0);
                            builder.transform.cy = get_attr(e, b"cy").and_then(|s| s.parse().ok()).unwrap_or(0);
                        }
                    }
                    b"ph" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.placeholder = Some(parse_placeholder(e));
                        }
                    }
                    b"prstGeom" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.preset_geometry = get_attr(e, b"prst");
                        }
                    }
                    b"blip" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.blip_rel_id = get_attr(e, b"r:embed")
                                .or_else(|| get_attr(e, b"embed"));
                        }
                    }
                    b"solidFill" => {
                        // Handled in nested elements
                    }
                    b"srgbClr" if !shape_stack.is_empty() => {
                        if let Some(val) = get_attr(e, b"val") {
                            if let Some(builder) = shape_stack.last_mut() {
                                builder.fill_color = Some(PptxColor::Rgb(val));
                            }
                        }
                    }
                    b"schemeClr" if !shape_stack.is_empty() => {
                        if let Some(val) = get_attr(e, b"val") {
                            if let Some(builder) = shape_stack.last_mut() {
                                builder.fill_color = Some(PptxColor::Scheme(val));
                            }
                        }
                    }
                    b"gridCol" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.last_mut() {
                            if let Some(ref mut table) = builder.table {
                                let w = get_attr(e, b"w").and_then(|s| s.parse().ok()).unwrap_or(0);
                                table.grid_cols.push(w);
                            }
                        }
                    }
                    b"hlinkClick" => {
                        if let Some(builder) = shape_stack.last_mut() {
                            builder.hyperlink = Some(PptxHyperlink {
                                rel_id: get_attr(e, b"r:id"),
                                action: get_attr(e, b"action"),
                                target_frame: get_attr(e, b"tgtFrame"),
                                tooltip: get_attr(e, b"tooltip"),
                                invalid_url: false,
                                history: true,
                                highlight_click: false,
                                end_sound: false,
                            });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if let Some(ref mut run) = current_run {
                    run.text.push_str(&text);
                }
            }
            Ok(Event::End(ref e)) => {
                match e.local_name().as_ref() {
                    b"spTree" => in_sp_tree = false,
                    b"sp" | b"pic" | b"graphicFrame" | b"grpSp" if !shape_stack.is_empty() => {
                        if let Some(builder) = shape_stack.pop() {
                            if let Some(shape) = builder.build() {
                                if let Some(parent) = shape_stack.last_mut() {
                                    parent.child_shapes.push(shape);
                                } else {
                                    slide.shapes.push(shape);
                                }
                            }
                        }
                    }
                    b"txBody" => {
                        in_txBody = false;
                    }
                    b"p" if current_para.is_some() => {
                        if let Some(para) = current_para.take() {
                            if let Some(builder) = shape_stack.last_mut() {
                                if let Some(ref mut tb) = builder.text_body {
                                    tb.paragraphs.push(para);
                                }
                            }
                        }
                    }
                    b"r" if current_run.is_some() => {
                        if let Some(run) = current_run.take() {
                            if let Some(ref mut para) = current_para {
                                para.runs.push(run);
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
    
    // Get layout rel_id from relationships
    slide.layout_rel_id = rels.iter()
        .find(|r| matches!(r.rel_type, PptxRelType::SlideLayout))
        .map(|r| r.id.clone());
    
    Ok(slide)
}

// =============================================================================
// COMMENTS
// =============================================================================

pub fn parse_comments(xml: &str) -> ParseResult<Vec<PptxComment>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut comments = Vec::new();
    let mut buf = Vec::new();
    let mut current_comment: Option<PptxComment> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                if e.local_name().as_ref() == b"cm" {
                    current_comment = Some(PptxComment {
                        id: get_attr(e, b"idx").and_then(|s| s.parse().ok()).unwrap_or(0),
                        author_id: get_attr(e, b"authorId").and_then(|s| s.parse().ok()).unwrap_or(0),
                        author_name: String::new(),
                        date: get_attr(e, b"dt"),
                        text: String::new(),
                        position: None,
                        slide_index: None,
                    });
                }
            }
            Ok(Event::Empty(ref e)) => {
                if e.local_name().as_ref() == b"pos" {
                    if let Some(ref mut comment) = current_comment {
                        let x = get_attr(e, b"x").and_then(|s| s.parse().ok()).unwrap_or(0);
                        let y = get_attr(e, b"y").and_then(|s| s.parse().ok()).unwrap_or(0);
                        comment.position = Some(PptxPoint { x, y });
                    }
                }
            }
            Ok(Event::Text(ref t)) => {
                if let Some(ref mut comment) = current_comment {
                    comment.text.push_str(&t.unescape().unwrap_or_default());
                }
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"cm" {
                    if let Some(comment) = current_comment.take() {
                        comments.push(comment);
                    }
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(comments)
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

// =============================================================================
// SHAPE BUILDER
// =============================================================================

enum ShapeType {
    Shape,
    Picture,
    GraphicFrame,
    Group,
}

struct PptxShapeBuilder {
    shape_type: ShapeType,
    id: u32,
    name: String,
    description: Option<String>,
    title: Option<String>,
    transform: PptxTransform2D,
    placeholder: Option<PptxPlaceholder>,
    preset_geometry: Option<String>,
    text_body: Option<PptxTextBody>,
    blip_rel_id: Option<String>,
    fill_color: Option<PptxColor>,
    table: Option<PptxTable>,
    hyperlink: Option<PptxHyperlink>,
    child_shapes: Vec<PptxShape>,
}

impl PptxShapeBuilder {
    fn new_shape() -> Self {
        Self {
            shape_type: ShapeType::Shape,
            id: 0,
            name: String::new(),
            description: None,
            title: None,
            transform: PptxTransform2D::default(),
            placeholder: None,
            preset_geometry: None,
            text_body: None,
            blip_rel_id: None,
            fill_color: None,
            table: None,
            hyperlink: None,
            child_shapes: Vec::new(),
        }
    }
    
    fn new_picture() -> Self {
        let mut s = Self::new_shape();
        s.shape_type = ShapeType::Picture;
        s
    }
    
    fn new_graphic_frame() -> Self {
        let mut s = Self::new_shape();
        s.shape_type = ShapeType::GraphicFrame;
        s
    }
    
    fn new_group() -> Self {
        let mut s = Self::new_shape();
        s.shape_type = ShapeType::Group;
        s
    }
    
    fn build(self) -> Option<PptxShape> {
        match self.shape_type {
            ShapeType::Shape => {
                Some(PptxShape::Shape(PptxShapeProperties {
                    id: self.id,
                    name: self.name,
                    description: self.description,
                    title: self.title,
                    placeholder: self.placeholder,
                    transform: self.transform,
                    preset_geometry: self.preset_geometry,
                    custom_geometry: None,
                    fill: self.fill_color.map(|c| PptxFill::Solid(PptxSolidFill { color: c })),
                    outline: None,
                    effect: None,
                    text_body: self.text_body,
                    hyperlink: self.hyperlink,
                    locked: false,
                    visible: true,
                }))
            }
            ShapeType::Picture => {
                let blip_rel_id = self.blip_rel_id?;
                Some(PptxShape::Picture(PptxPicture {
                    id: self.id,
                    name: self.name,
                    description: self.description,
                    transform: self.transform,
                    blip_rel_id,
                    source_rect: None,
                    fill_rect: None,
                    stretch: true,
                    hyperlink: self.hyperlink,
                }))
            }
            ShapeType::GraphicFrame => {
                let content = if let Some(table) = self.table {
                    PptxGraphicContent::Table(table)
                } else {
                    PptxGraphicContent::Other("unknown".to_string())
                };
                
                Some(PptxShape::GraphicFrame(PptxGraphicFrame {
                    id: self.id,
                    name: self.name,
                    transform: self.transform,
                    content,
                }))
            }
            ShapeType::Group => {
                Some(PptxShape::Group(PptxGroupShape {
                    id: self.id,
                    name: self.name,
                    transform: self.transform,
                    child_transform: None,
                    shapes: self.child_shapes,
                }))
            }
        }
    }
}
