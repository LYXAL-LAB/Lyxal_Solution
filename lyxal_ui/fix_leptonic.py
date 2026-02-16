import os
import re

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix Oco in root
    content = content.replace('use leptos::Oco;', 'use leptos::prelude::Oco;')
    content = content.replace('use leptos::*;', 'use leptos::prelude::*;')

    # Fix ElementDescriptor
    if 'ElementDescriptor' in content and 'use crate::utils::ElementDescriptor;' not in content:
        content = re.sub(r'(use educe::Educe;\s*)', r'\1use crate::utils::ElementDescriptor;\n', content)
        if 'use crate::utils::ElementDescriptor;' not in content:
            content = "use crate::utils::ElementDescriptor;\n" + content

    # Fix ev in prelude
    def fix_prelude_braces(match):
        prelude_items = match.group(1).split(',')
        new_prelude_items = []
        html_items = []
        ev_items = []
        local_items = []
        
        for item in prelude_items:
            item = item.strip()
            if not item: continue
            
            if 'html::' in item:
                html_items.append(item.replace('html::', ''))
            elif 'ev::' in item:
                ev_items.append(item.replace('ev::', ''))
            elif item in ['Attribute', 'IntoAttribute']:
                local_items.append(item)
            elif 'crate::utils::props::' in item:
                local_items.append(item.split('::')[-1])
            elif item == 'SignalDispose':
                continue
            elif item == 'ElementDescriptor':
                continue # we handle it separately
            else:
                new_prelude_items.append(item)
        
        results = []
        if html_items:
            results.append(f"use leptos::html::{{{', '.join(html_items)}}};")
        if ev_items:
            results.append(f"use leptos::ev::{{{', '.join(ev_items)}}};")
        if local_items:
            results.append(f"use crate::utils::props::{{{', '.join(local_items)}}};")
        if new_prelude_items:
            results.append(f"use leptos::prelude::{{{', '.join(new_prelude_items)}}};")
        
        return "\n".join(results)

    content = re.sub(r'use leptos::prelude::\{([^\}]*)\};', fix_prelude_braces, content)

    # Clean up any messed up double crates
    content = content.replace('crate::utils::props::crate::utils::props::', 'crate::utils::props::')
    
    # Final fix for AProps etc
    content = content.replace('leptos_router::AProps', 'leptos_router::components::AProps')
    content = content.replace('leptos_router::ToHref', 'leptos_router::components::ToHref')
    content = content.replace('leptos_router::State', 'leptos_router::location::State')

    # Fix on_cleanup in root
    content = content.replace('use leptos::on_cleanup;', 'use leptos::prelude::on_cleanup;')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

src_dir = r'C:\Users\Administrator\Downloads\Lyxal_Solution-main\lyxal_ui\crates\ui-kits\lyx-ui-leptonic\leptonic\src'
for root, dirs, files in os.walk(src_dir):
    for file in files:
        if file.endswith('.rs'):
            fix_file(os.path.join(root, file))
