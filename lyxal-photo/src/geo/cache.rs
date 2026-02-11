use lru::LruCache;
use std::num::NonZeroUsize;
use std::sync::Mutex;
use super::PlaceResult;

pub struct GeoCache {
    cache: Mutex<LruCache<String, PlaceResult>>,
}

impl GeoCache {
    pub fn new(capacity: usize) -> Self {
        Self {
            cache: Mutex::new(LruCache::new(NonZeroUsize::new(capacity).unwrap())),
        }
    }

    fn get_key(lat: f64, lon: f64) -> String {
        // Arrondi à la 4ème décimale (~11m de précision à l'équateur)
        format!("{:.4},{:.4}", lat, lon)
    }

    pub fn get(&self, lat: f64, lon: f64) -> Option<PlaceResult> {
        let key = Self::get_key(lat, lon);
        let mut cache = self.cache.lock().unwrap();
        cache.get(&key).cloned()
    }

    pub fn insert(&self, lat: f64, lon: f64, result: PlaceResult) {
        let key = Self::get_key(lat, lon);
        let mut cache = self.cache.lock().unwrap();
        cache.put(key, result);
    }
}
