use lyxal_types::instance::{Instance, InstanceChild};
use lyxal_types::LyxalStudioData;
use nanoid::nanoid;

pub struct TreeManager;

impl TreeManager {
    pub fn insert_child(
        data: &mut LyxalStudioData,
        parent_id: &str,
        component: &str,
        index: Option<usize>,
    ) -> Result<String, String> {
        let new_id = nanoid!();
        let new_instance = Instance {
            instance_type: "instance".to_string(),
            id: new_id.clone(),
            component: component.to_string(),
            tag: None,
            label: None,
            children: Vec::new(),
            props: Vec::new(),
        };
        data.instances.insert(new_id.clone(), new_instance);
        if let Some(parent) = data.instances.get_mut(parent_id) {
            let child_ref = InstanceChild::Id { value: new_id.clone() };
            if let Some(i) = index {
                if i <= parent.children.len() {
                    parent.children.insert(i, child_ref);
                } else {
                    parent.children.push(child_ref);
                }
            } else {
                parent.children.push(child_ref);
            }
            Ok(new_id)
        } else {
            Err(format!("Parent {} not found", parent_id))
        }
    }

    pub fn delete_recursive(data: &mut LyxalStudioData, instance_id: &str) -> Result<(), String> {
        if let Some(instance) = data.instances.remove(instance_id) {
            for child in instance.children {
                if let InstanceChild::Id { value } = child {
                    Self::delete_recursive(data, &value)?;
                }
            }
            for p in data.instances.values_mut() {
                p.children.retain(|c| {
                    match c {
                        InstanceChild::Id { value } => value != instance_id,
                        _ => true,
                    }
                });
            }
            Ok(())
        } else {
            Err(format!("Instance {} not found", instance_id))
        }
    }

    pub fn reparent(
        data: &mut LyxalStudioData,
        instance_id: &str,
        new_parent_id: &str,
        index: Option<usize>,
    ) -> Result<(), String> {
        for p in data.instances.values_mut() {
            p.children.retain(|c| {
                match c {
                    InstanceChild::Id { value } => value != instance_id,
                    _ => true,
                }
            });
        }
        if let Some(parent) = data.instances.get_mut(new_parent_id) {
            let child_ref = InstanceChild::Id { value: instance_id.to_string() };
            if let Some(i) = index {
                if i <= parent.children.len() {
                    parent.children.insert(i, child_ref);
                } else {
                    parent.children.push(child_ref);
                }
            } else {
                parent.children.push(child_ref);
            }
            Ok(())
        } else {
            Err(format!("New parent {} not found", new_parent_id))
        }
    }
}
