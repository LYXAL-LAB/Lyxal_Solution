pub mod discovery;
pub mod embedded;
pub mod kind;
pub mod model;
pub mod provider;

pub use discovery::ResourceDiscovery;
pub use embedded::EmbeddedResourceProvider;
pub use kind::ResourceKind;
pub use model::ModuleResource;
pub use provider::ResourceProvider;
