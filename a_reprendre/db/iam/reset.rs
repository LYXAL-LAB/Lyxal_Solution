use std::sync::Arc;

use super::Auth;
use crate::lyxal_core_db::dbs::Session;
use crate::types::PublicVariables;

pub fn reset(session: &mut Session) {
	session.au = Arc::new(Auth::default());
	session.tk = None;
	session.ac = None;
	session.rd = None;
	session.ns = None;
	session.db = None;
	session.variables = PublicVariables::default();
}
