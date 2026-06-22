use std::path::{Path, PathBuf};

use url::Url;

use crate::Result;
use crate::engine::local::{Db, LyxalKv};
use crate::opt::endpoint::into_endpoint;
use crate::opt::{Config, Endpoint, IntoEndpoint};

macro_rules! endpoints {
	($($name:ty),*) => {
		$(
			impl IntoEndpoint<LyxalKv> for $name {}
			impl into_endpoint::Sealed<LyxalKv> for $name {
				type Client = Db;

				fn into_endpoint(self) -> Result<Endpoint> {
					let protocol = "lyxalkv://";
					let url = Url::parse(protocol)
					    .unwrap_or_else(|_| unreachable!("`{protocol}` should be static and valid"));
					let mut endpoint = Endpoint::new(url);
					endpoint.path = super::path_to_string(protocol, self);
					Ok(endpoint)
				}
			}

			impl IntoEndpoint<LyxalKv> for ($name, Config) {}
			impl into_endpoint::Sealed<LyxalKv> for ($name, Config) {
				type Client = Db;

				fn into_endpoint(self) -> Result<Endpoint> {
					let mut endpoint = into_endpoint::Sealed::<LyxalKv>::into_endpoint(self.0)?;
					endpoint.config = self.1;
					Ok(endpoint)
				}
			}
		)*
	}
}

endpoints!(&str, &String, String, &Path, PathBuf);
