pub struct StyleElement {
    pub name: String,
}

impl StyleElement {
    pub fn mount(&self) { /* DOM logic for WASM */ }
    pub fn render(&self, _css: &str) { /* DOM logic for WASM */ }
}

pub struct FakeStyleElement;

