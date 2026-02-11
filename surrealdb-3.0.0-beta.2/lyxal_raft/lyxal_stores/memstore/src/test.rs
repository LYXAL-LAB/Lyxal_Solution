use std::sync::Arc;

use lyxal_raft::StorageError;
use lyxal_raft::testing::log::StoreBuilder;
use lyxal_raft::testing::log::Suite;
use lyxal_raft::type_config::TypeConfigExt;

use crate::MemLogStore;
use crate::MemStateMachine;
use crate::TypeConfig;

struct MemStoreBuilder {}

impl StoreBuilder<TypeConfig, Arc<MemLogStore>, Arc<MemStateMachine>, ()> for MemStoreBuilder {
	async fn build(
		&self,
	) -> Result<((), Arc<MemLogStore>, Arc<MemStateMachine>), StorageError<TypeConfig>> {
		let (log_store, sm) = crate::new_mem_store();
		Ok(((), log_store, sm))
	}
}

#[test]
pub fn test_mem_store() {
	TypeConfig::run(async {
		Suite::test_all(MemStoreBuilder {}).await.unwrap();
	});
}
