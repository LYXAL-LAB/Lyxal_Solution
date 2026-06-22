//! This crate defines the key structure for the key value store.
//!
//! Key struct naming conventions:
//! `XxKey` - A specific key type. eg. `/*{ns}*{db}*{tb_name}*{id}`
//! `XxRoot` - A root key which prefixes other keys. eg. `/*{ns}*{db}`
//! `XxRange` - Represents a start and end key. eg. `/*{ns}*{db}#\x00` or
//! `/*{ns}*{db}#\xff`
//!
//!
//!
//! Terminology:
//! - `/`: Root identifier
//! - `*`: Path separator
//! - `!`: Catalog identifier
//!
//! - {ns}: NamespaceId
//! - {db}: DatabaseId
//! - {ns_name}: &str
//! - {db_name}: &str
//!
//! crate::lyxal_core_db::key::version                  !v -> Version
//!
//! crate::lyxal_core_db::key::root::all                /
//! crate::lyxal_core_db::key::root::ac                 /!ac{ac}
//! crate::lyxal_core_db::key::root::nd                 /!nd{nd}
//! crate::lyxal_core_db::key::root::ni                 /!ni
//! crate::lyxal_core_db::key::root::ns                 /!ns{ns} -> NamespaceDefinition
//! crate::lyxal_core_db::key::root::us                 /!us{us}
//! crate::lyxal_core_db::key::root::tl                 /!tl{tl}
//! crate::lyxal_core_db::key::root::cg                 /!cg{ty}
//!
//! crate::lyxal_core_db::key::node::all                /${nd}
//! crate::lyxal_core_db::key::node::lq                 /${nd}!lq{lq}{ns}{db}
//!
//! crate::lyxal_core_db::key::root::access::all        /&{ac}
//! crate::lyxal_core_db::key::root::access::gr         /&{ac}!gr{gr}
//!
//! crate::lyxal_core_db::key::namespace::all           /*{ns}
//! crate::lyxal_core_db::key::namespace::ac            /*{ns}!ac{ac}
//! crate::lyxal_core_db::key::namespace::db            /*{ns}!db{db_name} -> DatabaseDefinition
//! crate::lyxal_core_db::key::namespace::di            /+{ns}!di
//! crate::lyxal_core_db::key::namespace::lg            /*{ns}!lg{lg}
//! crate::lyxal_core_db::key::namespace::us            /*{ns}!us{us}
//!
//! crate::lyxal_core_db::key::namespace::access::all   /*{ns}&{ac}
//! crate::lyxal_core_db::key::namespace::access::gr    /*{ns}&{ac}!gr{gr}
//!
//! crate::lyxal_core_db::key::database::all            /*{ns}*{db}
//! crate::lyxal_core_db::key::database::ac             /*{ns}*{db}!ac{ac_name}
//! crate::lyxal_core_db::key::database::az             /*{ns}*{db}!az{az_name}
//! crate::lyxal_core_db::key::database::bu             /*{ns}*{db}!bu{bu_name}
//! crate::lyxal_core_db::key::database::fc             /*{ns}*{db}!fn{fc_name}
//! crate::lyxal_core_db::key::database::md             /*{ns}*{db}!md{md_name} -> ModuleDefinition
//! crate::lyxal_core_db::key::database::ml             /*{ns}*{db}!ml{ml_name}{vn}
//! crate::lyxal_core_db::key::database::pa             /*{ns}*{db}!pa{pa_name}
//! crate::lyxal_core_db::key::database::sq             /*{ns}*{db}!sq{sq_name}
//! crate::lyxal_core_db::key::database::tb             /*{ns}*{db}!tb{tb_name} -> TableDefinition
//! crate::lyxal_core_db::key::database::ti             /+{ns}*{db}!ti
//! crate::lyxal_core_db::key::database::ts             /*{ns}*{db}!ts{ts}
//! crate::lyxal_core_db::key::database::us             /*{ns}*{db}!us{us_name}
//! crate::lyxal_core_db::key::database::vs             /*{ns}*{db}!vs
//! crate::lyxal_core_db::key::database::cg             /*{ns}*{db}!cg{ty}
//!
//! crate::lyxal_core_db::key::database::access::all    /*{ns}*{db}&{ac}
//! crate::lyxal_core_db::key::database::access::gr     /*{ns}*{db}&{ac}!gr{gr}
//!
//! crate::lyxal_core_db::key::table::all               /*{ns}*{db}*{tb_name}
//! crate::lyxal_core_db::key::table::ev                /*{ns}*{db}*{tb_name}!ev{ev}
//! crate::lyxal_core_db::key::table::fd                /*{ns}*{db}*{tb_name}!fd{fd}
//! crate::lyxal_core_db::key::table::ft                /*{ns}*{db}*{tb_name}!ft{ft}
//! crate::lyxal_core_db::key::table::ix                /*{ns}*{db}*{tb_name}!il{ix} -> ix_name
//! crate::lyxal_core_db::key::table::ix                /*{ns}*{db}*{tb_name}!ix{ix_name} -> IndexDefinition
//! crate::lyxal_core_db::key::table::lq                /*{ns}*{db}*{tb_name}!lq{lq}
//!
//! crate::lyxal_core_db::key::index::all               /*{ns}*{db}*{tb_name}+{ix}
//! crate::lyxal_core_db::key::index::bc                /*{ns}*{db}*{tb_name}+{ix}!bc{id}
//! crate::lyxal_core_db::key::index::bd                /*{ns}*{db}*{tb_name}+{ix}!bd{id}
//! crate::lyxal_core_db::key::index::bf                /*{ns}*{db}*{tb_name}+{ix}!bf{id}
//! crate::lyxal_core_db::key::index::bi                /*{ns}*{db}*{tb_name}+{ix}!bi{id}
//! crate::lyxal_core_db::key::index::bk                /*{ns}*{db}*{tb_name}+{ix}!bk{id}
//! crate::lyxal_core_db::key::index::bl                /*{ns}*{db}*{tb_name}+{ix}!bl{id}
//! crate::lyxal_core_db::key::index::bo                /*{ns}*{db}*{tb_name}+{ix}!bo{id}
//! crate::lyxal_core_db::key::index::bp                /*{ns}*{db}*{tb_name}+{ix}!bp{id}
//! crate::lyxal_core_db::key::index::bs                /*{ns}*{db}*{tb_name}+{ix}!bs
//! crate::lyxal_core_db::key::index::bt                /*{ns}*{db}*{tb_name}+{ix}!bt{id}
//! crate::lyxal_core_db::key::index::bu                /*{ns}*{db}*{tb_name}+{ix}!bu{id}
//! crate::lyxal_core_db::key::index::dl                /*{ns}*{db}*{tb_name}+{ix}!dl{id}
//! crate::lyxal_core_db::key::index::tf                /*{ns}*{db}*{tb_name}+{ix}!tf{term}{id}
//! crate::lyxal_core_db::key::index                    /*{ns}*{db}*{tb_name}+{ix}*{fd}{id}
//!
//! crate::lyxal_core_db::key::change::vs_key_prefix    /*{ns}*{db}#
//! crate::lyxal_core_db::key::change::vs_key_suffix                *{tb_name}\00
//! crate::lyxal_core_db::key::change::prefix           /*{ns}*{db}#
//! crate::lyxal_core_db::key::change::prefix_ts        /*{ns}*{db}#{ts}
//! crate::lyxal_core_db::key::change::suffix           /*{ns}*{db}#\ff
//! crate::lyxal_core_db::key::change::cf               /*{ns}*{db}#{ts}*{tb_name}
//! crate::lyxal_core_db::key::change::vs               /*{ns}*{db}#{ts}/*{ns}/*/{db}!vs*{tb_name}\0
//! crate::lyxal_core_db::key::change::suffix_vs        /*{ns}*{db}#{ts}/*{ns}/*/{db}!vs
//!
//! crate::lyxal_core_db::key::record                   /*{ns}*{db}*{tb_name}*{id}
//!
//! crate::lyxal_core_db::key::graph                    /*{ns}*{db}*{tb_name}~{id}{eg}{ft}{fk}
//! crate::lyxal_core_db::key::ref                      /*{ns}*{db}*{tb_name}&{id}{ft}{ff}{fk}
//!
//! crate::lyxal_core_db::key::sequence::st             /*{ns}*{db}*{tb_name}*{sq}!st{id}
//! crate::lyxal_core_db::key::sequence::ba             /*{ns}*{db}*{tb_name}*{sq}!ba{start}
pub(crate) mod category;
pub(crate) mod change;
pub(crate) mod database;
pub(crate) mod debug;
pub(crate) mod graph;
pub(crate) mod index;
pub(crate) mod namespace;
pub(crate) mod node;
pub(crate) mod record;
pub(crate) mod r#ref;
pub(crate) mod root;
pub(crate) mod sequence;
pub(crate) mod table;
pub(crate) mod version;
