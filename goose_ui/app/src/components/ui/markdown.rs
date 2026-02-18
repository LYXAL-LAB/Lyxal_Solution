use leptos::prelude::*;
use pulldown_cmark::{html, Options, Parser, Event, Tag, TagEnd, CodeBlockKind};
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;
use syntect::html::highlighted_html_for_string;

#[component]
pub fn Markdown(#[prop(into)] content: String) -> impl IntoView {
    let html_content = move || {
        let ps = SyntaxSet::load_defaults_newlines();
        let ts = ThemeSet::load_defaults();
        
        let theme = &ts.themes["base16-ocean.dark"];

        let mut options = Options::empty();
        options.insert(Options::ENABLE_TABLES);
        options.insert(Options::ENABLE_STRIKETHROUGH);
        options.insert(Options::ENABLE_TASKLISTS);
        options.insert(Options::ENABLE_FOOTNOTES);

        let parser = Parser::new_ext(&content, options);
        let mut html_output = String::new();
        
        let mut in_code_block = false;
        let mut current_lang = String::new();
        let mut code_accumulator = String::new();

        let mut events = Vec::new();

        for event in parser {
            match event {
                Event::Start(Tag::CodeBlock(kind)) => {
                    in_code_block = true;
                    current_lang = match kind {
                        CodeBlockKind::Fenced(lang) => lang.to_string(),
                        CodeBlockKind::Indented => String::new(),
                    };
                    code_accumulator.clear();
                }
                Event::End(TagEnd::CodeBlock) => {
                    in_code_block = false;
                    let syntax = ps.find_syntax_by_token(&current_lang)
                        .unwrap_or_else(|| ps.find_syntax_plain_text());
                    
                    let highlighted = highlighted_html_for_string(&code_accumulator, &ps, syntax, theme)
                        .unwrap_or_else(|_| format!("<pre><code>{}</code></pre>", code_accumulator));
                    
                    events.push(Event::Html(highlighted.into()));
                }
                Event::Text(t) => {
                    if in_code_block {
                        code_accumulator.push_str(&t);
                    } else {
                        events.push(Event::Text(t));
                    }
                }
                _ => {
                    if !in_code_block {
                        events.push(event);
                    }
                }
            }
        }

        html::push_html(&mut html_output, events.into_iter());
        html_output
    };

    view! {
        <div class="prose prose-sm dark:prose-invert max-w-none text-foreground" 
             inner_html=html_content />
    }
}
