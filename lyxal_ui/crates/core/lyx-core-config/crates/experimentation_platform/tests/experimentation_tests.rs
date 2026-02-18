### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
use chrono::Utc;
use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::experiments::helpers;
use serde_json::{Map, Value, json};
use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::ExperimentationFlags;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
Condition, Exp, Overrides,
database::models::{
ChangeReason, Description, Metrics,
experimentation::{
Experiment, ExperimentStatusType, ExperimentType, TrafficPercentage, Variant,
Variants,
},
},
result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
};

enum Dimensions {
Os(String),
Client(String),
#[allow(dead_code)]
VariantIds(String),
}

fn multiple_dimension_ctx_gen(values: Vec<Dimensions>) -> Map<String, Value> {
values
.into_iter()
.map(|val| {
let (key, value) = match val {
Dimensions::Os(os) => ("os".to_string(), json!(os)),
Dimensions::Client(lyx-core-lyx_core_lyx-core-lyx_core_client_id) => {
("lyx-core-lyx_core_lyx-core-lyx_core_clientId".to_string(), json!(lyx-core-lyx_core_lyx-core-lyx_core_client_id))
}
Dimensions::VariantIds(id) => ("variantIds".to_string(), json!(id)),
};
(key, value)
})
.collect::<Map<String, Value>>()
}

fn experiment_gen(
override_keys: &[String],
context: &Condition,
status: ExperimentStatusType,
variants: &[Variant],
) -> Experiment {
Experiment {
id: 123456789,
created_at: Utc::now(),
created_by: "test".to_string(),
last_modified: Utc::now(),
last_modified_by: "test".to_string(),
name: "experiment-test".to_string(),
experiment_type: ExperimentType::Default,
traffic_percentage: TrafficPercentage::default(),
started_at: None,
started_by: None,

override_keys: override_keys.to_vec(),
status,
context: context.clone(),
variants: Variants::new(variants.to_owned()),
chosen_variant: None,
description: Description::try_from(String::from("test")).unwrap(),
change_reason: ChangeReason::try_from(String::from("test")).unwrap(),
metrics: Metrics::default(),
experiment_group_id: None,
}
}

#[test]
fn test_duplicate_override_key_entries() {
let override_keys = vec!["key1".to_string(), "key2".to_string(), "key1".to_string()];
assert!(matches!(
helpers::validate_override_keys(&override_keys),
Err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument(_))
));
}

#[test]
fn test_unique_override_key_entries() {
let override_keys = vec!["key1".to_string(), "key2".to_string()];
assert!(matches!(
helpers::validate_override_keys(&override_keys),
Ok(())
));
}

#[test]
fn test_are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts() -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let context_a = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let context_a = Exp::<Condition>::try_from(context_a.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();

let context_b = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
]);
let context_b = Exp::<Condition>::try_from(context_b.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();

let context_c = multiple_dimension_ctx_gen(vec![Dimensions::Os("os1".to_string())]);
let context_d = multiple_dimension_ctx_gen(vec![Dimensions::Os("os2".to_string())]);
let context_c = Exp::<Condition>::try_from(context_c.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let context_d = Exp::<Condition>::try_from(context_d.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();

// both contexts with same dimensions
assert!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_a)?);
// contexts with one different dimension
assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_b)?));
// one context dimensions are subset of other
assert!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_c)?);
// one context dimensions not a subset of other but have less dimensions that other
assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_d)?));
// disjoint contexts
assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_c, &context_d)?));
Ok(())
}

#[test]
fn test_check_variants_override_coverage() -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let override_keys = vec!["key1".to_string(), "key2".to_string()];
let overrides = [
Exp::<Overrides>::try_from(Map::from_iter(vec![
("key1".to_string(), json!("value1")),
("key2".to_string(), json!("value2")),
])),
// has one override key missing
Exp::<Overrides>::try_from(Map::from_iter(vec![(
"key1".to_string(),
json!("value1"),
)])),
// has an unknown override key
Exp::<Overrides>::try_from(Map::from_iter(vec![(
"key3".to_string(),
json!("value3"),
)])),
// has an extra unknown override key
Exp::<Overrides>::try_from(Map::from_iter(vec![
("key1".to_string(), json!("value1")),
("key2".to_string(), json!("value2")),
("key3".to_string(), json!("value3")),
])),
]
.into_iter()
.map(|a| a.map(|b| b.into_inner()))
.collect::<Result<Vec<Overrides>, String>>()
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?;

assert!(helpers::check_variant_override_coverage(
&overrides[0],
&override_keys
));
assert!(!helpers::check_variant_override_coverage(
&overrides[1],
&override_keys
));
assert!(!helpers::check_variant_override_coverage(
&overrides[2],
&override_keys
));
assert!(!helpers::check_variant_override_coverage(
&overrides[3],
&override_keys
));
Ok(())
}

/************************* No Restrictions *****************************************/

#[test]
fn test_is_valid_experiment_no_restrictions_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key1".to_string(), "key2".to_string()],
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(true, "".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_no_restrictions_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key1".to_string(), "key2".to_string()],
&Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
Dimensions::Os("os2".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
]))
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner(),
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(true, "".to_string())
);

Ok(())
}

/************************* Restrict Same Keys Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/

#[test]
fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&experiment_override_keys,
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_same_key()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key1".to_string(), "key3".to_string()],
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key3".to_string(), "key4".to_string()],
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(true, "".to_string())
);

Ok(())
}

/************************* Restrict Different Keys Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/

#[test]
fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&experiment_override_keys,
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(true, "".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_diff_key()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key1".to_string(), "key3".to_string()],
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key3".to_string(), "key4".to_string()],
&experiment_context,
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

/************************* Restrict Same Keys Non Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/

#[test]
fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
};

let active_experiments = vec![experiment_gen(
&experiment_override_keys,
&Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
Dimensions::Os("os2".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
]))
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner(),
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_diff_key()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
};

let active_experiments = vec![experiment_gen(
&["key1".to_string(), "key3".to_string()],
&Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
Dimensions::Os("os2".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
]))
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner(),
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
);

Ok(())
}

#[test]
fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
-> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
let experiment_context = multiple_dimension_ctx_gen(vec![
Dimensions::Os("os1".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
]);
let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner();
let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
let flags = ExperimentationFlags {
allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
};

let active_experiments = vec![experiment_gen(
&["key3".to_string(), "key4".to_string()],
&Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
Dimensions::Os("os2".to_string()),
Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
]))
.map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
.into_inner(),
ExperimentStatusType::CREATED,
&[],
)];

assert_eq!(
helpers::is_valid_experiment(
&experiment_context,
&experiment_override_keys,
&flags,
&active_experiments
)?,
(true, "".to_string())
);

Ok(())
}
