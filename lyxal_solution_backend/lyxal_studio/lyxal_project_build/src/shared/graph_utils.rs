use std::collections::{HashMap, HashSet};
use lyxal_types::instance::{Instance, InstanceChild};

/// Portage intÃ©gral de findCycles (shared/graph-utils.ts)
pub fn find_cycles(instances: &[Instance]) -> Vec<Vec<String>> {
    let mut adj = HashMap::new();
    for inst in instances {
        let child_ids: Vec<String> = inst.children.iter().filter_map(|c| match c {
            InstanceChild::Id { value } => Some(value.clone()),
            _ => None
        }).collect();
        adj.insert(inst.id.clone(), child_ids);
    }
    let mut visited = HashSet::new();
    let mut path = Vec::new();
    let mut cycles = Vec::new();
    fn dfs(id: &str, adj: &HashMap<String, Vec<String>>, visited: &mut HashSet<String>, path: &mut Vec<String>, cycles: &mut Vec<Vec<String>>) {
        if let Some(pos) = path.iter().position(|x| x == id) {
            let mut cycle = path[pos..].to_vec();
            cycle.push(id.to_string());
            cycles.push(cycle);
            return;
        }
        if visited.contains(id) { return; }
        visited.insert(id.to_string());
        path.push(id.to_string());
        if let Some(children) = adj.get(id) {
            for c in children { dfs(c, adj, visited, path, cycles); }
        }
        path.pop();
    }
    for inst in instances { if !visited.contains(&inst.id) { dfs(&inst.id, &adj, &mut visited, &mut path, &mut cycles); } }
    cycles
}

/// Portage intÃ©gral de breakCyclesMutable
pub fn break_cycles(instances: &mut Vec<Instance>, break_on_slot: bool) {
    let cycles = find_cycles(instances);
    if cycles.is_empty() { return; }
    for cycle in cycles {
        let target_id = if break_on_slot {
            cycle.iter().find(|id| instances.iter().any(|i| &i.id == *id && i.component == "Slot")).cloned()
        } else { None }.unwrap_or_else(|| cycle.last().unwrap().clone());
        for inst in instances.iter_mut() {
            inst.children.retain(|c| match c {
                InstanceChild::Id { value } => value != &target_id,
                _ => true
            });
        }
    }
}

