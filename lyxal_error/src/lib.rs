#![allow(clippy::large_enum_variant, clippy::result_large_err)]

pub mod error;
pub mod result;

pub use error::{LyxalCallError, LyxalError};
pub use result::LyxalResult;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_into_result_valid_ok() {
        let res: LyxalResult<String> = LyxalResult {
            ok: true,
            data: Some("username_test".to_string()),
            error: None,
        };
        assert_eq!(res.into_result("test_func").unwrap(), "username_test");
    }

    #[test]
    fn test_into_result_rejects_inconsistent_ok_true_with_none_data() {
        let res: LyxalResult<String> = LyxalResult {
            ok: true,
            data: None,
            error: None,
        };
        assert!(matches!(
            res.into_result("test_func"),
            Err(LyxalCallError::InvalidContract {
                function: "test_func"
            })
        ));
    }

    #[test]
    fn test_into_result_rejects_inconsistent_ok_false_with_some_data() {
        let err = LyxalError {
            code: "TEST_ERR".to_string(),
            message: "msg".to_string(),
            label: "label".to_string(),
            description: None,
            resolution: None,
            category: "business".to_string(),
            severity: "error".to_string(),
            http_status: Some(400),
            retryable: false,
            documentation: serde_json::json!({}),
            metadata: serde_json::json!({}),
            details: serde_json::json!({}),
        };

        let res: LyxalResult<String> = LyxalResult {
            ok: false,
            data: Some("data".to_string()),
            error: Some(err),
        };
        assert!(matches!(
            res.into_result("test_func"),
            Err(LyxalCallError::InvalidContract {
                function: "test_func"
            })
        ));
    }
}
