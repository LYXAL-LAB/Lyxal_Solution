use crate::account::AccountRegistry;
use crate::consensus::ConsensusManager;
use crate::ledger::RealmLedger;
use crate::safety::SafetyManager;
use crate::transactions::{TransactionKind, TransactionRequest};
use anyhow::{anyhow, Result};
use parking_lot::RwLock;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tracing::{error, info, warn};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum ProviderId {
	Mock,
	Stripe,
	Sepa,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum PaymentKind {
	Deposit,
	Withdrawal,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum PaymentStatus {
	Pending,
	Succeeded,
	Failed,
	Disputed,
	Refunded,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum ApplyState {
	Recorded,
	Applied, // Credited or Debited
	Finalized,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExternalPayment {
	pub provider: ProviderId,
	pub external_id: String,
	pub account_id: u128,
	pub realm_id: Option<u128>,
	pub kind: PaymentKind,
	pub amount_micros: i64,
	pub status: PaymentStatus,
	pub observed_at_ns: u64,
	pub idempotency_key: [u8; 32],
	pub raw_digest: [u8; 32],
	pub tx_id: Option<u128>,
	pub apply_state: ApplyState,
}

pub struct SettlementManager {
	node_id: u128,
	db: Arc<lyxalkv::Tree>,
	consensus: Arc<ConsensusManager>,
	safety: Arc<SafetyManager>,
	accounts: Arc<RwLock<AccountRegistry>>,
}

impl SettlementManager {
	pub fn new(
		node_id: u128,
		db: Arc<lyxalkv::Tree>,
		consensus: Arc<ConsensusManager>,
		safety: Arc<SafetyManager>,
		accounts: Arc<RwLock<AccountRegistry>>,
	) -> Self {
		Self {
			node_id,
			db,
			consensus,
			safety,
			accounts,
		}
	}

	pub async fn ensure_leader(&self) -> Result<()> {
		if !self.consensus.is_leader().await {
			return Err(anyhow!("ErrNotLeader"));
		}
		Ok(())
	}

	fn get_key(provider: ProviderId, external_id: &str) -> String {
		format!("_settlement/events/{:?}/{}", provider, external_id)
	}

	pub async fn get_payment(
		&self,
		provider: ProviderId,
		external_id: &str,
	) -> Result<Option<ExternalPayment>> {
		let key = Self::get_key(provider, external_id);
		let txn = self.db.begin()?;
		if let Some(bytes) = txn.get(key.as_bytes())? {
			Ok(Some(bincode::deserialize(&bytes)?))
		} else {
			Ok(None)
		}
	}

	pub async fn ingest_deposit(&self, mut payment: ExternalPayment) -> Result<ExternalPayment> {
		self.ensure_leader().await?;

		if payment.kind != PaymentKind::Deposit {
			return Err(anyhow!("InvalidPaymentKind"));
		}

		if payment.amount_micros <= 0 {
			return Err(anyhow!("InvalidAmount"));
		}

		let key = Self::get_key(payment.provider, &payment.external_id);

		// 1. Idempotency Check
		{
			let txn = self.db.begin()?;
			if let Some(bytes) = txn.get(key.as_bytes())? {
				let existing: ExternalPayment = bincode::deserialize(&bytes)?;
				return Ok(existing);
			}
		}

		// 2. Step: Record (Recorded)
		payment.apply_state = ApplyState::Recorded;
		payment.status = PaymentStatus::Succeeded;
		{
			let mut txn = self.db.begin()?;
			txn.set(key.as_bytes(), bincode::serialize(&payment)?)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
		}

		// 3. Step: Apply to Ledger
		self.apply_to_ledger(&mut payment).await?;

		Ok(payment)
	}

	pub async fn initiate_withdrawal(
		&self,
		mut payment: ExternalPayment,
	) -> Result<ExternalPayment> {
		self.ensure_leader().await?;

		if payment.kind != PaymentKind::Withdrawal {
			return Err(anyhow!("InvalidPaymentKind"));
		}

		if payment.amount_micros <= 0 {
			return Err(anyhow!("InvalidAmount"));
		}

		// P28 Check: Sufficient balance
		let has_sufficient_balance = {
			let reg = self.accounts.read();
			let account = reg.get(payment.account_id).ok_or_else(|| anyhow!("AccountNotFound"))?;
			account.balance >= payment.amount_micros
		};

		if !has_sufficient_balance {
			return Err(anyhow!("InsufficientBalance"));
		}

		let key = Self::get_key(payment.provider, &payment.external_id);

		// 1. Idempotency Check
		{
			let txn = self.db.begin()?;
			if let Some(bytes) = txn.get(key.as_bytes())? {
				let existing: ExternalPayment = bincode::deserialize(&bytes)?;
				return Ok(existing);
			}
		}

		// 2. Step: Record (Recorded)
		payment.apply_state = ApplyState::Recorded;
		payment.status = PaymentStatus::Pending; // Withdrawals start as pending
		{
			let mut txn = self.db.begin()?;
			txn.set(key.as_bytes(), bincode::serialize(&payment)?)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
		}

		// 3. Step: Apply to Ledger (Debit)
		self.apply_to_ledger(&mut payment).await?;

		Ok(payment)
	}

	async fn apply_to_ledger(&self, payment: &mut ExternalPayment) -> Result<()> {
		// P31 Safety Check: Freeze check
		let status = {
			let guard = self.safety.governance.read();
			guard.get_status(payment.account_id)
		};

		if let crate::safety::governance::AccountSafetyStatus::Frozen {
			reason,
			..
		} = status
		{
			warn!(
				"Settlement: Deposit rejected for frozen account {}: {}",
				payment.account_id, reason
			);
			payment.status = PaymentStatus::Failed;
			payment.apply_state = ApplyState::Finalized;

			let key = Self::get_key(payment.provider, &payment.external_id);
			{
				let mut txn = self.db.begin()?;
				txn.set(key.as_bytes(), bincode::serialize(&payment)?)?;
				txn.commit().await.map_err(|e| anyhow!(e))?;
			}

			// Audit log - Bypass the lock because parking_lot guards are not Send
			let audit_log = crate::safety::audit::SecureAuditLog::new(self.db.clone());
			audit_log
				.log(
					payment.realm_id.unwrap_or(0),
					payment.account_id,
					"settlement".into(),
					0,
					crate::safety::audit::SafetyAction::Settlement,
					crate::safety::audit::SafetyDecision::Frozen,
					0, // risk_score
				)
				.await;
			return Ok(());
		}

		// Generate Tx ID for internal linkage
		let tx_id_full = blake3::hash(&payment.idempotency_key);
		let tx_id = u128::from_be_bytes(tx_id_full.as_bytes()[0..16].try_into()?);

		// Step: Mark Applied in state
		payment.tx_id = Some(tx_id);
		payment.apply_state = ApplyState::Applied;
		let key = Self::get_key(payment.provider, &payment.external_id);
		{
			let mut txn = self.db.begin()?;
			txn.set(key.as_bytes(), bincode::serialize(&payment)?)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
		}

		// Actually update Account Registry - Bypass the lock because parking_lot guards are not Send
		{
			let mut reg = crate::account::AccountRegistry::new(self.db.clone());
			match payment.kind {
				PaymentKind::Deposit => {
					reg.credit_balance(payment.account_id, payment.amount_micros).await?
				}
				PaymentKind::Withdrawal => {
					reg.debit_balance(payment.account_id, payment.amount_micros).await?
				}
			}
		}

		// Step: Mark Finalized
		payment.apply_state = ApplyState::Finalized;
		{
			let mut txn = self.db.begin()?;
			txn.set(key.as_bytes(), bincode::serialize(&payment)?)?;
			txn.commit().await.map_err(|e| anyhow!(e))?;
		}

		info!(
			"Settlement: Applied {:?} of {} to account {}",
			payment.kind, payment.amount_micros, payment.account_id
		);

		Ok(())
	}

	pub async fn recover(&self) -> Result<()> {
		info!("Settlement: Running recovery...");

		let to_recover = self.get_payments_to_recover()?;

		for mut payment in to_recover {
			info!("Settlement: Recovering payment {:?}/{}", payment.provider, payment.external_id);
			if let Err(e) = self.apply_to_ledger(&mut payment).await {
				error!("Settlement: Failed to recover payment: {}", e);
			}
		}

		Ok(())
	}

	fn get_payments_to_recover(&self) -> Result<Vec<ExternalPayment>> {
		let txn = self.db.begin()?;
		let mut it = txn.range(&b"_settlement/events/"[..], &b"_settlement/events/\xff"[..])?;
		let mut to_recover = Vec::new();

		while let Some(res) = it.next() {
			let (_key, bytes) = res.map_err(|e| anyhow!(e))?;
			let payment: ExternalPayment = bincode::deserialize(&bytes)?;

			if payment.apply_state != ApplyState::Finalized {
				to_recover.push(payment);
			}
		}
		Ok(to_recover)
	}
}
