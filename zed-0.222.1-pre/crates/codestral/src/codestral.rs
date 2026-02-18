use edit_prediction_types::{EditPrediction, EditPredictionDelegate};
use gpui::{App, Context, Entity};
use http_client::HttpClient;
use language::{Anchor, Buffer};
use std::sync::Arc;

pub struct CodestralEditPredictionDelegate;

impl CodestralEditPredictionDelegate {
    pub fn new(_http_client: Arc<dyn HttpClient>) -> Self {
        Self
    }

    pub fn ensure_api_key_loaded(_http_client: Arc<dyn HttpClient>, _cx: &mut App) {
        // No-op
    }

    pub fn has_api_key(_cx: &App) -> bool {
        false
    }
}

impl EditPredictionDelegate for CodestralEditPredictionDelegate {
    fn name() -> &'static str {
        "codestral"
    }

    fn display_name() -> &'static str {
        "Codestral"
    }

    fn show_predictions_in_menu() -> bool {
        false // Hide from menu
    }

    fn is_enabled(&self, _buffer: &Entity<Buffer>, _cursor_position: Anchor, _cx: &App) -> bool {
        false
    }

    fn is_refreshing(&self, _cx: &App) -> bool {
        false
    }

    fn refresh(
        &mut self,
        _buffer: Entity<Buffer>,
        _cursor_position: Anchor,
        _debounce: bool,
        _cx: &mut Context<Self>,
    ) {
        // No-op
    }

    fn accept(&mut self, _cx: &mut Context<Self>) {}

    fn discard(&mut self, _cx: &mut Context<Self>) {}

    fn suggest(
        &mut self,
        _buffer: &Entity<Buffer>,
        _cursor_position: Anchor,
        _cx: &mut Context<Self>,
    ) -> Option<EditPrediction> {
        None
    }
}
