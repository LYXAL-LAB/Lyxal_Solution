pub struct FeatureFlags {
    pub internal_components: bool,
    pub unsupported_browsers: bool,
    pub resource_prop: bool,
    pub tailwind: bool,
}

impl Default for FeatureFlags {
    fn default() -> Self {
        Self {
            internal_components: false,
            unsupported_browsers: false,
            resource_prop: false,
            tailwind: false,
        }
    }
}

impl FeatureFlags {
    pub fn is_enabled(&self, name: &str) -> bool {
        match name {
            "internalComponents" => self.internal_components,
            "unsupportedBrowsers" => self.unsupported_browsers,
            "resourceProp" => self.resource_prop,
            "tailwind" => self.tailwind,
            _ => false,
        }
    }
}

