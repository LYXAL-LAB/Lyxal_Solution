// lyxal/core/src/function/list.rs
//
// Fonctions natives Lyxal — domaine list::
// Opérations d'intelligence de collection (haut niveau)
//
// list::dedupe    — dédoublonnage par clé spécifique
// list::aggregate — agrégation sur un champ (sum/avg/min/max/collect)
// list::split_out — éclate un sous-tableau en rows séparés (LEFT JOIN)
// list::diff      — delta complet entre deux listes

use std::collections::{HashMap, HashSet};

use anyhow::Result;

use crate::error::Error;
use crate::db::val::{Array, Object, Value};
use lyxal_types::ToSql;

// ============================================================
//  HELPER : extraire une clé string propre depuis une Value
//  Distingue Value::String des autres types pour éviter
//  le bug .to_sql() qui produirait "'1'" au lieu de "1"
// ============================================================
fn extract_key(val: &Value) -> String {
    match val {
         Value::String(s) => s.clone(),
        other            => other.to_sql(),
    }
}

/// Helper : extraire la valeur d'un champ depuis un Value::Object
fn obj_get<'a>(item: &'a Value, field: &str) -> Option<&'a Value> {
    match item {
        Value::Object(obj) => obj.get(field),
        _ => None,
    }
}

/// Helper : extraire la valeur f64 d'un champ depuis un Value::Object
fn obj_get_f64(item: &Value, field: &str) -> Option<f64> {
    match item {
        Value::Object(obj) => {
            obj.get(field).and_then(|v| {
                match v {
                    Value::Number(n) => Some(n.to_float()),
                    _ => None,
                }
            })
        }
        _ => None,
    }
}

// ============================================================
//  list::dedupe($array: array, $field: string) -> array
//  Dédoublonnage par valeur d'un champ spécifique
// ============================================================
pub(crate) fn dedupe((array, field): (Array, String)) -> Result<Value> {
    let mut seen   = HashSet::new();
    let mut result = Vec::new();

    for item in array.iter() {
        if let Some(val) = obj_get(item, &field) {
            let key = extract_key(val);
            if seen.insert(key) {
                result.push(item.clone());
            }
            // doublon -> on ignore silencieusement
        } else {
            // champ absent -> on conserve l'item
            result.push(item.clone());
        }
    }

    Ok(Value::Array(result.into()))
}

// ============================================================
//  list::aggregate($array: array, $field: string, $op: string) -> any
//  Opérations : "sum" | "avg" | "min" | "max" | "collect"
// ============================================================
pub(crate) fn aggregate((array, field, op): (Array, String, String)) -> Result<Value> {

    // "collect" traité en premier : pas d'itération numérique inutile
    if op == "collect" {
        let collected: Vec<Value> = array
            .iter()
            .filter_map(|item| obj_get(item, &field).cloned())
            .collect();
        return Ok(Value::Array(collected.into()));
    }

    // Itérateur lazy sur les valeurs numériques du champ
    let numbers = || {
        array
            .iter()
            .filter_map(|item| obj_get_f64(item, &field))
    };

    match op.as_str() {
        "sum" => {
            let mut total = 0.0_f64;
            let mut count = 0_usize;
            for n in numbers() { total += n; count += 1; }
            // Tableau vide ou champ absent -> None (cohérent avec avg/min/max)
            if count == 0 { return Ok(Value::None); }
            Ok(Value::from(total))
        }

        "avg" => {
            let mut total = 0.0_f64;
            let mut count = 0_usize;
            for n in numbers() { total += n; count += 1; }
            if count == 0 { return Ok(Value::None); }
            Ok(Value::from(total / count as f64))
        }

        "min" => Ok(numbers()
            .reduce(f64::min)
            .map(Value::from)
            .unwrap_or(Value::None)),

        "max" => Ok(numbers()
            .reduce(f64::max)
            .map(Value::from)
            .unwrap_or(Value::None)),

        _ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
            name: "list::aggregate".into(),
            message: format!(
                "Opération '{}' inconnue. Valeurs acceptées : sum | avg | min | max | collect",
                op
            ),
        })),
    }
}

// ============================================================
//  list::split_out($array: array, $field: string) -> array
//  Éclate un sous-tableau en rows séparés
//  Comportement LEFT JOIN : tableau vide -> item conservé intact
// ============================================================
pub(crate) fn split_out((array, field): (Array, String)) -> Result<Value> {
    let mut result = Vec::new();

    for item in array.iter() {
        match obj_get(item, &field) {
            Some(Value::Array(sub)) if !sub.is_empty() => {
                // Cas nominal : on éclate chaque valeur du sous-tableau
                for sub_val in sub.iter() {
                    // Clone l'item et remplace le champ par la sous-valeur
                    if let Value::Object(obj) = item {
                        let mut new_obj = obj.clone();
                        new_obj.insert(field.clone(), sub_val.clone());
                        result.push(Value::Object(new_obj));
                    } else {
                        result.push(item.clone());
                    }
                }
            }
            // Tableau vide ou champ absent -> LEFT JOIN, item conservé
            _ => result.push(item.clone()),
        }
    }

    Ok(Value::Array(result.into()))
}

// ============================================================
//  list::diff($base: array, $new: array, $key: string) -> object
//  Delta complet entre deux listes
//  Retourne : { added, removed, modified: [{key, before, after, changes}] }
//  Erreur explicite si des doublons de clé sont détectés
// ============================================================
pub(crate) fn diff((base, new, key): (Array, Array, String)) -> Result<Value> {
    let base_map = build_index(&base, &key)?;
    let new_map  = build_index(&new,  &key)?;

    let base_keys: HashSet<&String> = base_map.keys().collect();
    let new_keys:  HashSet<&String> = new_map.keys().collect();

    // Ajouts : présents dans new, absents dans base
    let added: Vec<Value> = new_keys
        .difference(&base_keys)
        .filter_map(|k| new_map.get(*k).map(|v| (*v).clone()))
        .collect();

    // Suppressions : présents dans base, absents dans new
    let removed: Vec<Value> = base_keys
        .difference(&new_keys)
        .filter_map(|k| base_map.get(*k).map(|v| (*v).clone()))
        .collect();

    // Modifications : présents dans les deux mais différents
    let mut modified: Vec<Value> = Vec::new();

    for k in base_keys.intersection(&new_keys) {
        let before = base_map[*k];
        let after  = new_map[*k];

        if before != after {
            let changes = diff_fields(before, after);

            let mut entry = Object::default();
            entry.insert("key".to_string(),     Value::String(k.as_str().into()));
            entry.insert("before".to_string(), before.clone());
            entry.insert("after".to_string(),  after.clone());
            entry.insert(
                "changes".to_string(),
                Value::Array(
                    changes.into_iter()
                        .map(|s|  Value::String(s.as_str().into()))
                        .collect::<Vec<_>>()
                        .into()
                ),
            );

            modified.push(Value::Object(entry));
        }
    }

    let mut result = Object::default();
    result.insert("added".to_string(),    Value::Array(added.into()));
    result.insert("removed".to_string(),  Value::Array(removed.into()));
    result.insert("modified".to_string(), Value::Array(modified.into()));

    Ok(Value::Object(result))
}

// ============================================================
//  HELPERS INTERNES
// ============================================================

/// Construit un index HashMap<key_string, &Value>
/// Retourne Err si des doublons de clé sont détectés
fn build_index<'a>(
    array: &'a Array,
    key:   &str,
) -> Result<HashMap<String, &'a Value>> {
    let mut map = HashMap::new();

    for item in array.iter() {
        if let Some(val) = obj_get(item, key) {
            let k = extract_key(val);
            if map.insert(k.clone(), item).is_some() {
                return Err(anyhow::Error::new(Error::InvalidFunctionArguments {
                    name: "list::diff".into(),
                    message: format!(
                        "Doublon détecté sur la clé '{}' = '{}'. \
                         Utilisez list::dedupe en amont.",
                        key, k
                    ),
                }));
            }
        }
    }

    Ok(map)
}

/// Retourne la liste des champs qui diffèrent entre deux valeurs
fn diff_fields(before: &Value, after: &Value) -> Vec<String> {
    let mut changed = Vec::new();

    if let (Value::Object(b), Value::Object(a)) = (before, after) {
        let all_keys: HashSet<&String> = b.keys().chain(a.keys()).collect();
        for k in all_keys {
            let bv = b.get(k).unwrap_or(&Value::None);
            let av = a.get(k).unwrap_or(&Value::None);
            if bv != av {
                changed.push(k.clone());
            }
        }
    }

    changed
}

// ============================================================
//  TESTS
// ============================================================
#[cfg(test)]
mod tests {
    use super::*;
    use crate::db::val::{Array, Value};

    fn strand(s: &str) -> Value {
        Value::String(s.into())
    }

    fn obj(pairs: &[(&str, Value)]) -> Value {
        let mut o = Object::default();
        for (k, v) in pairs {
            o.insert(k.to_string(), v.clone());
        }
        Value::Object(o)
    }

    fn arr(items: Vec<Value>) -> Array {
        Array(items)
    }

    // --- list::dedupe ---

    #[test]
    fn test_dedupe_removes_duplicate() {
        let data = arr(vec![
            obj(&[("id", Value::from(1i64)), ("email", strand("a@test.com"))]),
            obj(&[("id", Value::from(2i64)), ("email", strand("b@test.com"))]),
            obj(&[("id", Value::from(3i64)), ("email", strand("a@test.com"))]), // doublon
        ]);
        let result = dedupe((data, "email".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 2);
        } else { panic!("expected array"); }
    }

    #[test]
    fn test_dedupe_keeps_item_without_field() {
        let data = arr(vec![
            obj(&[("id", Value::from(1i64)), ("email", strand("a@test.com"))]),
            obj(&[("id", Value::from(2i64))]), // pas de champ email
        ]);
        let result = dedupe((data, "email".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 2);
        } else { panic!("expected array"); }
    }

    // --- list::aggregate ---

    #[test]
    fn test_aggregate_sum() {
        let data = arr(vec![
            obj(&[("val", Value::from(10.0f64))]),
            obj(&[("val", Value::from(20.0f64))]),
            obj(&[("val", Value::from(30.0f64))]),
        ]);
        let result = aggregate((data, "val".into(), "sum".into())).unwrap();
        assert_eq!(result, Value::from(60.0f64));
    }

    #[test]
    fn test_aggregate_avg() {
        let data = arr(vec![
            obj(&[("val", Value::from(10.0f64))]),
            obj(&[("val", Value::from(20.0f64))]),
            obj(&[("val", Value::from(30.0f64))]),
        ]);
        let result = aggregate((data, "val".into(), "avg".into())).unwrap();
        assert_eq!(result, Value::from(20.0f64));
    }

    #[test]
    fn test_aggregate_sum_empty_is_none() {
        let data = arr(vec![]);
        let result = aggregate((data, "val".into(), "sum".into())).unwrap();
        assert_eq!(result, Value::None);
    }

    #[test]
    fn test_aggregate_collect() {
        let data = arr(vec![
            obj(&[("tag", strand("rust"))]),
            obj(&[("tag", strand("surreal"))]),
        ]);
        let result = aggregate((data, "tag".into(), "collect".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 2);
        } else { panic!("expected array"); }
    }

    #[test]
    fn test_aggregate_unknown_op_returns_error() {
        let data = arr(vec![]);
        let result = aggregate((data, "val".into(), "unknown".into()));
        assert!(result.is_err());
    }

    // --- list::split_out ---

    #[test]
    fn test_split_out_nominal() {
        let data = arr(vec![
            obj(&[
                ("id", Value::from(1i64)),
                ("tags", Value::Array(arr(vec![strand("rust"), strand("surreal")]))),
            ]),
        ]);
        let result = split_out((data, "tags".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 2);
        } else { panic!("expected array"); }
    }

    #[test]
    fn test_split_out_empty_array_left_join() {
        // Tableau vide -> item conservé (LEFT JOIN)
        let data = arr(vec![
            obj(&[
                ("id", Value::from(1i64)),
                ("tags", Value::Array(arr(vec![]))),
            ]),
        ]);
        let result = split_out((data, "tags".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 1);
        } else { panic!("expected array"); }
    }

    #[test]
    fn test_split_out_missing_field_conserved() {
        let data = arr(vec![obj(&[("id", Value::from(1i64))])]);
        let result = split_out((data, "tags".into())).unwrap();
        if let Value::Array(a) = result {
            assert_eq!(a.len(), 1);
        } else { panic!("expected array"); }
    }

    // --- list::diff ---

    #[test]
    fn test_diff_nominal() {
        let base = arr(vec![
            obj(&[("id", strand("1")), ("status", strand("pending")), ("val", Value::from(100i64))]),
            obj(&[("id", strand("2")), ("status", strand("active")),  ("val", Value::from(200i64))]),
        ]);
        let new = arr(vec![
            obj(&[("id", strand("1")), ("status", strand("done")), ("val", Value::from(150i64))]),
            obj(&[("id", strand("3")), ("status", strand("new")),  ("val", Value::from(300i64))]),
            // id:2 supprimé
        ]);

        let result = diff((base, new, "id".into())).unwrap();

        if let Value::Object(o) = result {
            let added    = o.get("added").unwrap();
            let removed  = o.get("removed").unwrap();
            let modified = o.get("modified").unwrap();

            assert_eq!(added.as_array().unwrap().len(),    1);
            assert_eq!(removed.as_array().unwrap().len(),  1);
            assert_eq!(modified.as_array().unwrap().len(), 1);

            let m = &modified.as_array().unwrap()[0];
            if let Value::Object(m_obj) = m {
                // Clé propre : "1" et non "'1'"
                assert_eq!(m_obj.get("key").unwrap(), &strand("1"));

                let changes = m_obj.get("changes").unwrap().as_array().unwrap();
                let change_strs: Vec<String> = changes.iter()
                    .map(|v| v.to_raw_string())
                    .collect();
                assert!(change_strs.contains(&"status".to_string()));
                assert!(change_strs.contains(&"val".to_string()));
            } else {
                panic!("expected object in modified");
            }
        } else {
            panic!("expected object");
        }
    }

    #[test]
    fn test_diff_duplicate_key_returns_error() {
        let base = arr(vec![
            obj(&[("id", strand("1")), ("val", Value::from(1i64))]),
            obj(&[("id", strand("1")), ("val", Value::from(2i64))]), // doublon !
        ]);
        let new = arr(vec![obj(&[("id", strand("2")), ("val", Value::from(3i64))])]);
        assert!(diff((base, new, "id".into())).is_err());
    }
}