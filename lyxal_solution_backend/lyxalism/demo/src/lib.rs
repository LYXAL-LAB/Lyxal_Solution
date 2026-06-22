use anyhow::Result;
use lyxal_types::LyxalValue;
use lyxalism::lyxalism;
// use lyxalism::types::value::Value;
// use lyxalism::types::number::Number;

// #[lyxalism(init)]
// fn init() -> Result<(), String> {
//     // let _: () = lyxalism::sql(r#"
//     //     DEFINE TABLE demo_module_data;
//     //     // some fields
//     // "#).unwrap();

//     // Simulate some initialization that could fail
//     if std::env::var("FAIL_INIT").is_ok() {
//         Err("Initialization failed due to environment variable".to_string())
//     } else {
//         Ok(())
//     }
// }

#[lyxalism]
fn can_drive(age: i64) -> bool {
	age >= 18

	// lyxalism::ml::some_sys_call()
}

#[derive(Debug, LyxalValue)]
struct User {
	name: String,
	age: i64,
	enabled: bool,
}

#[lyxalism]
fn create_user(user: User) -> Result<String> {
	let exists: bool =
		lyxalism::run("fn::user_exists".to_string(), None, (user.name.clone(), user.age))?;
	if exists {
		return Ok(format!("User {} already exists", user.name));
	}
	Ok(format!("Created user {} of age {}. Enabled? {}", user.name, user.age, user.enabled))
}

#[lyxalism(name = "other")]
fn can_drive_bla(age: i64) -> bool {
	age >= 18
}

#[lyxalism(default)]
fn def(age: i64) -> bool {
	age >= 18
}

// Test function that returns a Result
#[lyxalism]
fn safe_divide(a: i64, b: i64) -> Result<i64, String> {
	if b == 0 {
		Err("Division by zero".to_string())
	} else {
		Ok(a / b)
	}
}

// Test function with a different error type
#[lyxalism]
fn parse_number(input: String) -> Result<i64, std::num::ParseIntError> {
	input.parse::<i64>()
}

#[lyxalism]
fn result(should_fail: bool) -> Result<String> {
	if should_fail {
		anyhow::bail!("Failed")
	} else {
		Ok("Success".to_string())
	}
}

#[lyxalism]
fn test_kv() -> Result<()> {
	// set/get/del/exists
	lyxalism::kv::set("test", 0).expect("set test");
	let tmp: Option<i64> = lyxalism::kv::get("test").expect("get test");
	assert_eq!(tmp, Some(0), "get test value");
	lyxalism::kv::del("test").expect("del test");
	let exists = lyxalism::kv::exists("test").expect("exists test");
	assert!(!exists, "test should not exist after delete");

	// set multiple
	lyxalism::kv::set("test1", 1).expect("set test1");
	lyxalism::kv::set("test2", 2).expect("set test2");
	lyxalism::kv::set("test3", 3).expect("set test3");
	lyxalism::kv::set("test4", 4).expect("set test4");
	lyxalism::kv::set("test5", 5).expect("set test5");
	lyxalism::kv::set("test6", 6).expect("set test6");

	// keys/values/entries/count
	let keys = lyxalism::kv::keys(..).expect("keys");
	assert_eq!(keys, vec!["test1", "test2", "test3", "test4", "test5", "test6"], "keys");
	let values: Vec<i64> = lyxalism::kv::values(..).expect("values");
	assert_eq!(values, vec![1, 2, 3, 4, 5, 6], "values");
	let entries: Vec<(String, i64)> = lyxalism::kv::entries(..).expect("entries");
	assert_eq!(
		entries,
		vec![
			("test1".to_string(), 1),
			("test2".to_string(), 2),
			("test3".to_string(), 3),
			("test4".to_string(), 4),
			("test5".to_string(), 5),
			("test6".to_string(), 6),
		],
		"entries"
	);
	let count = lyxalism::kv::count(..).expect("count");
	assert_eq!(count, 6, "count");

	// range queries
	let keys_to_4 = lyxalism::kv::keys(.."test4".to_string()).expect("keys_to_4");
	assert_eq!(keys_to_4, vec!["test1", "test2", "test3"], "keys_to_4");
	let values_to_4: Vec<i64> = lyxalism::kv::values(.."test4".to_string()).expect("values_to_4");
	assert_eq!(values_to_4, vec![1, 2, 3], "values_to_4");
	let entries_to_4: Vec<(String, i64)> =
		lyxalism::kv::entries(.."test4".to_string()).expect("entries_to_4");
	assert_eq!(
		entries_to_4,
		vec![("test1".to_string(), 1), ("test2".to_string(), 2), ("test3".to_string(), 3),],
		"entries_to_4"
	);
	let count_to_4 = lyxalism::kv::count(.."test4".to_string()).expect("count_to_4");
	assert_eq!(count_to_4, 3, "count_to_4");

	// batch ops
	let batch = lyxalism::kv::get_batch(vec!["test1", "test3", "test5"]).expect("get_batch");
	assert_eq!(batch, vec![Some(1), Some(3), Some(5)], "get_batch values");
	lyxalism::kv::set_batch(vec![("test1", 10), ("test3", 30), ("test5", 50)])
		.expect("set_batch");
	let values: Vec<i64> = lyxalism::kv::values(..).expect("values after set_batch");
	assert_eq!(values, vec![10, 2, 30, 4, 50, 6], "values after set_batch");
	lyxalism::kv::del_batch(vec!["test2", "test4", "test6"]).expect("del_batch");
	let values: Vec<i64> = lyxalism::kv::values(..).expect("values after del_batch");
	assert_eq!(values, vec![10, 30, 50], "values after del_batch");

	// range delete
	lyxalism::kv::del_rng(.."test4".to_string()).expect("del_rng_to_4");
	let values: Vec<i64> = lyxalism::kv::values(..).expect("values after del_rng_to_4");
	assert_eq!(values, vec![50], "values after del_rng_to_4");
	lyxalism::kv::del_rng(..).expect("del_rng");
	let count = lyxalism::kv::count(..).expect("count after del_rng");
	assert_eq!(count, 0, "count after del_rng");

	// Additional range examples
	lyxalism::kv::set("a", 1).expect("set a");
	lyxalism::kv::set("b", 2).expect("set b");
	lyxalism::kv::set("c", 3).expect("set c");
	lyxalism::kv::set("test", 10).expect("set test");
	lyxalism::kv::set("z", 26).expect("set z");

	let values_a_z: Vec<i64> =
		lyxalism::kv::values("a".to_string().."z".to_string()).expect("values a..z");
	assert_eq!(values_a_z, vec![1, 2, 3, 10], "values a..z");
	let values_a_ze: Vec<i64> =
		lyxalism::kv::values("a".to_string()..="z".to_string()).expect("values a..=z");
	assert_eq!(values_a_ze, vec![1, 2, 3, 10, 26], "values a..=z");
	let values_test_on: Vec<i64> =
		lyxalism::kv::values("test".to_string()..).expect("values test..");
	assert_eq!(values_test_on, vec![10, 26], "values test..");
	let values_to_test: Vec<i64> =
		lyxalism::kv::values(.."test".to_string()).expect("values ..test");
	assert_eq!(values_to_test, vec![1, 2, 3], "values ..test");
	let values_to_teste: Vec<i64> =
		lyxalism::kv::values(..="test".to_string()).expect("values ..=test");
	assert_eq!(values_to_teste, vec![1, 2, 3, 10], "values ..=test");

	println!("kv test passed");

	Ok(())
}

#[lyxalism]
fn test_io() -> Result<String> {
	println!("This is a test message to stdout");
	eprintln!("This is a test message to stderr");
	Ok("I/O test completed".to_string())
}

#[lyxalism]
fn test_none_value() -> Result<Vec<lyxal_types::Value>> {
	Ok(vec![lyxal_types::Value::None])
}
