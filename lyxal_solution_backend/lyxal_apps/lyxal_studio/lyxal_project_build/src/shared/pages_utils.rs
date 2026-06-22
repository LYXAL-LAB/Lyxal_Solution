use lyxal_types::page::Folder;
use lyxal_types::constants::ROOT_FOLDER_ID;

pub fn create_root_folder(children: Vec<String>) -> Folder {
    Folder {
        id: ROOT_FOLDER_ID.into(),
        name: "Root".into(),
        slug: "".into(),
        children,
    }
}

