use lyxal_text::{TextRun, TextStyle, FontStyle};

#[test]
fn test_runs_json_serialization() {
    let style = TextStyle::default();
    let run = TextRun::new("Hello", style);
    
    let json = serde_json::to_string(&run).unwrap();
    println!("JSON: {}", json);
    
    assert!(json.contains("Hello"));
    assert!(json.contains("Sans Serif"));
}

#[test]
fn test_runs_deserialization() {
    let json = r##"
    {
        "text": "World",
        "style": {
            "font_family": "Inter",
            "font_size": 32.0,
            "color": "#FF0000"
        }
    }
    "##;
    
    let run: TextRun = serde_json::from_str(json).expect("Deserialization failed");
    assert_eq!(run.text, "World");
    assert_eq!(run.style.font_family, "Inter");
    assert_eq!(run.style.color, "#FF0000");
    assert_eq!(run.style.font_weight, 400); // Default
}
