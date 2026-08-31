pub mod call;
pub mod error;

pub use call::{validate_function_name, LyxalSurrealCall};
pub use error::LyxalSurrealError;
pub use lyxal_error::{LyxalCallError, LyxalError, LyxalResult};

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

    #[derive(serde::Serialize)]
    struct PrimitiveParams<'a> {
        email: &'a str,
    }

    #[derive(serde::Serialize)]
    struct RecordParams {
        account: surrealdb::RecordId,
    }

    #[derive(serde::Serialize)]
    struct DateParams {
        start_at: surrealdb::Datetime,
    }

    #[test]
    fn test_param_structs_serialize_cleanly() {
        let p1 = PrimitiveParams { email: "test@example.com" };
        assert!(serde_json::to_value(&p1).is_ok());

        let p2 = RecordParams { account: surrealdb::RecordId::from(("account", "yaniss")) };
        assert!(serde_json::to_value(&p2).is_ok());

        let p3 = DateParams { start_at: surrealdb::Datetime::default() };
        assert!(serde_json::to_value(&p3).is_ok());
    }
}
