use crate::registry::{Policy, PolicyPrincipal, PolicyScope, PolicyEffect};

pub const ACTION_REALM_CREATE: &str = "realm:create";
pub const ACTION_REALM_START: &str = "realm:start";
pub const ACTION_REALM_DRAIN: &str = "realm:drain";
pub const ACTION_REALM_STOP: &str = "realm:stop";
pub const ACTION_REALM_DELETE: &str = "realm:delete";
pub const ACTION_SYNC_SNAPSHOT: &str = "sync:snapshot";
pub const ACTION_SYNC_DRAIN: &str = "sync:drain";
pub const ACTION_DS_APPLY: &str = "desired_state:apply";

pub struct EvalContext {
    pub principal: u128,      // node_id du demandeur
    pub realm_id: Option<u128>,
    pub service: Option<&'static str>,
    pub action: &'static str,
    pub resource: String,     // ex: "realm:0x1234"
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Decision {
    Allow,
    Deny,
}

#[derive(Debug, Clone)]
pub struct PolicyDecision {
    pub decision: Decision,
    pub matched: Vec<String>,     // policy ids
    pub reason: Option<String>,
}

pub fn evaluate(ctx: &EvalContext, policies: &[Policy]) -> PolicyDecision {
    let mut sorted_policies = policies.to_vec();
    sorted_policies.sort_by(|a, b| a.id.cmp(&b.id)); // Ordre stable

    let mut deny_hit = false;
    let mut allow_hit = false;
    let mut matched_ids = Vec::new();

    for policy in &sorted_policies {
        // Scope match
        let scope_match = match &policy.scope {
            PolicyScope::Global => true,
            PolicyScope::Realm(id) => ctx.realm_id == Some(*id),
            PolicyScope::Service(name) => ctx.service == Some(name),
        };

        if !scope_match {
            continue;
        }

        for rule in &policy.rules {
            // Principal match
            let principal_match = match rule.principal {
                PolicyPrincipal::Any => true,
                PolicyPrincipal::Node(id) => ctx.principal == id,
            };

            if !principal_match {
                continue;
            }

            // Action match (wildcard)
            if !match_pattern(&rule.action, ctx.action) {
                continue;
            }

            // Resource match (wildcard)
            if !match_pattern(&rule.resource, &ctx.resource) {
                continue;
            }

            // Hit!
            matched_ids.push(policy.id.clone());
            match rule.effect {
                PolicyEffect::Deny => {
                    deny_hit = true;
                }
                PolicyEffect::Allow => {
                    allow_hit = true;
                }
            }
        }
    }

    let final_decision = if deny_hit {
        Decision::Deny
    } else if allow_hit {
        Decision::Allow
    } else {
        Decision::Deny // Deny par défaut
    };

    PolicyDecision {
        decision: final_decision,
        matched: matched_ids,
        reason: None,
    }
}

fn match_pattern(pattern: &str, target: &str) -> bool {
    if pattern == "*" {
        return true;
    }
    if pattern.ends_with("*") {
        let prefix = &pattern[..pattern.len() - 1];
        return target.starts_with(prefix);
    }
    pattern == target
}
