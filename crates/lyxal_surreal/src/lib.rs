#![allow(clippy::result_large_err)]

pub mod call;
pub mod client;
pub mod error;

pub use call::{validate_function_name, LyxalSurrealCall};
pub use client::{
    create_surreal_client, normalize_endpoint, validate_endpoint_scheme, RootCredentials,
};
pub use error::LyxalSurrealError;
pub use lyxal_error::{LyxalCallError, LyxalError, LyxalResult};

/// Types natifs du SDK SurrealDB exposés aux modules (§12.2 : alias définis dans `models/types.rs`).
pub use surrealdb::types::{Datetime, RecordId, SurrealValue, ToSql, Value};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_function_name() {
        assert!(validate_function_name("booking_generate_username"));
        assert!(validate_function_name("auth_login_v2"));
        assert!(!validate_function_name("booking;DROP TABLE account;"));
        assert!(!validate_function_name("fn::invalid"));
        assert!(!validate_function_name(""));
    }

    #[derive(SurrealValue)]
    struct PrimitiveParams {
        email: String,
    }

    #[derive(SurrealValue)]
    struct RecordParams {
        account: RecordId,
    }

    #[derive(SurrealValue)]
    struct DateParams {
        start_at: Datetime,
    }

    #[test]
    fn test_param_structs_convert_to_native_values() {
        let p1 = PrimitiveParams {
            email: "test@example.com".to_owned(),
        };
        assert!(matches!(p1.into_value(), Value::Object(_)));

        let account = RecordId::new("account", "yaniss");
        let p2 = RecordParams {
            account: account.clone(),
        };
        match p2.into_value() {
            Value::Object(obj) => assert_eq!(obj.get("account"), Some(&Value::RecordId(account))),
            other => panic!("objet attendu, obtenu {other:?}"),
        }

        let p3 = DateParams {
            start_at: Datetime::now(),
        };
        match p3.into_value() {
            Value::Object(obj) => assert!(matches!(obj.get("start_at"), Some(Value::Datetime(_)))),
            other => panic!("objet attendu, obtenu {other:?}"),
        }
    }
}
