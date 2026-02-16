//! Leptos port of shadcn/ui table

mod signal_managed;
mod default;
mod new_york;
pub mod data_table;

pub use default::{Table};
pub use new_york::{Table as TableNewYork};
pub use data_table::{
    DataTable, DataRow, DataColumn, DataTableState,
    SortDirection, FilterType, FilterOperator, SelectionMode, ExportFormat,
    ColumnFilter, RowAction
};

mod tests;

mod tdd_tests;

mod data_table_tests;

// Signal-managed exports
pub use signal_managed::*;
