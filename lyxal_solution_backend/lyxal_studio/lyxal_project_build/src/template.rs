use lyxal_types::page::{Page, Pages, Folder, PageMeta};
use lyxal_types::constants::ROOT_FOLDER_ID;
use nanoid::nanoid;

pub fn create_default_project() -> Pages {
    let home_id = nanoid!();
    let home_body_id = nanoid!();
    let not_found_id = nanoid!();
    let not_found_body_id = nanoid!();

    Pages {
        home_page: Page {
            id: home_id.clone(),
            name: "Home".into(),
            path: "".into(),
            root_instance_id: home_body_id,
            meta: PageMeta {
                title: "Home".into(),
                description: None,
                exclude_page_from_search: None,
                language: None,
                social_image_asset_id: None,
                social_image_url: None,
                status: None,
                redirect: None,
                custom: None,
                document_type: None,
            },
        },
        pages: vec![Page {
            id: not_found_id.clone(),
            name: "404".into(),
            path: "/*".into(),
            root_instance_id: not_found_body_id,
            meta: PageMeta {
                title: "Page not found".into(),
                description: None,
                exclude_page_from_search: None,
                language: None,
                social_image_asset_id: None,
                social_image_url: None,
                status: Some(serde_json::json!("404")),
                redirect: None,
                custom: None,
                document_type: None,
            },
        }],
        folders: vec![Folder {
            id: ROOT_FOLDER_ID.into(),
            name: "Root".into(),
            slug: "".into(),
            children: vec![home_id, not_found_id],
        }],
    }
}

