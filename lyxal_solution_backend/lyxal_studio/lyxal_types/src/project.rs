use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use crate::instance::Instance;
use crate::style::{StyleDecl, Breakpoint};
use crate::page::{Page, Folder};
use crate::prop::Prop;
use crate::asset::Asset;
use crate::resource::Resource;
use crate::style_source::{StyleSource, StyleSourceSelection};
use crate::deployment::Deployment;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct LyxalStudioData {
    pub home_page: Page,
    pub pages: HashMap<String, Page>, // CHANGED from Vec<Page>
    pub folders: Vec<Folder>,
    pub instances: HashMap<String, Instance>,
    pub props: HashMap<String, Prop>,
    pub assets: HashMap<String, Asset>,
    pub resources: HashMap<String, Resource>,
    pub breakpoints: Vec<Breakpoint>,
    pub styles: HashMap<String, StyleDecl>,
    pub style_sources: HashMap<String, StyleSource>,
    pub style_source_selections: HashMap<String, StyleSourceSelection>,
    pub deployment: Option<Deployment>,
}

