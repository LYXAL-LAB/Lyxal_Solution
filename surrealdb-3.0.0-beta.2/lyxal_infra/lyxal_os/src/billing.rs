use crate::registry_new::{PricingPlan, MeterKind, MoneyMicros};
use crate::accounting::UsageEvent;
use std::collections::HashMap;

pub struct LineItem {
    pub meter_id: String,
    pub measured: i64,
    pub chargeable: i64,
    pub cost_micros: MoneyMicros,
}

pub struct RatedPeriod {
    pub period_id: [u8; 32],
    pub account_id: u128,
    pub plan_id: String,
    pub cursor_start: u64,
    pub cursor_end: u64,
    pub items: Vec<LineItem>,  // Renamed to avoid confusion
    pub total_micros: MoneyMicros,
    // P30bis: For Invoice rendering
    pub line_items: HashMap<String, i64>,   // meter_id -> cost_micros
    pub meter_totals: HashMap<String, i64>, // meter_id -> units
}

pub struct BillingEngine;

impl BillingEngine {
    /// Pure function for rating events based on a plan.
    /// No I/O allowed here.
    pub fn rate(
        account_id: u128,
        plan: &PricingPlan,
        events: Vec<UsageEvent>,
        cursor_start: u64,
        cursor_end: u64,
    ) -> RatedPeriod {
        let mut aggregates: HashMap<String, i64> = HashMap::new();

        // 1. Process Events
        for event in events {
            if let Some(meter) = plan.meters.iter().find(|m| m.id == event.meter_id) {
                match meter.kind {
                    MeterKind::Sum => {
                        let entry = aggregates.entry(event.meter_id.clone()).or_insert(0);
                        *entry += event.units;
                    }
                    MeterKind::Max => {
                        let entry = aggregates.entry(event.meter_id.clone()).or_insert(0);
                        *entry = (*entry).max(event.units);
                    }
                }
            }
        }

        // 2. Generate Line Items
        let mut items = Vec::new();
        let mut total_micros: MoneyMicros = 0;
        let mut line_items_map: HashMap<String, i64> = HashMap::new();
        let mut meter_totals_map: HashMap<String, i64> = HashMap::new();

        for meter in &plan.meters {
            let measured = aggregates.get(&meter.id).copied().unwrap_or(0);
            let chargeable = (measured - meter.free_allowance).max(0);
            
            // Checked math to prevent overflows (prod-grade)
            let cost_micros = chargeable.checked_mul(meter.unit_price_micros).unwrap_or(MoneyMicros::MAX);
            
            // Apply hard cap if configured
            let final_cost = if let Some(cap) = meter.hard_cap {
                cost_micros.min(cap)
            } else {
                cost_micros
            };

            items.push(LineItem {
                meter_id: meter.id.clone(),
                measured,
                chargeable,
                cost_micros: final_cost,
            });

            // P30bis: Populate rendering maps
            line_items_map.insert(meter.id.clone(), final_cost);
            meter_totals_map.insert(meter.id.clone(), measured);

            total_micros = total_micros.checked_add(final_cost).unwrap_or(MoneyMicros::MAX);
        }

        // 3. Compute period_id (Idempotence Anchor)
        let mut hasher = blake3::Hasher::new();
        hasher.update(&account_id.to_be_bytes());
        hasher.update(plan.id.as_bytes());
        hasher.update(&cursor_start.to_be_bytes());
        hasher.update(&cursor_end.to_be_bytes());
        let period_id = hasher.finalize().into();

        RatedPeriod {
            period_id,
            account_id,
            plan_id: plan.id.clone(),
            cursor_start,
            cursor_end,
            items,
            total_micros,
            line_items: line_items_map,
            meter_totals: meter_totals_map,
        }
    }
}
