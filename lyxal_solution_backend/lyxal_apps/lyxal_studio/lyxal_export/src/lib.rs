use lyxal_types::LyxalStudioData;
use lyxal_css::LyxalStyleSheet;

pub struct Exporter;

impl Exporter {
    pub fn export_to_html(data: &LyxalStudioData) -> String {
        let mut stylesheet = LyxalStyleSheet::new();
        let css = stylesheet.generate(data);
        
        // Simplement une structure HTML de base pour l'instant
        format!(
            r#"<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Lyxal Studio Export</title>
    <style id="lyxal-styles">{}</style>
</head>
<body>
    <div id="app"></div>
    <!-- Le moteur de rendu WASM serait injectÃ© ici -->
</body>
</html>"#,
            css
        )
    }
}

