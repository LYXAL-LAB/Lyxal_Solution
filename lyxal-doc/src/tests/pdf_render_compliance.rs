use crate::word::physical_layout::{WordPageLayout, PageSettings as WordSettings, PhysicalPage};
use crate::slides::physical_layout::{SlidesPhysicalLayout, ViewportSettings as SlidesSettings, PhysicalSlide, SlideStep, PhysicalSlideElement, PhysicalSlideContent};
use crate::render::pdf::renderer::PdfRenderer;
use std::collections::BTreeMap;

#[test]
fn test_pdf_compliance_step1_core_structure() {
    let settings = WordSettings::default();
    let layout = WordPageLayout {
        pages: vec![
            PhysicalPage {
                number: 1,
                elements: vec![],
                header: vec![],
                footer: vec![],
                footnotes: vec![],
            },
            PhysicalPage {
                number: 2,
                elements: vec![],
                header: vec![],
                footer: vec![],
                footnotes: vec![],
            },
        ],
        settings,
    };

    let renderer = PdfRenderer::new();
    let pdf_bytes = renderer.render_word(&layout).expect("PDF Word should succeed");

    assert!(pdf_bytes.len() > 100);
    assert_eq!(&pdf_bytes[0..5], b"%PDF-");
}

#[test]
fn test_pdf_compliance_slides_steps() {
    let settings = SlidesSettings::default();
    let layout = SlidesPhysicalLayout {
        slides: vec![
            PhysicalSlide {
                id: "s1".to_string(),
                number: 1,
                steps: vec![
                    SlideStep {
                        index: 0,
                        elements: vec![
                            PhysicalSlideElement {
                                id: "el1".to_string(),
                                x: 100.0, y: 100.0, z: 1,
                                width: 200.0, height: 50.0,
                                content: PhysicalSlideContent::Text("Step 0 Content".to_string()),
                                styles: BTreeMap::new(),
                            }
                        ],
                    },
                    SlideStep {
                        index: 1,
                        elements: vec![
                            PhysicalSlideElement {
                                id: "el1".to_string(),
                                x: 100.0, y: 100.0, z: 1,
                                width: 200.0, height: 50.0,
                                content: PhysicalSlideContent::Text("Step 0 Content".to_string()),
                                styles: BTreeMap::new(),
                            },
                            PhysicalSlideElement {
                                id: "el2".to_string(),
                                x: 100.0, y: 200.0, z: 2,
                                width: 200.0, height: 50.0,
                                content: PhysicalSlideContent::Text("Step 1 Content".to_string()),
                                styles: BTreeMap::new(),
                            }
                        ],
                    }
                ],
            }
        ],
        settings,
    };

    let renderer = PdfRenderer::new();
    let pdf_bytes = renderer.render_slides(&layout).expect("PDF Slides should succeed");

    // Doit avoir au moins 2 pages (une par step)
    assert!(pdf_bytes.len() > 1000);
}

