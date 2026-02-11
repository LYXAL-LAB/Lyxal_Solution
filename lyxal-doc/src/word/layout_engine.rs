use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use crate::word::physical_layout::*;
use crate::word::error::WordError;

pub struct WordLayoutEngine {
    settings: PageSettings,
}

impl WordLayoutEngine {
    pub fn new(settings: PageSettings) -> Self {
        Self { settings }
    }

    pub fn compose(&self, visual_layout: &VisualLayout) -> Result<WordPageLayout, WordError> {
        let mut pages = Vec::new();
        let mut current_page = self.new_page(1);
        let mut cursor_y = self.settings.margins[0]; // Top margin
        let available_width = self.settings.width - self.settings.margins[1] - self.settings.margins[3];
        let available_height = self.settings.height - self.settings.margins[2]; // Height minus bottom margin

        for element in &visual_layout.root_elements {
            // Pour v1.0, on gère principalement les Paragraphes et Headings qui se fragmentent
            if element.element_type == "paragraph" || element.element_type == "heading" {
                self.layout_block_element(
                    element,
                    &mut pages,
                    &mut current_page,
                    &mut cursor_y,
                    available_width,
                    available_height,
                )?;
            } else if element.element_type == "page_break" {
                pages.push(current_page);
                current_page = self.new_page((pages.len() + 1) as u32);
                cursor_y = self.settings.margins[0];
            }
        }

        pages.push(current_page);

        Ok(WordPageLayout {
            pages,
            settings: self.settings.clone(),
        })
    }

    fn new_page(&self, number: u32) -> PhysicalPage {
        PhysicalPage {
            number,
            elements: Vec::new(),
            header: Vec::new(),
            footer: Vec::new(),
            footnotes: Vec::new(),
        }
    }

    fn layout_block_element(
        &self,
        element: &VisualElement,
        pages: &mut Vec<PhysicalPage>,
        current_page: &mut PhysicalPage,
        cursor_y: &mut f64,
        width: f64,
        height: f64,
    ) -> Result<(), WordError> {
        // Estimation très simplifiée pour la v1.0 :
        // Chaque élément prend une certaine hauteur basée sur font_size et line_height
        let font_size = match element.resolved_styles.get("font_size") {
            Some(StyleValue::Number(n)) => *n,
            _ => 12.0,
        };
        let line_height_mult = match element.resolved_styles.get("line_height") {
            Some(StyleValue::Number(n)) => *n,
            _ => 1.2,
        };
        let line_height = font_size * line_height_mult;

        // Collecter tout le texte (très simplifié)
        let mut full_text = String::new();
        for child in &element.children {
            if let Some(StyleValue::String(s)) = child.resolved_styles.get("text") {
                full_text.push_str(s);
            }
        }

        // Simuler le line-breaking (1 ligne par défaut pour la démo v1.0 si court, 
        // ou calcul basé sur la largeur si on avait des métriques de police)
        // Ici on va juste dire qu'un élément peut tenir sur plusieurs lignes.
        let estimated_lines = (full_text.len() as f64 / (width / (font_size * 0.5))).ceil().max(1.0);
        let element_height = estimated_lines * line_height;

        // Pagination
        if *cursor_y + element_height > height {
            // Règle des veuves et orphelines (simplifiée) : 
            // Si on ne peut pas mettre au moins 2 lignes, on saute de page.
            pages.push(current_page.clone());
            *current_page = self.new_page((pages.len() + 1) as u32);
            *cursor_y = self.settings.margins[0];
        }

        current_page.elements.push(PhysicalElement {
            id: element.id.clone(),
            x: self.settings.margins[3],
            y: *cursor_y,
            width,
            height: element_height,
            content: PhysicalContent::Line { 
                text: full_text,
                runs: Vec::new(), // v1.0 simplifié
            },
            styles: element.resolved_styles.clone(),
        });

        *cursor_y += element_height + 6.0; // Petit espacement entre blocs

        Ok(())
    }
}

