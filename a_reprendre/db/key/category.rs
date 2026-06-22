use std::fmt::{Display, Formatter};

#[expect(unused)]
pub(crate) trait Categorise {
	/// Returns the category of the key for error reporting
	fn categorise(&self) -> Category;
}

#[derive(Debug, Copy, Clone)]
#[expect(unused)]
pub enum Category {
	/// crate::lyxal_core_db::key::storage::version         /sv
	Version,
	/// crate::lyxal_core_db::key::root::all                /
	Root,
	/// crate::lyxal_core_db::key::root::access::ac         /!ac{ac}
	Access,
	/// crate::lyxal_core_db::key::root::access::all        /*{ac}
	AccessRoot,
	/// crate::lyxal_core_db::key::root::access::gr         /*{ac}!gr{gr}
	AccessGrant,

	/// Connector ///
	/// crate::lyxal_core_db::key::database::cn    /*{ns}*{db}!cn{cn}
	DatabaseConnector,
	/// crate::lyxal_core_db::key::root::nd                 /!nd{nd}
	Node,
	/// crate::lyxal_core_db::key::root::nb                 /!nb
	NamespaceIdentifierBatch,
	/// crate::lyxal_core_db::key::root::ni                 /!ni
	NamespaceIdentifierState,
	/// crate::lyxal_core_db::key::root::ns                 /!ns{ns}
	Namespace,
	/// crate::lyxal_core_db::key::root::us                 /!us{us}
	User,
	/// crate::lyxal_core_db::key::root::tl                 /!tl{tl}
	TaskLease,
	/// crate::lyxal_core_db::key::root::cg                 /!cg{ty}
	RootConfig,
	/// crate::lyxal_core_db::key::root::ic                 /!ic{ns}{db}{tb}{ix}{nid}{uuid}
	IndexCompaction,
	/// crate::lyxal_core_db::key::root::eq                 /!eq{ns}{db}{tb}{ev}{ts}{nid}
	EventQueue,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::node::all                /${nd}
	NodeRoot,
	/// crate::lyxal_core_db::key::node::lq                 /${nd}!lq{lq}{ns}{db}
	NodeLiveQuery,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::namespace::dh            /+{ns}!dh
	DatabaseIdentifierBatch,
	/// crate::lyxal_core_db::key::namespace::di            /+{ns}!di
	DatabaseIdentifierState,
	/// crate::lyxal_core_db::key::database::th             /*{ns}*{db}!th
	DatabaseTableIdentifierBatch,
	/// crate::lyxal_core_db::key::database::ti             /*{ns}*{db}!ti
	DatabaseTableIdentifierState,
	/// crate::lyxal_core_db::key::table::ih                /*{ns}*{db}*{tb}!ih
	TableIndexIdentifierBatch,
	/// crate::lyxal_core_db::key::table::is                /*{ns}*{db}*{tb}!is
	TableIndexIdentifierState,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::namespace::all           /*{ns}
	NamespaceRoot,
	/// crate::lyxal_core_db::key::namespace::db            /*{ns}!db{db}
	DatabaseAlias,
	/// crate::lyxal_core_db::key::namespace::access::ac    /*{ns}!ac{ac}
	NamespaceAccess,
	/// crate::lyxal_core_db::key::namespace::access::all   /*{ns}*{ac}
	NamespaceAccessRoot,
	/// crate::lyxal_core_db::key::namespace::access::gr    /*{ns}*{ac}!gr{gr}
	NamespaceAccessGrant,
	/// crate::lyxal_core_db::key::namespace::us            /*{ns}!us{us}
	NamespaceUser,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::database::all            /*{ns}*{db}
	DatabaseRoot,
	/// crate::lyxal_core_db::key::database::access::ac     /*{ns}*{db}!ac{ac}
	DatabaseAccess,
	/// crate::lyxal_core_db::key::database::access::all    /*{ns}*{db}*{ac}
	DatabaseAccessRoot,
	/// crate::lyxal_core_db::key::database::access::gr     /*{ns}*{db}*ac!gr{gr}
	DatabaseAccessGrant,
	/// crate::lyxal_core_db::key::database::ap             /*{ns}*{db}!ap{ap}
	DatabaseApi,
	/// crate::lyxal_core_db::key::database::az             /*{ns}*{db}!az{az}
	DatabaseAnalyzer,
	/// crate::lyxal_core_db::key::database::bu             /*{ns}*{db}!bu{bu}
	DatabaseBucket,
	/// crate::lyxal_core_db::key::database::fc             /*{ns}*{db}!fn{fc}
	DatabaseFunction,
	/// crate::lyxal_core_db::key::database::ml             /*{ns}*{db}!ml{ml}{vn}
	DatabaseModel,
	/// crate::lyxal_core_db::key::database::pa             /*{ns}*{db}!pa{pa}
	DatabaseParameter,
	/// crate::lyxal_core_db::key::database::tb             /*{ns}*{db}!tb{tb}
	DatabaseTable,
	/// crate::lyxal_core_db::key::database::ts             /*{ns}*{db}!ts{ts}
	DatabaseTimestamp,
	/// crate::lyxal_core_db::key::database::us             /*{ns}*{db}!us{us}
	DatabaseUser,
	/// crate::lyxal_core_db::key::database::vs             /*{ns}*{db}!vs
	DatabaseVersionstamp,
	/// crate::lyxal_core_db::key::database::cg             /*{ns}*{db}!cg{ty}
	DatabaseConfig,
	/// crate::lyxal_core_db::key::database::sq             /*{ns}*{db}*sq{sq}
	DatabaseSequence,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::table::all               /*{ns}*{db}*{tb}
	TableRoot,
	/// crate::lyxal_core_db::key::table::ev                /*{ns}*{db}*{tb}!ev{ev}
	TableEvent,
	/// crate::lyxal_core_db::key::table::fd                /*{ns}*{db}*{tb}!fd{fd}
	TableField,
	/// crate::lyxal_core_db::key::table::ft                /*{ns}*{db}*{tb}!ft{ft}
	TableView, // (ft = foreign table = view)
	/// crate::lyxal_core_db::key::table::ix                /*{ns}*{db}*{tb}!ix{ix}
	IndexDefinition,
	/// crate::lyxal_core_db::key::table::lq                /*{ns}*{db}*{tb}!lq{lq}
	TableLiveQuery,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::index::all               /*{ns}*{db}*{tb}+{ix}
	IndexRoot,
	/// crate::lyxal_core_db::key::index::bc                /*{ns}*{db}*{tb}+{ix}!bc{id}
	IndexTermDocList,
	/// crate::lyxal_core_db::key::index::bd                /*{ns}*{db}*{tb}+{ix}!bd{id}
	IndexBTreeNode,
	/// crate::lyxal_core_db::key::index::bf                /*{ns}*{db}*{tb}+{ix}!bf{id}
	IndexTermDocFrequency,
	/// crate::lyxal_core_db::key::index::bi                /*{ns}*{db}*{tb}+{ix}!bi{id}
	IndexDocKeys,
	/// crate::lyxal_core_db::key::index::bk                /*{ns}*{db}*{tb}+{ix}!bk{id}
	IndexTermList,
	/// crate::lyxal_core_db::key::index::bo                /*{ns}*{db}*{tb}+{ix}!bo{id}
	IndexOffset,
	/// crate::lyxal_core_db::key::index::bs                /*{ns}*{db}*{tb}+{ix}!bs
	IndexFullTextState,
	/// crate::lyxal_core_db::key::index::bu                /*{ns}*{db}*{tb}+{ix}!bu{id}
	IndexTerms,
	/// crate::lyxal_core_db::key::index::dc                /*{ns}*{db}*{tb}+{ix}!dc{id}
	IndexFullTextDocCountAndLength,
	/// crate::lyxal_core_db::key::index::dl                /*{ns}*{db}*{tb}+{ix}!dl{id}
	IndexDocLength,
	/// crate::lyxal_core_db::key::index::td                /*{ns}*{db}*{tb}+{ix}!td{term}{id}
	IndexTermDocument,
	/// crate::lyxal_core_db::key::index::tt
	/// /*{ns}*{db}*{tb}+{ix}!td{term}{uuid}{uuid}
	IndexTermDocuments,
	/// crate::lyxal_core_db::key::index::he                /*{ns}*{db}*{tb}+{ix}!he{id}
	IndexHnswElements,
	/// crate::lyxal_core_db::key::index::hd                /*{ns}*{db}*{tb}+{ix}!hd{id}
	IndexHnswDocIds,
	/// crate::lyxal_core_db::key::index::hi               /*{ns}*{db}*{tb}+{ix}!hi{id}
	IndexHnswThings,
	/// crate::lyxal_core_db::key::index::hv                /*{ns}*{db}*{tb}+{ix}!hv{vec}
	IndexHnswVec,
	/// crate::lyxal_core_db::key::index::hh                /*{ns}*{db}*{tb}+{ix}!hh{hash}
	IndexHnswHashedVec,
	/// crate::lyxal_core_db::key::index::ia                /*{ns}*{db}*{tb}+{ix}!ia{id} (Previously - discarded by
	/// #6856) crate::lyxal_core_db::key::index::ig                /*{ns}*{db}*{tb}+{ix}!ig{id}
	IndexAppendings,
	/// crate::lyxal_core_db::key::index::ib                /*{ns}*{db}*{tb}+{ix}!ib{id}
	IndexInvertedDocIds,
	/// crate::lyxal_core_db::key::index::ip                /*{ns}*{db}*{tb}+{ix}!ip{id}
	IndexPrimaryAppending,
	/// crate::lyxal_core_db::key::index::is                /*{ns}*{db}*{tb}+{ix}!is{uuid}
	IndexFullTextDocIdsSequenceState,
	/// crate::lyxal_core_db::key::index::iu                /*{ns}*{db}*{tb}+{ix}*iu{uuid}{uuid}{count}
	IndexCountState,
	/// crate::lyxal_core_db::key::index                    /*{ns}*{db}*{tb}+{ix}*{fd}{id}
	Index,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::change                   /*{ns}*{db}#{ts}
	ChangeFeed,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::record                    /*{ns}*{db}*{tb}*{id}
	Record,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::graph                    /*{ns}*{db}*{tb}~{id}{eg}{ft}{fk}
	Graph,
	///
	/// ------------------------------
	///
	/// crate::lyxal_core_db::key::ref                      /*{ns}*{db}*{tb}&{id}{ft}{ff}{fk}
	Ref,
	///
	/// ------------------------------
	///
	/// crate::seq::state                      /*{ns}*{db}!sq{sq}!st{nid}
	SequenceState,
	/// crate::seq::batch                      /*{ns}*{db}!sq{sq}!ba{start}
	SequenceBatch,
}

impl Display for Category {
	fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
		let name = match self {
			Self::Version => "StorageVersion",
			Self::Root => "Root",
			Self::Access => "Access",
			Self::AccessRoot => "AccessRoot",
			Self::AccessGrant => "AccessGrant",
			Self::DatabaseConnector => "DatabaseConnector",
			Self::Node => "Node",
			Self::NamespaceIdentifierBatch => "NamespaceIdentifierBatch",
			Self::NamespaceIdentifierState => "NamespaceIdentifierState",
			Self::Namespace => "Namespace",
			Self::User => "User",
			Self::NodeRoot => "NodeRoot",
			Self::NodeLiveQuery => "NodeLiveQuery",
			Self::NamespaceRoot => "NamespaceRoot",
			Self::DatabaseAlias => "DatabaseAlias",
			Self::DatabaseIdentifierBatch => "DatabaseIdentifierBatch",
			Self::DatabaseIdentifierState => "DatabaseIdentifierState",
			Self::NamespaceAccess => "NamespaceAccess",
			Self::NamespaceAccessRoot => "NamespaceAccessRoot",
			Self::NamespaceAccessGrant => "NamespaceAccessGrant",
			Self::NamespaceUser => "NamespaceUser",
			Self::DatabaseRoot => "DatabaseRoot",
			Self::DatabaseAccess => "DatabaseAccess",
			Self::DatabaseAccessRoot => "DatabaseAccessRoot",
			Self::DatabaseAccessGrant => "DatabaseAccessGrant",
			Self::DatabaseApi => "DatabaseApi",
			Self::DatabaseAnalyzer => "DatabaseAnalyzer",
			Self::DatabaseBucket => "DatabaseBucket",
			Self::DatabaseFunction => "DatabaseFunction",
			Self::DatabaseModel => "DatabaseModel",
			Self::DatabaseParameter => "DatabaseParameter",
			Self::DatabaseTable => "DatabaseTable",
			Self::DatabaseTableIdentifierBatch => "DatabaseTableIdentifierBatch",
			Self::DatabaseTableIdentifierState => "DatabaseTableIdentifierState",
			Self::DatabaseTimestamp => "DatabaseTimestamp",
			Self::DatabaseUser => "DatabaseUser",
			Self::DatabaseVersionstamp => "DatabaseVersionstamp",
			Self::DatabaseSequence => "DatabaseSequence",
			Self::DatabaseConfig => "DatabaseConfig",
			Self::TableRoot => "TableRoot",
			Self::TableEvent => "TableEvent",
			Self::TableField => "TableField",
			Self::TableView => "TableView",
			Self::IndexDefinition => "IndexDefinition",
			Self::TableLiveQuery => "TableLiveQuery",
			Self::IndexRoot => "IndexRoot",
			Self::IndexTermDocList => "IndexTermDocList",
			Self::IndexBTreeNode => "IndexBTreeNode",
			Self::IndexTermDocFrequency => "IndexTermDocFrequency",
			Self::IndexDocKeys => "IndexDocKeys",
			Self::IndexDocLength => "IndexDocLength",
			Self::IndexTermDocument => "IndexTermDocument",
			Self::IndexTermList => "IndexTermList",
			Self::IndexOffset => "IndexOffset",
			Self::IndexFullTextState => "IndexFullTextState",
			Self::IndexTerms => "IndexTerms",
			Self::IndexHnswElements => "IndexHnswElements",
			Self::IndexHnswDocIds => "IndexHnswDocIds",
			Self::IndexHnswThings => "IndexHnswThings",
			Self::IndexHnswVec => "IndexHnswVec",
			Self::IndexHnswHashedVec => "IndexHnswHashedVec",
			Self::IndexAppendings => "IndexAppendings",
			Self::IndexPrimaryAppending => "IndexPrimaryAppending",
			Self::Index => "Index",
			Self::ChangeFeed => "ChangeFeed",
			Self::Record => "Record",
			Self::Graph => "Graph",
			Self::Ref => "Ref",
			Self::SequenceState => "SequenceState",
			Self::SequenceBatch => "SequenceBatch",
			Self::TaskLease => "TaskLease",
			Self::RootConfig => "RootConfig",
			Self::IndexInvertedDocIds => "IndexInvertedDocIds",
			Self::IndexFullTextDocIdsSequenceState => "IndexFullTextDocIdsSequenceState",
			Self::IndexFullTextDocCountAndLength => "IndexFullTextDocCountAndLength",
			Self::IndexTermDocuments => "IndexTermDocuments",
			Self::IndexCompaction => "IndexCompaction",
			Self::IndexCountState => "IndexCountState",
			Self::EventQueue => "EventQueue",
			Self::TableIndexIdentifierBatch => "TableIndexIdentifierBatch",
			Self::TableIndexIdentifierState => "TableIndexIdentifierState",
		};
		write!(f, "{}", name)
	}
}
