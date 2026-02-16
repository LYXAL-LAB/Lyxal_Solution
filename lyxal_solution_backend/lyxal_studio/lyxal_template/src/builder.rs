use lyxal_types::instance::{Instance, InstanceChild};

use nanoid::nanoid;

pub struct TemplateBuilder {
    pub instances: Vec<Instance>,
}

impl TemplateBuilder {
    pub fn new() -> Self { Self { instances: Vec::new() } }

    pub fn create_instance(&mut self, component: &str, tag: Option<String>) -> String {
        let id = nanoid!();
        let instance = Instance {
            instance_type: "instance".to_string(),
            id: id.clone(),
            component: component.to_string(),
            tag,
            label: None,
            children: Vec::new(),
            props: Vec::new(),
        };
        self.instances.push(instance);
        id
    }

    pub fn add_child(&mut self, parent_id: &str, child_id: &str) {
        if let Some(parent) = self.instances.iter_mut().find(|i| i.id == parent_id) {
            parent.children.push(InstanceChild::Id { value: child_id.to_string() });
        }
    }
}

