pub mod discovery;
pub mod filesystem;
pub mod kind;
pub mod model;
pub mod provider;

pub use discovery::ResourceDiscovery;
pub use filesystem::{FilesystemResourceProvider, DEFAULT_MAX_RESOURCE_SIZE};
pub use kind::ResourceKind;
pub use model::ModuleResource;
pub use provider::ResourceProvider;
