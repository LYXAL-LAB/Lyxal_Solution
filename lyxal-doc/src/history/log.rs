use serde::{Deserialize, Serialize};
use crate::core::Document;
use crate::ops::{apply, Operation};
use crate::history::entry::HistoryEntry;
use crate::history::error::HistoryError;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryLog {
    entries: Vec<HistoryEntry>,
    cursor: usize,
}

impl HistoryLog {
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            cursor: 0,
        }
    }

    /// Applique une nouvelle opération au document, tronque l'historique futur (si après undo)
    /// et enregistre l'entrée. Retourne le nouvel état du document.
    pub fn commit(&mut self, doc: &Document, op: Operation) -> Result<Document, HistoryError> {
        // 1. Tenter d'appliquer l'opération pour vérifier sa validité
        let new_doc = apply(doc, op.clone())?;

        // 2. Si valide, on tronque l'historique après le curseur (comportement standard undo/redo)
        if self.cursor < self.entries.len() {
            self.entries.truncate(self.cursor);
        }

        // 3. Ajouter l'opération et avancer le curseur
        self.entries.push(HistoryEntry::new(op));
        self.cursor += 1;

        Ok(new_doc)
    }

    /// Retourne l'état du document après avoir reculé le curseur.
    pub fn undo(&mut self, base: &Document) -> Result<Document, HistoryError> {
        if self.cursor == 0 {
            return Err(HistoryError::NoMoreUndo);
        }

        self.cursor -= 1;
        self.replay(base)
    }

    /// Retourne l'état du document après avoir avancé le curseur.
    pub fn redo(&mut self, base: &Document) -> Result<Document, HistoryError> {
        if self.cursor >= self.entries.len() {
            return Err(HistoryError::NoMoreRedo);
        }

        self.cursor += 1;
        self.replay(base)
    }

    /// Rejoue toutes les opérations de la base jusqu'au curseur actuel.
    pub fn replay(&self, base: &Document) -> Result<Document, HistoryError> {
        let mut current_doc = base.clone();
        
        for i in 0..self.cursor {
            let entry = &self.entries[i];
            current_doc = apply(&current_doc, entry.operation.clone())?;
        }
        
        Ok(current_doc)
    }

    pub fn cursor(&self) -> usize {
        self.cursor
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn entries(&self) -> &[HistoryEntry] {
        &self.entries
    }
}

