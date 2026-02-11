//! P30bis - Billing API Module (READ-ONLY)
//! 
//! Provides introspection, simulation, rendering, forecast, health, and metrics
//! without modifying P29 billing engine.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ============================================================================
// DTOs
// ============================================================================

/// Account health status
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AccountHealth {
    Ok,
    NearLimit,
    AtLimit,
    Blocked,
}

/// Forecast response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ForecastResponse {
    pub days_until_limit: Option<u32>,
    pub projected_daily_usage_micros: i64,
    pub current_balance_micros: i64,
    pub credit_limit_micros: i64,
    pub available_micros: i64,
}

/// Usage response - aggregated by meter_id
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsageResponse {
    pub account_id: String,
    pub meters: Vec<MeterUsage>,
    pub total_events: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MeterUsage {
    pub meter_id: String,
    pub total_units: i64,
    pub event_count: u64,
}

/// Simulation request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationRequest {
    pub plan_id: String,
    pub events: Vec<SimulationEvent>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationEvent {
    pub meter_id: String,
    pub units: i64,
}

/// Simulation response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationResponse {
    pub total_micros: i64,
    pub breakdown: Vec<SimulationBreakdown>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationBreakdown {
    pub meter_id: String,
    pub units: i64,
    pub free_allowance: i64,
    pub billable_units: i64,
    pub unit_price_micros: i64,
    pub cost_micros: i64,
}

/// Rendered invoice (human-readable)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenderedInvoice {
    pub invoice_id: String,
    pub account_id: String,
    pub period_start_seq: u64,
    pub period_end_seq: u64,
    pub plan_id: String,
    pub items: Vec<InvoiceLineItem>,
    pub total_micros: i64,
    pub total_formatted: String,  // "1.23€"
    pub status: String,
    pub kernel_signature: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceLineItem {
    pub meter_id: String,
    pub description: String,
    pub units: i64,
    pub units_formatted: String,  // "100MB"
    pub cost_micros: i64,
    pub cost_formatted: String,   // "0.80€"
}

/// Billing metrics snapshot
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BillingMetrics {
    pub total_accounts: u64,
    pub blocked_accounts: u64,
    pub near_limit_accounts: u64,
    pub total_balance_micros: i64,
    pub total_invoiced_micros: i64,
    pub outstanding_balance_micros: i64,
}

/// Account summary for list
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccountSummary {
    pub id: String,
    pub balance_micros: i64,
    pub credit_limit_micros: i64,
    pub pricing_plan_id: String,
    pub health: AccountHealth,
    pub realm_count: u32,
}

/// Ledger event for introspection
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LedgerEvent {
    pub seq: u64,
    pub ts_ns: u64,
    pub meter_id: String,
    pub units: i64,
    pub realm_id: String,
}

// ============================================================================
// Helper Functions (READ-ONLY)
// ============================================================================

/// Calculate account health based on balance and credit limit
/// Rules:
/// - available = balance + credit_limit
/// - Blocked: available < 0
/// - AtLimit: available == 0
/// - NearLimit: available > 0 AND available <= 20% of credit_limit (if credit_limit > 0)
/// - OK: otherwise
pub fn calculate_health(balance: i64, credit_limit: i64) -> AccountHealth {
    let available = balance + credit_limit;
    
    if available < 0 {
        return AccountHealth::Blocked;
    }
    
    if available == 0 {
        return AccountHealth::AtLimit;
    }
    
    // NearLimit: within 20% of credit limit
    if credit_limit > 0 {
        let threshold = credit_limit / 5; // 20%
        if available <= threshold {
            return AccountHealth::NearLimit;
        }
    }
    
    AccountHealth::Ok
}

/// Format micros to currency string (no floats)
/// 1_000_000 micros = 1€
pub fn format_micros_to_currency(micros: i64) -> String {
    let is_negative = micros < 0;
    let abs_micros = micros.abs();
    let euros = abs_micros / 1_000_000;
    let cents = (abs_micros % 1_000_000) / 10_000; // 2 decimal places
    
    if is_negative {
        format!("-{}.{:02}€", euros, cents)
    } else {
        format!("{}.{:02}€", euros, cents)
    }
}

/// Format bytes to human readable
pub fn format_bytes(bytes: i64) -> String {
    let abs_bytes = bytes.abs();
    if abs_bytes >= 1_073_741_824 {
        format!("{}GB", abs_bytes / 1_073_741_824)
    } else if abs_bytes >= 1_048_576 {
        format!("{}MB", abs_bytes / 1_048_576)
    } else if abs_bytes >= 1024 {
        format!("{}KB", abs_bytes / 1024)
    } else {
        format!("{}B", abs_bytes)
    }
}

/// Simulate pricing (dry-run) - duplicates P29 logic without side effects
pub fn simulate_pricing(
    plan: &lyxal_os::registry_new::PricingPlan,
    events: &[SimulationEvent],
) -> SimulationResponse {
    use lyxal_os::registry_new::MeterKind;
    
    // Aggregate events by meter_id
    let mut aggregates: HashMap<String, i64> = HashMap::new();
    for event in events {
        *aggregates.entry(event.meter_id.clone()).or_insert(0) += event.units;
    }
    
    let mut breakdown = Vec::new();
    let mut total_micros: i64 = 0;
    
    for meter in &plan.meters {
        let units = *aggregates.get(&meter.id).unwrap_or(&0);
        
        // Apply aggregation kind
        let aggregated_units = match meter.kind {
            MeterKind::Sum => units,
            MeterKind::Max => units, // For simulation, treat as sum
        };
        
        // Apply free allowance
        let billable_units = (aggregated_units - meter.free_allowance).max(0);
        
        // Calculate cost (checked arithmetic)
        let cost_micros = billable_units.saturating_mul(meter.unit_price_micros);
        
        breakdown.push(SimulationBreakdown {
            meter_id: meter.id.clone(),
            units: aggregated_units,
            free_allowance: meter.free_allowance,
            billable_units,
            unit_price_micros: meter.unit_price_micros,
            cost_micros,
        });
        
        total_micros = total_micros.saturating_add(cost_micros);
    }
    
    SimulationResponse {
        total_micros,
        breakdown,
    }
}

/// Calculate forecast based on recent usage
/// Returns days until limit is reached (None if not projected to reach)
pub fn calculate_forecast(
    balance: i64,
    credit_limit: i64,
    recent_daily_usage: i64,
) -> ForecastResponse {
    let available = balance + credit_limit;
    
    let days_until_limit = if recent_daily_usage > 0 && available > 0 {
        Some((available / recent_daily_usage) as u32)
    } else {
        None
    };
    
    ForecastResponse {
        days_until_limit,
        projected_daily_usage_micros: recent_daily_usage,
        current_balance_micros: balance,
        credit_limit_micros: credit_limit,
        available_micros: available,
    }
}

/// Render invoice to human-readable format
pub fn render_invoice(
    invoice: &lyxal_os::invoice::Invoice,
    plan: Option<&lyxal_os::registry_new::PricingPlan>,
) -> RenderedInvoice {
    let mut items = Vec::new();
    
    // Build line items from invoice breakdown
    for (meter_id, cost_micros) in &invoice.line_items {
        let units = invoice.meter_totals.get(meter_id).copied().unwrap_or(0);
        
        // Determine description
        let description = match meter_id.as_str() {
            "sync.delta.bytes" => "Sync Delta Bytes",
            "sync.snapshot.bytes" => "Sync Snapshot Bytes",
            "sync.peer.millis" => "Peer Connection Time",
            "storage.bytes" => "Storage",
            "kernel.action" => "Kernel Actions",
            _ => meter_id.as_str(),
        }.to_string();
        
        // Format units based on meter type
        let units_formatted = if meter_id.contains("bytes") {
            format_bytes(units)
        } else if meter_id.contains("millis") {
            format!("{}ms", units)
        } else {
            format!("{}", units)
        };
        
        items.push(InvoiceLineItem {
            meter_id: meter_id.clone(),
            description,
            units,
            units_formatted,
            cost_micros: *cost_micros,
            cost_formatted: format_micros_to_currency(*cost_micros),
        });
    }
    
    RenderedInvoice {
        invoice_id: hex::encode(&invoice.period_id),
        account_id: format!("{:032x}", invoice.account_id),
        period_start_seq: invoice.cursor_start,
        period_end_seq: invoice.cursor_end,
        plan_id: plan.map(|p| p.id.clone()).unwrap_or_else(|| "unknown".to_string()),
        items,
        total_micros: invoice.total_micros,
        total_formatted: format_micros_to_currency(invoice.total_micros),
        status: format!("{:?}", invoice.status),
        kernel_signature: invoice.signature.as_ref().map(|s| hex::encode(s)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_calculate_health() {
        // OK: plenty of available
        assert_eq!(calculate_health(5000, 5000), AccountHealth::Ok);
        
        // NearLimit: within 20% of credit limit
        assert_eq!(calculate_health(-4500, 5000), AccountHealth::NearLimit);
        
        // AtLimit: exactly zero available
        assert_eq!(calculate_health(-5000, 5000), AccountHealth::AtLimit);
        
        // Blocked: negative available
        assert_eq!(calculate_health(-6000, 5000), AccountHealth::Blocked);
    }
    
    #[test]
    fn test_format_micros_to_currency() {
        assert_eq!(format_micros_to_currency(1_000_000), "1.00€");
        assert_eq!(format_micros_to_currency(1_230_000), "1.23€");
        assert_eq!(format_micros_to_currency(50_000), "0.05€");
        assert_eq!(format_micros_to_currency(-1_000_000), "-1.00€");
    }
    
    #[test]
    fn test_format_bytes() {
        assert_eq!(format_bytes(100), "100B");
        assert_eq!(format_bytes(1024), "1KB");
        assert_eq!(format_bytes(1_048_576), "1MB");
        assert_eq!(format_bytes(1_073_741_824), "1GB");
    }
}
