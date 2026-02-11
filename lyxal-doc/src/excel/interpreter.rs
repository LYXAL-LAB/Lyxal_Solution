use crate::core::Document;
use crate::core::node::{Block, Inline, ValueType};
use crate::excel::layout::*;
use crate::excel::error::ExcelError;
use crate::excel::dag::DependencyGraph;
use std::collections::{HashMap, HashSet, BTreeMap};

pub struct ExcelInterpreter {
    dag: DependencyGraph,
    cell_addresses: HashMap<String, String>, // NodeId -> Address (A1, etc.)
    reverse_addresses: HashMap<String, String>, // Address -> NodeId
    cell_data: HashMap<String, (CalculatedValue, Option<String>)>, // Address -> (Value, Formula)
}

impl ExcelInterpreter {
    pub fn new() -> Self {
        Self {
            dag: DependencyGraph::new(),
            cell_addresses: HashMap::new(),
            reverse_addresses: HashMap::new(),
            cell_data: HashMap::new(),
        }
    }

    pub fn interpret(&mut self, doc: &Document) -> Result<ExcelLayout, ExcelError> {
        // Reset state for stateless interpretation
        self.dag = DependencyGraph::new();
        self.cell_addresses.clear();
        self.reverse_addresses.clear();
        self.cell_data.clear();

        let mut sheets = Vec::new();
        
        // 1. First pass: Identify all tables and map their cells to A1, B2...
        for (i, block) in doc.content.iter().enumerate() {
            self.process_top_level_block(block, i + 1, &mut sheets)?;
        }

        // 2. Second pass: Build DAG and check for cycles
        let all_addresses: HashSet<String> = self.reverse_addresses.keys().cloned().collect();
        let _calc_order = self.dag.get_calculation_order(&all_addresses)?;

        // 3. Third pass: Finalize the sheets (In v1.0, calculation is basic/symbolic)
        
        Ok(ExcelLayout {
            sheets,
            metadata: ExcelDocumentMetadata {
                title: doc.title.clone(),
                author: doc.meta.author.clone().unwrap_or_default(),
            },
        })
    }

    fn process_top_level_block(&mut self, block: &Block, sheet_index: usize, sheets: &mut Vec<ExcelSheet>) -> Result<(), ExcelError> {
        match block {
            Block::Section(s) => {
                let mut grid = BTreeMap::new();
                for inner_block in &s.children {
                    self.process_inner_block(inner_block, &mut grid)?;
                }
                if !grid.is_empty() {
                    sheets.push(ExcelSheet {
                        name: format!("Sheet {}", sheet_index),
                        grid,
                    });
                }
            }
            Block::Table(t) => {
                let mut grid = BTreeMap::new();
                self.process_table(t, &mut grid)?;
                sheets.push(ExcelSheet {
                    name: format!("Sheet {}", sheet_index),
                    grid,
                });
            }
            Block::Condition(c) => {
                // Branche 'then' par défaut pour la v1.0
                for inner_block in &c.then_branch {
                    self.process_inner_block(inner_block, sheets.last_mut().map(|s| &mut s.grid).unwrap_or(&mut BTreeMap::new()))?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn process_inner_block(&mut self, block: &Block, grid: &mut BTreeMap<String, ExcelCell>) -> Result<(), ExcelError> {
        match block {
            Block::Table(t) => self.process_table(t, grid)?,
            Block::Group(g) => {
                for child in &g.children {
                    self.process_inner_block(child, grid)?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn process_table(&mut self, t: &crate::core::node::TableBlock, grid: &mut BTreeMap<String, ExcelCell>) -> Result<(), ExcelError> {
        for (r, row) in t.rows.iter().enumerate() {
            for (c, cell) in row.cells.iter().enumerate() {
                let address = self.get_address(r, c);
                self.cell_addresses.insert(cell.id.clone(), address.clone());
                self.reverse_addresses.insert(address.clone(), cell.id.clone());

                let mut formula = None;
                let mut value = CalculatedValue::Empty;

                for block in &cell.content {
                    if let Block::Paragraph(p) = block {
                        for inline in &p.inlines {
                            match inline {
                                Inline::Value(v) => {
                                    value = match v.value_type {
                                        ValueType::Number => CalculatedValue::Number(v.raw_value.parse().unwrap_or(0.0)),
                                        ValueType::Boolean => CalculatedValue::Boolean(v.raw_value == "true"),
                                        ValueType::Date => CalculatedValue::Date(v.raw_value.parse().unwrap_or(0)),
                                        ValueType::Currency => CalculatedValue::Currency { 
                                            amount: v.raw_value.parse().unwrap_or(0.0), 
                                            code: "EUR".to_string() 
                                        },
                                        _ => CalculatedValue::String(v.raw_value.clone()),
                                    };
                                }
                                Inline::Expression(e) => {
                                    formula = Some(e.formula.clone());
                                    self.extract_dependencies(&address, &e.formula);
                                }
                                Inline::CrossRef(_cr) => {
                                    // CrossRef logic (v1.0 neutre)
                                }
                                _ => {}
                            }
                        }
                    }
                }

                grid.insert(address.clone(), ExcelCell {
                    id: cell.id.clone(),
                    address: address.clone(),
                    value: value.clone(),
                    formula: formula.clone(),
                    is_locked: false, 
                });
                self.cell_data.insert(address, (value, formula));
            }
        }
        Ok(())
    }

    fn get_address(&self, row: usize, col: usize) -> String {
        let col_letter = (b'A' + col as u8) as char;
        format!("{}{}", col_letter, row + 1)
    }

    fn extract_dependencies(&mut self, dependent: &str, formula: &str) {
        let mut chars = formula.chars().peekable();
        while let Some(ch) = chars.next() {
            if ch.is_ascii_uppercase() {
                let mut addr = String::new();
                addr.push(ch);
                while let Some(&next) = chars.peek() {
                    if next.is_ascii_digit() {
                        addr.push(chars.next().unwrap());
                    } else {
                        break;
                    }
                }
                if addr.len() > 1 {
                    self.dag.add_dependency(dependent.to_string(), addr);
                }
            }
        }
    }
}
