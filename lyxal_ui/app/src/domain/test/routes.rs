pub struct TestRoutes;

impl TestRoutes {
    pub fn base_segment() -> &'static str {
        "test"
    }

    pub fn base_url() -> &'static str {
        "/test"
    }

    pub fn label() -> &'static str {
        "Test"
    }
}
