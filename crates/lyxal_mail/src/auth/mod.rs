// SPDX-License-Identifier: AGPL-3.0-only

//! Authenticité du courrier reçu (plan du lot 5, §6) : SPF, DKIM, DMARC, nom inverse
//! (`iprev`) et en-tête `Authentication-Results`.
//!
//! Décision S1 : code écrit dans `lyxal_mail` ; toute la cryptographie passe par
//! `lyxal_crypto::dkim` (règle 13 du §11.3) — lecture des balises, choix des en-têtes de `h=`,
//! DNS, `t=` / `x=`, `i=` / `d=`, politique de `l=` et résultats sont écrits ici, les octets
//! signés et la vérification restent dans `lyxal_crypto`. `mail-auth` n'est jamais une
//! dépendance. Provenance : `SOURCES.md` (écrit depuis les RFC ; cas d'essai transposés de
//! Mox).
//!
//! Tout passe par [`crate::dns::MailResolver`] ; aucune donnée personnelle n'est journalisée ;
//! chaque contrôle est borné en requêtes et en temps.

mod dkim;
mod dmarc;
mod domain;
mod headers;
mod iprev;
mod psl;
mod results;
mod spf;

pub use dkim::{DkimOutput, DkimResult, DkimVerifier, MAX_VERIFIED_SIGNATURES};
pub use dmarc::{
    author_domains, sample_roll, Alignment, DmarcDisposition, DmarcOutput, DmarcPolicy,
    DmarcRecord, DmarcResult, DmarcVerifier, MAX_AUTHOR_DOMAINS,
};
pub use domain::{is_same_or_subdomain, is_valid_domain, to_ascii_domain};
pub use headers::{HeaderError, HeaderField, MessageHeaders, MAX_HEADER_FIELDS};
pub use iprev::{Iprev, IprevOutput, IprevResult};
pub use psl::{OrganizationalDomain, PublicSuffixList, PublicSuffixListError};
pub use results::{strip_forged_results, AuthenticationResults};
pub use spf::{SpfIdentity, SpfLimits, SpfOutput, SpfResult, SpfVerifier};
