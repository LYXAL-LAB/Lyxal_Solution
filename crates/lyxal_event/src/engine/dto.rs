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

//! Contrats DTO et adaptateurs typés pour les fonctions SurrealQL du Lot 3B.1.
//!
//! Ce module formalise les paramètres d'appel (`*Params`) et les résultats typés (`*Result`)
//! transmis au runtime SurrealDB via le trait universel [`lyxal_surreal::LyxalSurrealCall`].

use serde::{Deserialize, Serialize};
use surrealdb::sql::Datetime;

// ----------------------------------------------------------------------------
// 1. Bail distribué & Fencing (fn::event_lease_*)
// ----------------------------------------------------------------------------

/// Paramètres d'acquisition du bail (`fn::event_lease_acquire`).
#[derive(Debug, Clone, Serialize)]
pub struct LeaseAcquireParams {
    pub node_id: String,
    pub ttl_seconds: u64,
}

/// Résultat d'acquisition du bail (`fn::event_lease_acquire`).
#[derive(Debug, Clone, Deserialize)]
pub struct LeaseAcquireResult {
    pub acquired: bool,
    pub generation: u64,
    pub owner_node_id: String,
    pub expires_at: Option<Datetime>,
}

/// Paramètres de renouvellement du bail (`fn::event_lease_renew`).
#[derive(Debug, Clone, Serialize)]
pub struct LeaseRenewParams {
    pub node_id: String,
    pub generation: u64,
    pub ttl_seconds: u64,
}

/// Résultat de renouvellement du bail (`fn::event_lease_renew`).
#[derive(Debug, Clone, Deserialize)]
pub struct LeaseRenewResult {
    pub renewed: bool,
    pub generation: u64,
    pub expires_at: Option<Datetime>,
}

/// Paramètres de libération du bail (`fn::event_lease_release`).
#[derive(Debug, Clone, Serialize)]
pub struct LeaseReleaseParams {
    pub node_id: String,
    pub generation: u64,
}

/// Résultat de libération du bail (`fn::event_lease_release`).
#[derive(Debug, Clone, Deserialize)]
pub struct LeaseReleaseResult {
    pub released: bool,
}

// ----------------------------------------------------------------------------
// 2. Attribution séquentielle & Création (fn::event_delivery_assign_seq)
// ----------------------------------------------------------------------------

/// Paramètres d'attribution de séquence contiguë (`fn::event_delivery_assign_seq`).
#[derive(Debug, Clone, Serialize)]
pub struct DeliveryAssignSeqParams {
    pub outbox_event: String,
    pub subscription: String,
    pub target_module: String,
    pub node_id: String,
    pub generation: u64,
    pub context: serde_json::Value,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub lock_seconds: Option<u64>,
}

// ----------------------------------------------------------------------------
// 3. Flush granulaire des résultats (fn::event_flush_batch)
// ----------------------------------------------------------------------------

/// Paramètres de flush granulaire et d'avancement de curseur (`fn::event_flush_batch`).
#[derive(Debug, Clone, Serialize)]
pub struct FlushBatchParams {
    pub subscription: String,
    pub target_cursor: u64,
    pub node_id: String,
    pub generation: u64,
    pub delivered_ids: Vec<String>,
    pub dead_letter_ids: Vec<String>,
    pub dropped_ids: Vec<String>,
    pub drop_reason: Option<String>,
}

/// Résultat de flush granulaire (`fn::event_flush_batch`).
#[derive(Debug, Clone, Deserialize)]
pub struct FlushBatchResult {
    pub flushed: bool,
    pub persisted_cursor: u64,
    pub delivered_count: usize,
    pub dead_letter_count: usize,
    pub dropped_count: usize,
}

// ----------------------------------------------------------------------------
// 4. Transfert DLQ (fn::event_dead_letter_transfer)
// ----------------------------------------------------------------------------

/// Paramètres de transfert en quarantaine DLQ (`fn::event_dead_letter_transfer`).
#[derive(Debug, Clone, Serialize)]
pub struct DeadLetterTransferParams {
    pub delivery_id: String,
    pub error: String,
    pub node_id: String,
    pub generation: u64,
}

/// Résultat de transfert en quarantaine DLQ (`fn::event_dead_letter_transfer`).
#[derive(Debug, Clone, Deserialize)]
pub struct DeadLetterTransferResult {
    pub dead_lettered: bool,
    pub dlq_id: String,
}

// ----------------------------------------------------------------------------
// 5. Progression d'abonnement (fn::event_progress_get)
// ----------------------------------------------------------------------------

/// Paramètres de lecture de progression durable (`fn::event_progress_get`).
#[derive(Debug, Clone, Serialize)]
pub struct ProgressGetParams {
    pub subscription: String,
}

/// Résultat de lecture de progression durable (`fn::event_progress_get`).
#[derive(Debug, Clone, Deserialize)]
pub struct ProgressGetResult {
    pub subscription: String,
    pub partition: u32,
    pub last_assigned_seq: u64,
    pub last_persisted_cursor: u64,
    pub exists: bool,
    pub updated_at: Option<Datetime>,
}

// ----------------------------------------------------------------------------
// 6. Polling des livraisons éligibles (fn::event_delivery_fetch_pending)
// ----------------------------------------------------------------------------

/// Paramètres de récupération des livraisons en attente (`fn::event_delivery_fetch_pending`).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeliveryFetchPendingParams {
    pub limit: usize,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub instance_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub subscription: Option<String>,
}

/// Enregistrement d'une livraison éligible renvoyé par `fn::event_delivery_fetch_pending`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PendingDeliveryItem {
    pub id: surrealdb::sql::Thing,
    pub created_at: Option<Datetime>,
    pub outbox_event: surrealdb::sql::Thing,
    pub subscription: surrealdb::sql::Thing,
    pub target_module: String,
    pub context: Option<serde_json::Value>,
    pub event_id: Option<String>,
    pub event_type: Option<String>,
    pub version: Option<u32>,
    pub producer: Option<String>,
    pub source: Option<surrealdb::sql::Thing>,
    pub correlation_id: Option<String>,
    pub causation_id: Option<String>,
    pub payload: Option<serde_json::Value>,
    pub metadata: Option<serde_json::Value>,
}

