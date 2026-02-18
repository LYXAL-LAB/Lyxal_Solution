pub struct ToastHandler;

impl ToastHandler {
    pub fn info(&self, message: &str) {
        leptos::logging::log!("Toast Info: {}", message);
    }

    pub fn success(&self, message: &str) {
        leptos::logging::log!("Toast Success: {}", message);
    }

    pub fn error(&self, message: &str) {
        leptos::logging::log!("Toast Error: {}", message);
    }

    pub fn warning(&self, message: &str) {
        leptos::logging::log!("Toast Warning: {}", message);
    }
}

pub fn show_toast() -> ToastHandler {
    ToastHandler
}
