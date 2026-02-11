use crate::excel::layout::{ExcelLayout, ExcelCell};
use crate::excel::physical_layout::*;
use crate::excel::error::ExcelError;
use std::collections::BTreeMap;

pub struct ExcelLayoutEngine {
    settings: GridSettings,
}

impl ExcelLayoutEngine {
    pub fn new(settings: GridSettings) -> Self {
        Self { settings }
    }

    pub fn compose(&self, visual_layout: &ExcelLayout) -> Result<ExcelPhysicalLayout, ExcelError> {
        let mut sheets = Vec::new();

        for visual_sheet in &visual_layout.sheets {
            let mut physical_grid = BTreeMap::new();
            let mut col_widths = BTreeMap::new();
            let mut row_heights = BTreeMap::new();

            // 1. Déterminer les dimensions dynamiques (v1.0 simplification)
            for (addr, cell) in &visual_sheet.grid {
                let (col_idx, row_idx) = self.parse_address(addr)?;
                
                // On pourrait calculer ici la taille réelle basée sur le contenu
                // Pour v1.0, on utilise les réglages par défaut ou des tags sémantiques.
                col_widths.entry(col_idx).or_insert(self.settings.default_column_width);
                row_heights.entry(row_idx).or_insert(self.settings.default_row_height);
            }

            // 2. Calculer les positions X, Y
            for (addr, cell) in &visual_sheet.grid {
                let (col_idx, row_idx) = self.parse_address(addr)?;
                let x = self.calculate_offset(&col_widths, col_idx);
                let y = self.calculate_offset(&row_heights, row_idx);
                let w = *col_widths.get(&col_idx).unwrap_or(&self.settings.default_column_width);
                let h = *row_heights.get(&row_idx).unwrap_or(&self.settings.default_row_height);

                physical_grid.insert(addr.clone(), PhysicalExcelCell {
                    id: cell.id.clone(),
                    address: addr.clone(),
                    x,
                    y,
                    width: w,
                    height: h,
                    value: format!("{:?}", cell.value), // Simplification v1.0
                    styles: BTreeMap::new(), // Seraient résolus par le Style Engine
                    is_locked: cell.is_locked,
                });
            }

            sheets.push(PhysicalExcelSheet {
                name: visual_sheet.name.clone(),
                grid: physical_grid,
                column_widths: col_widths,
                row_heights: row_heights,
                viewport: ViewportArea {
                    start_address: "A1".to_string(),
                    end_address: "Z100".to_string(), // v1.0 Simplification
                    width: self.settings.viewport_width,
                    height: self.settings.viewport_height,
                },
                freeze_panes: FreezeSettings::default(),
            });
        }

        Ok(ExcelPhysicalLayout {
            sheets,
            settings: self.settings.clone(),
        })
    }

    fn parse_address(&self, addr: &str) -> Result<(usize, usize), ExcelError> {
        let mut chars = addr.chars();
        let col_char = chars.next().ok_or_else(|| ExcelError::ReferenceError(addr.to_string()))?;
        let col = (col_char as u8 - b'A') as usize;
        let row_str: String = chars.collect();
        let row = row_str.parse::<usize>().map_err(|_| ExcelError::ReferenceError(addr.to_string()))? - 1;
        Ok((col, row))
    }

    fn calculate_offset(&self, sizes: &BTreeMap<usize, f64>, index: usize) -> f64 {
        let mut offset = 0.0;
        for i in 0..index {
            offset += sizes.get(&i).unwrap_or(&0.0);
        }
        offset
    }
}

