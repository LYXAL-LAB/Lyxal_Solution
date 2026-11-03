// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Portions of this file are derived from Danube Messaging (danube-broker/src/dispatcher/poison_handler.rs),
// under Apache-2.0 license. Adapted for Lyxal OS by the Lyxal Development Team.

//! Gestion des messages poison (Poison Handler) — Stratégies Drop, Dead-Letter Queue et Block.
//!
//! Ce module prend en charge les messages ayant épuisé leur quota maximal de tentatives
//! de livraison (`RetryExhausted`). Il applique la politique configurée sans toucher
//! directement à la persistance ni au curseur (qui relève du dispatcher et de la fenêtre).

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tracing::warn;

use super::pending_delivery::PendingDelivery;

/// Erreur survenue lors de la résolution d'une politique de poison.
#[derive(Debug, thiserror::Error, Clone, PartialEq, Eq)]
pub enum PoisonError {
    /// La politique DeadLetter a été configurée sans spécifier de topic/destination DLQ.
    #[error("Dead letter topic must be configured for DeadLetter policy")]
    MissingDeadLetterTopic,
}

/// Politique d'action à appliquer lorsqu'un message a épuisé tous ses retries.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum PoisonPolicy {
    /// Le message est ignoré et abandonné. Le curseur avance.
    Drop,
    /// Le message est routé vers une Dead-Letter Queue (DLQ). Le curseur avance.
    #[default]
    DeadLetter,
    /// Le message est bloqué sur place, interrompant le dispatching séquentiel pour cette souscription.
    Block,
}

/// Résultat de l'application de la politique de poison.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PoisonResolution {
    /// Le message est résolu (soit dropé, soit routé vers la DLQ).
    /// Le dispatcher doit retirer le message de la fenêtre et avancer le curseur contigu.
    Resolved,
    /// Le message est bloqué sur place. Le dispatcher maintient le message en vol et n'avance pas le curseur.
    Blocked,
}

/// Enveloppe scellée d'un message envoyé en Dead-Letter Queue (DLQ).
///
/// Embarque l'ensemble des métadonnées contextuelles de traçabilité d'origine.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DeadLetterEnvelope {
    /// Nom du topic ou type d'événement d'origine.
    pub original_event_type: String,
    /// Offset / numéro de séquence d'origine dans la partition ou fenêtre.
    pub original_offset: u64,
    /// Nom de la souscription concernée.
    pub subscription_name: String,
    /// Nombre total de tentatives de livraison effectuées.
    pub delivery_attempt: u32,
    /// Dernier motif d'échec constaté.
    pub failure_reason: Option<String>,
    /// Politique de poison appliquée.
    pub poison_policy: PoisonPolicy,
    /// Topic de destination DLQ.
    pub dead_letter_topic: String,
    /// Données métier (payload JSON).
    pub payload: serde_json::Value,
    /// Métadonnées enrichies avec les attributs de diagnostic x-original-*.
    pub metadata: serde_json::Value,
}

/// Helper extrayant le nom du label de politique de poison.
#[must_use]
pub fn poison_policy_label(policy: &PoisonPolicy) -> &'static str {
    match policy {
        PoisonPolicy::Drop => "drop",
        PoisonPolicy::DeadLetter => "dead_letter",
        PoisonPolicy::Block => "block",
    }
}

/// Construit une enveloppe Dead-Letter à partir d'informations génériques.
#[must_use]
#[allow(clippy::too_many_arguments)]
pub fn build_dead_letter_envelope(
    original_event_type: String,
    original_offset: u64,
    subscription_name: &str,
    dead_letter_topic: &str,
    delivery_attempt: u32,
    failure_reason: Option<String>,
    poison_policy: PoisonPolicy,
    payload: serde_json::Value,
    existing_metadata: Option<serde_json::Value>,
) -> DeadLetterEnvelope {
    let mut meta_map: HashMap<String, serde_json::Value> = match existing_metadata {
        Some(serde_json::Value::Object(map)) => map.into_iter().collect(),
        _ => HashMap::new(),
    };

    meta_map.insert(
        "x-original-topic".to_string(),
        serde_json::Value::String(original_event_type.clone()),
    );
    meta_map.insert(
        "x-original-subscription".to_string(),
        serde_json::Value::String(subscription_name.to_string()),
    );
    meta_map.insert(
        "x-original-offset".to_string(),
        serde_json::Value::String(original_offset.to_string()),
    );
    meta_map.insert(
        "x-poison-policy".to_string(),
        serde_json::Value::String(poison_policy_label(&poison_policy).to_string()),
    );
    meta_map.insert(
        "x-delivery-attempt".to_string(),
        serde_json::Value::Number(delivery_attempt.into()),
    );

    if let Some(ref reason) = failure_reason {
        meta_map.insert(
            "x-failure-reason".to_string(),
            serde_json::Value::String(reason.clone()),
        );
    }

    DeadLetterEnvelope {
        original_event_type,
        original_offset,
        subscription_name: subscription_name.to_string(),
        delivery_attempt,
        failure_reason,
        poison_policy,
        dead_letter_topic: dead_letter_topic.to_string(),
        payload,
        metadata: serde_json::Value::Object(meta_map.into_iter().collect()),
    }
}

/// Résout la politique de poison pour un `PendingDelivery<T>` générique.
///
/// Retourne :
/// - `PoisonResolution::Resolved` avec `None` pour `PoisonPolicy::Drop`.
/// - `PoisonResolution::Resolved` avec `Some(DeadLetterEnvelope)` pour `PoisonPolicy::DeadLetter`.
/// - `PoisonResolution::Blocked` avec `None` pour `PoisonPolicy::Block`.
pub fn resolve_poison_policy<T, F>(
    pending: &PendingDelivery<T>,
    offset: u64,
    subscription_name: &str,
    policy: &PoisonPolicy,
    dead_letter_topic: Option<&str>,
    extractor: F,
) -> Result<(PoisonResolution, Option<DeadLetterEnvelope>), PoisonError>
where
    F: FnOnce(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
{
    match policy {
        PoisonPolicy::Drop => {
            warn!(
                offset = %offset,
                delivery_attempt = %pending.delivery_attempt,
                "Dropping retry-exhausted message (PoisonPolicy::Drop)"
            );
            Ok((PoisonResolution::Resolved, None))
        }
        PoisonPolicy::DeadLetter => {
            let dlq_topic = dead_letter_topic.ok_or(PoisonError::MissingDeadLetterTopic)?;
            let (event_type, payload, metadata) = extractor(&pending.message);

            let dlq_envelope = build_dead_letter_envelope(
                event_type,
                offset,
                subscription_name,
                dlq_topic,
                pending.delivery_attempt,
                pending.last_failure_reason.clone(),
                *policy,
                payload,
                metadata,
            );

            warn!(
                offset = %offset,
                delivery_attempt = %pending.delivery_attempt,
                dlq_topic = %dlq_topic,
                "Routed retry-exhausted message to DLQ (PoisonPolicy::DeadLetter)"
            );

            Ok((PoisonResolution::Resolved, Some(dlq_envelope)))
        }
        PoisonPolicy::Block => {
            warn!(
                offset = %offset,
                delivery_attempt = %pending.delivery_attempt,
                "Message blocked in dispatch window (PoisonPolicy::Block)"
            );
            Ok((PoisonResolution::Blocked, None))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[test]
    fn test_poison_drop_resolution() {
        let mut pending = PendingDelivery::new("test_payload".to_string());
        pending.delivery_attempt = 5;
        pending.last_failure_reason = Some("Handler error".into());

        let (res, dlq) =
            resolve_poison_policy(&pending, 42, "sub_test", &PoisonPolicy::Drop, None, |msg| {
                ("test.event".into(), serde_json::json!(msg), None)
            })
            .expect("Drop resolution should succeed");

        assert_eq!(res, PoisonResolution::Resolved);
        assert!(dlq.is_none());
    }

    #[test]
    fn test_poison_block_resolution() {
        let mut pending = PendingDelivery::new("test_payload".to_string());
        pending.delivery_attempt = 5;

        let (res, dlq) = resolve_poison_policy(
            &pending,
            42,
            "sub_test",
            &PoisonPolicy::Block,
            None,
            |msg| ("test.event".into(), serde_json::json!(msg), None),
        )
        .expect("Block resolution should succeed");

        assert_eq!(res, PoisonResolution::Blocked);
        assert!(dlq.is_none());
    }

    #[test]
    fn test_poison_dead_letter_missing_topic() {
        let mut pending = PendingDelivery::new("test_payload".to_string());
        pending.delivery_attempt = 5;

        let err = resolve_poison_policy(
            &pending,
            42,
            "sub_test",
            &PoisonPolicy::DeadLetter,
            None,
            |msg| ("test.event".into(), serde_json::json!(msg), None),
        )
        .expect_err("Missing topic must fail");

        assert_eq!(err, PoisonError::MissingDeadLetterTopic);
    }

    #[test]
    fn test_poison_dead_letter_envelope_metadata() {
        let mut pending = PendingDelivery::new("test_payload".to_string());
        pending.delivery_attempt = 3;
        pending.on_send_attempt("worker_1", Duration::from_secs(10));
        pending.last_failure_reason = Some("Database timeout".into());

        let (res, dlq) = resolve_poison_policy(
            &pending,
            100,
            "billing_sub",
            &PoisonPolicy::DeadLetter,
            Some("billing.dead_letter"),
            |msg| {
                (
                    "invoice.created".into(),
                    serde_json::json!({ "id": msg }),
                    Some(serde_json::json!({ "tenant": "acme" })),
                )
            },
        )
        .expect("Dead letter resolution must succeed");

        assert_eq!(res, PoisonResolution::Resolved);
        let env = dlq.expect("DLQ envelope must be generated");

        assert_eq!(env.original_event_type, "invoice.created");
        assert_eq!(env.original_offset, 100);
        assert_eq!(env.subscription_name, "billing_sub");
        assert_eq!(env.dead_letter_topic, "billing.dead_letter");
        assert_eq!(env.failure_reason, Some("Database timeout".into()));
        assert_eq!(env.delivery_attempt, 4);

        let meta = env.metadata.as_object().expect("metadata must be object");
        assert_eq!(
            meta.get("x-original-topic").and_then(|v| v.as_str()),
            Some("invoice.created")
        );
        assert_eq!(
            meta.get("x-original-subscription").and_then(|v| v.as_str()),
            Some("billing_sub")
        );
        assert_eq!(
            meta.get("x-original-offset").and_then(|v| v.as_str()),
            Some("100")
        );
        assert_eq!(
            meta.get("x-failure-reason").and_then(|v| v.as_str()),
            Some("Database timeout")
        );
        assert_eq!(
            meta.get("x-poison-policy").and_then(|v| v.as_str()),
            Some("dead_letter")
        );
        assert_eq!(meta.get("tenant").and_then(|v| v.as_str()), Some("acme"));
    }
}
