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

//! Moteur de livraison et de dispatching pipeliné pour `lyxal_event`.
//!
//! Ce module constitue le cœur algorithmique de distribution in-process de LYXAL Event Engine.
//! Il encapsule la machine à états des livraisons unitaires (`pending_delivery`), la fenêtre
//! de suivi contigu des acquittements (`dispatch_window`), le traitement des messages poison (`poison_handler`)
//! et le dispatcher résilient in-process (`dispatcher`).
//!
//! # Statut & Isolation
//!
//! Ce module est strictement interne (`pub(crate)`) pour les Lots 1 & 2.
//! Aucun chemin de production ni aucun runtime actif n'est relié à ce moteur
//! tant que l'ensemble des lots n'a pas été formellement validé par le CTO.

#![allow(dead_code)]

pub mod consumer_bridge;
pub mod dispatch_window;
pub mod dispatcher;
pub mod dto;
pub mod feeder;
pub mod lease;
pub mod pending_delivery;
pub mod poison_handler;
pub mod progress;

#[allow(unused_imports)]
pub use consumer_bridge::{
    envelope_extractor, is_error_terminal, BridgeConfig, ConsumerOutcome, HandlerConsumerBridge,
    HandlerExecutionResult,
};

#[allow(unused_imports)]
pub use dispatch_window::{AckOutcome, DispatchWindow, DispatchWindowError};
#[allow(unused_imports)]
pub use dispatcher::{
    AckReport, ConsumerHandle, DispatchMessage, DispatcherConfig, DispatcherError, NackReport,
    ReliableDispatcher, WatchdogReport,
};
#[allow(unused_imports)]
pub use feeder::{FeederError, OutboxFeeder};
#[allow(unused_imports)]
pub use lease::{LeaseError, OutboxLeaseManager};
#[allow(unused_imports)]
pub use pending_delivery::{
    BackoffStrategy, DeliveryPolicy, PendingDelivery, PendingDeliveryStatus,
};
#[allow(unused_imports)]
pub use poison_handler::{
    build_dead_letter_envelope, resolve_envelope_poison, resolve_poison_policy,
    DeadLetterEnvelope, PoisonError, PoisonPolicy, PoisonResolution,
};
#[allow(unused_imports)]
pub use progress::{ProgressError, SubscriptionProgressTracker};
