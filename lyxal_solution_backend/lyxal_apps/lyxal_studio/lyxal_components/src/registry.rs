use crate::meta::ComponentMeta;
use std::collections::HashMap;
use lazy_static::lazy_static;

lazy_static! {
    pub static ref COMPONENT_METADATA: HashMap<&'static str, ComponentMeta> = {
        let mut m = HashMap::new();
        m.insert("Box", ComponentMeta { label: "Box".into(), category: "general".into(), icon: "box".into(), description: Some("A simple container".into()) });
        m.insert("Text", ComponentMeta { label: "Text".into(), category: "typography".into(), icon: "text".into(), description: Some("Text block".into()) });
        m.insert("Heading", ComponentMeta { label: "Heading".into(), category: "typography".into(), icon: "heading".into(), description: Some("Heading element".into()) });
        m.insert("Image", ComponentMeta { label: "Image".into(), category: "media".into(), icon: "image".into(), description: Some("Image element".into()) });
        m.insert("Link", ComponentMeta { label: "Link".into(), category: "general".into(), icon: "link".into(), description: Some("Hyperlink".into()) });
        m.insert("Button", ComponentMeta { label: "Button".into(), category: "general".into(), icon: "button".into(), description: Some("Clickable button".into()) });
        // Portage intÃ©gral des composants Radix
        m.insert("Accordion", ComponentMeta { label: "Accordion".into(), category: "radix".into(), icon: "accordion".into(), description: Some("Accordion component".into()) });
        m.insert("Tabs", ComponentMeta { label: "Tabs".into(), category: "radix".into(), icon: "tabs".into(), description: Some("Tabs component".into()) });
        m
    };
}

