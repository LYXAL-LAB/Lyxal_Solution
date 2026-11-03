pub mod model;
pub mod parser;
pub mod validation;

pub use model::{
    ModuleDependency, ModuleManifest, ModuleResources, RuntimeRequirement, CURRENT_MANIFEST_VERSION,
};
pub use parser::ManifestParser;
pub use validation::ManifestValidator;
