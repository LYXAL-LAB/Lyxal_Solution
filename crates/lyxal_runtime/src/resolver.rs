use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::registry::ModuleRegistry;
use crate::types::ModuleId;
use std::collections::{BTreeMap, BTreeSet, HashMap, HashSet};

/// Moteur de résolution des dépendances et de tri topologique (DAG) pour Lyxal OS.
///
/// Garantit un ordre de démarrage strictly déterministe et détecte à la fois
/// les dépendances manquantes et les cycles d'interdépendances.
pub struct DependencyResolver;

impl DependencyResolver {
    /// Résout l'ordre topologique de démarrage pour l'ensemble des modules du registre.
    ///
    /// # Erreurs
    /// - `RuntimeError::MissingDependency` si un module déclare une dépendance absente du registre.
    /// - `RuntimeError::DependencyCycle` si un cycle de dépendances est détecté.
    pub fn resolve(registry: &ModuleRegistry) -> Result<Vec<ModuleId>, RuntimeError> {
        let descriptors = registry.descriptors();
        Self::resolve_descriptors(&descriptors)
    }

    /// Résout l'ordre topologique à partir d'une liste de descripteurs.
    pub fn resolve_descriptors(
        descriptors: &[ModuleDescriptor],
    ) -> Result<Vec<ModuleId>, RuntimeError> {
        if descriptors.is_empty() {
            return Ok(Vec::new());
        }

        // 1. Indexer tous les modules connus et mémoriser leur position d'origine
        let mut known_ids: HashSet<ModuleId> = HashSet::new();
        let mut index_map: HashMap<ModuleId, usize> = HashMap::new();

        for (idx, desc) in descriptors.iter().enumerate() {
            known_ids.insert(desc.id.clone());
            index_map.insert(desc.id.clone(), idx);
        }

        // 2. Vérifier les dépendances manquantes
        for desc in descriptors {
            for dep in &desc.dependencies {
                if !known_ids.contains(dep) {
                    return Err(RuntimeError::MissingDependency {
                        module: desc.id.clone(),
                        dependency: dep.clone(),
                    });
                }
            }
        }

        // 3. Construction du graphe orienté
        // Un arc `dep -> module` signifie que `dep` doit être démarré avant `module`.
        // dependents[dep] = ensemble des modules qui dépendent de `dep`.
        let mut dependents: HashMap<ModuleId, Vec<ModuleId>> = HashMap::new();
        let mut in_degrees: BTreeMap<ModuleId, usize> = BTreeMap::new();

        for desc in descriptors {
            in_degrees.insert(desc.id.clone(), desc.dependencies.len());
            for dep in &desc.dependencies {
                dependents
                    .entry(dep.clone())
                    .or_default()
                    .push(desc.id.clone());
            }
        }

        // 4. Ensemble des modules prêts (in-degree == 0), ordonné par (index, ModuleId) pour un déterminisme absolu
        let mut ready: BTreeSet<(usize, ModuleId)> = BTreeSet::new();
        for (id, &deg) in &in_degrees {
            if deg == 0 {
                let idx = index_map.get(id).copied().unwrap_or(0);
                ready.insert((idx, id.clone()));
            }
        }

        let mut start_order: Vec<ModuleId> = Vec::with_capacity(descriptors.len());

        // 5. Algorithme de Kahn déterministe
        while let Some((_, current)) = ready.pop_first() {
            start_order.push(current.clone());

            if let Some(deps) = dependents.get(&current) {
                for next in deps {
                    if let Some(deg) = in_degrees.get_mut(next) {
                        *deg -= 1;
                        if *deg == 0 {
                            let idx = index_map.get(next).copied().unwrap_or(0);
                            ready.insert((idx, next.clone()));
                        }
                    }
                }
            }
        }

        // 6. Détection de cycle si tous les modules n'ont pas pu être ordonnés
        if start_order.len() != descriptors.len() {
            let cycle_candidates: Vec<ModuleId> = in_degrees
                .into_iter()
                .filter(|(_, deg)| *deg > 0)
                .map(|(id, _)| id)
                .collect();

            let cycle = Self::extract_cycle(descriptors, &cycle_candidates);
            return Err(RuntimeError::DependencyCycle { cycle });
        }

        Ok(start_order)
    }

    /// Extrait un chemin de cycle représentatif à des fins de diagnostic et de log.
    fn extract_cycle(descriptors: &[ModuleDescriptor], candidates: &[ModuleId]) -> Vec<ModuleId> {
        let candidate_set: HashSet<&ModuleId> = candidates.iter().collect();
        let desc_map: HashMap<&ModuleId, &ModuleDescriptor> =
            descriptors.iter().map(|d| (&d.id, d)).collect();

        let mut visited: HashSet<ModuleId> = HashSet::new();
        let mut rec_stack: Vec<ModuleId> = Vec::new();

        for candidate in candidates {
            if !visited.contains(candidate) {
                if let Some(cycle) = Self::dfs_cycle(
                    candidate,
                    &desc_map,
                    &candidate_set,
                    &mut visited,
                    &mut rec_stack,
                ) {
                    return cycle;
                }
            }
        }

        candidates.to_vec()
    }

    fn dfs_cycle(
        current: &ModuleId,
        desc_map: &HashMap<&ModuleId, &ModuleDescriptor>,
        candidate_set: &HashSet<&ModuleId>,
        visited: &mut HashSet<ModuleId>,
        rec_stack: &mut Vec<ModuleId>,
    ) -> Option<Vec<ModuleId>> {
        visited.insert(current.clone());
        rec_stack.push(current.clone());

        if let Some(desc) = desc_map.get(current) {
            for dep in &desc.dependencies {
                if !candidate_set.contains(dep) {
                    continue;
                }

                if let Some(pos) = rec_stack.iter().position(|id| id == dep) {
                    let mut cycle: Vec<ModuleId> = rec_stack[pos..].to_vec();
                    cycle.push(dep.clone());
                    return Some(cycle);
                }

                if !visited.contains(dep) {
                    if let Some(cycle) =
                        Self::dfs_cycle(dep, desc_map, candidate_set, visited, rec_stack)
                    {
                        return Some(cycle);
                    }
                }
            }
        }

        rec_stack.pop();
        None
    }
}
