use std::collections::{HashMap, HashSet};
use crate::excel::error::ExcelError;

pub struct DependencyGraph {
    /// nodes[A] = {B, C} means A depends on B and C
    nodes: HashMap<String, HashSet<String>>,
}

impl DependencyGraph {
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
        }
    }

    pub fn add_dependency(&mut self, dependent: String, provider: String) {
        self.nodes.entry(dependent).or_insert_with(HashSet::new).insert(provider);
    }

    /// Performs a topological sort to find the calculation order.
    /// Returns a vector of addresses in the order they should be calculated.
    /// Returns ExcelError::CycleDetected if a cycle is found.
    pub fn get_calculation_order(&self, all_nodes: &HashSet<String>) -> Result<Vec<String>, ExcelError> {
        let mut order = Vec::new();
        let mut visited = HashSet::new();
        let mut temporary_stack = HashSet::new();

        for node in all_nodes {
            if !visited.contains(node) {
                self.visit(node, &mut visited, &mut temporary_stack, &mut order)?;
            }
        }

        Ok(order)
    }

    fn visit(
        &self,
        node: &String,
        visited: &mut HashSet<String>,
        temporary_stack: &mut HashSet<String>,
        order: &mut Vec<String>,
    ) -> Result<(), ExcelError> {
        if temporary_stack.contains(node) {
            return Err(ExcelError::CycleDetected);
        }

        if !visited.contains(node) {
            temporary_stack.insert(node.clone());

            if let Some(dependencies) = self.nodes.get(node) {
                for dep in dependencies {
                    self.visit(dep, visited, temporary_stack, order)?;
                }
            }

            temporary_stack.remove(node);
            visited.insert(node.clone());
            order.push(node.clone());
        }

        Ok(())
    }
}

