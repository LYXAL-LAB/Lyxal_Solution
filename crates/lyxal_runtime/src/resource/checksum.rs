use crate::resource::model::ModuleResource;
use lyxal_crypto::hash::Sha256Hasher;

/// Empreinte SHA-256 d'une suite ordonnée de ressources : nature, chemin et contenu de chacune,
/// dans l'ordre fourni. Sert d'empreinte à une release de module et au socle.
///
/// Chaque champ est précédé de sa longueur : deux suites différentes ne donnent jamais la même
/// séquence d'octets.
pub struct ResourceChecksum(Sha256Hasher);

impl Default for ResourceChecksum {
    fn default() -> Self {
        Self::new()
    }
}

impl ResourceChecksum {
    /// Crée une empreinte vide.
    pub fn new() -> Self {
        Self(Sha256Hasher::new())
    }

    fn field(&mut self, value: &str) {
        self.0.update(&(value.len() as u64).to_be_bytes());
        self.0.update(value.as_bytes());
    }

    /// Ajoute un séparateur nommé (identifiant du module dont les ressources suivent).
    pub fn scope(&mut self, name: &str) {
        self.field("scope");
        self.field(name);
    }

    /// Ajoute une ressource : nature, chemin logique et contenu.
    pub fn resource(&mut self, resource: &ModuleResource) {
        self.field(&resource.kind.to_string());
        self.field(&resource.logical_path);
        self.field(&resource.content);
    }

    /// Empreinte hexadécimale (64 caractères).
    pub fn finalize(self) -> String {
        self.0.finalize_hex()
    }

    /// Empreinte d'une suite de ressources.
    pub fn of<'a>(resources: impl IntoIterator<Item = &'a ModuleResource>) -> String {
        let mut checksum = Self::new();
        for resource in resources {
            checksum.resource(resource);
        }
        checksum.finalize()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::resource::kind::ResourceKind;

    fn resource(path: &str, kind: ResourceKind, content: &str) -> ModuleResource {
        ModuleResource::new(path, kind, content)
    }

    #[test]
    fn checksum_depends_on_kind_path_content_and_order() {
        let a = resource("schema/a.surql", ResourceKind::Schema, "DEFINE TABLE a;");
        let b = resource("functions/b.surql", ResourceKind::Function, "RETURN 1;");
        let reference = ResourceChecksum::of([&a, &b]);
        assert_eq!(reference.len(), 64);
        assert_eq!(reference, ResourceChecksum::of([&a, &b]));

        assert_ne!(reference, ResourceChecksum::of([&b, &a]), "ordre");
        let renamed = resource("schema/z.surql", ResourceKind::Schema, "DEFINE TABLE a;");
        assert_ne!(reference, ResourceChecksum::of([&renamed, &b]), "chemin");
        let edited = resource("schema/a.surql", ResourceKind::Schema, "DEFINE TABLE a2;");
        assert_ne!(reference, ResourceChecksum::of([&edited, &b]), "contenu");
        let moved = resource("schema/a.surql", ResourceKind::Seed, "DEFINE TABLE a;");
        assert_ne!(reference, ResourceChecksum::of([&moved, &b]), "nature");
    }

    #[test]
    fn checksum_separates_fields_by_length() {
        let joined = resource("ab", ResourceKind::Schema, "c");
        let split = resource("a", ResourceKind::Schema, "bc");
        assert_ne!(
            ResourceChecksum::of([&joined]),
            ResourceChecksum::of([&split])
        );
    }
}
