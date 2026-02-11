#!/usr/bin/env python3
"""
Script de génération automatique des batches de services
Génère : seeds + i18n_keys + i18n_translations pour les batches 2-21
"""

import json
import re
from pathlib import Path

# Charger le mapping
with open("services_mapping.json", "r", encoding="utf-8-sig") as f:
    services = json.load(f)

print(f"\n✅ {len(services)} services chargés\n")

# Fonctions utilitaires
def get_slug(text):
    slug = text.lower()
    slug = re.sub(r'[^a-z0-9]+', '_', slug)
    slug = re.sub(r'^_+|_+$', '', slug)
    return slug

def get_provider_id(provider):
    return f"provider:{get_slug(provider)}"

def get_color(provider):
    colors = {
        'aws': '#FF9900',
        'google': '#4285F4',
        'microsoft': '#00A4EF',
        'slack': '#4A154B',
        'github': '#181717',
        'airtable': '#FCBD24',
        'asana': '#F06A6A',
    }
    p = provider.lower()
    for key, color in colors.items():
        if key in p:
            return color
    return '#5C6AC4'

def get_category(service):
    s = service.lower()
    if any(x in s for x in ['aws', 'cloud', 'lambda', 's3']): return 'cloud'
    if any(x in s for x in ['mail', 'email', 'smtp']): return 'communication'
    if any(x in s for x in ['crm', 'sales', 'customer']): return 'crm'
    if any(x in s for x in ['sheet', 'table', 'database', 'sql']): return 'data-storage'
    if any(x in s for x in ['task', 'project', 'asana']): return 'project-management'
    if any(x in s for x in ['ai', 'ml', 'transform', 'comprehend']): return 'ai'
    if any(x in s for x in ['marketing', 'campaign']): return 'marketing'
    if any(x in s for x in ['github', 'gitlab', 'git']): return 'development'
    return 'productivity'

# Générer les batches
total_batches = (len(services) + 19) // 20

for batch in range(2, total_batches + 1):
    start = (batch - 1) * 20
    end = min(start + 20, len(services))
    batch_services = services[start:end]
    
    print(f"📦 Batch {batch} : Services {start+1} à {end} ({len(batch_services)} services)")
    
    # =================================================================
    # FICHIER 1: Seeds
    # =================================================================
    seeds = []
    seeds.append(f"-- Batch {batch}: {len(batch_services)} services Lyxal\n\n")
    
    for idx, svc in enumerate(batch_services, start+1):
        slug = get_slug(svc['Service'])
        provider_id = get_provider_id(svc['Provider'])
        category = get_category(svc['Service'])
        color = get_color(svc['Provider'])
        
        seeds.append(f"""-- Service {idx}: {svc['Service']}
CREATE service:{slug} SET
    identity = {{
        name: "{svc['Service']}",
        slug: "{slug}",
        display_name_i18n: i18n_key:service_{slug}_name,
        description_i18n: i18n_key:service_{slug}_desc,
        aliases: ["{svc['Service']}"]
    }},
    presentation = {{
        icon: NONE,
        color: "{color}",
        display_order: 0,
        category_slug: "{category}",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    }},
    config = {{
        version: {{
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        }},
        capabilities: {{
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        }},
        api: {{
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        }},
        rate_limits: NONE
    }},
    documentation = NONE,
    metadata = {{
        tags: ["{category}"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    }},
    provider_id: {provider_id},
    category_id: NONE,
    is_active: true;

""")
    
    with open(f"service_batch{batch}_seeds.surql", "w", encoding="utf-8") as f:
        f.write("".join(seeds))
    print(f"   ✓ Seeds créé")
    
    # =================================================================
    # FICHIER 2: i18n_keys
    # =================================================================
    keys = []
    keys.append(f"-- Batch {batch}: {len(batch_services) * 2} clés i18n Lyxal\n\n")
    
    for svc in batch_services:
        slug = get_slug(svc['Service'])
        keys.append(f"""-- {svc['Service']}
CREATE i18n_key:service_{slug}_name SET description = "Nom du service {svc['Service']}";
CREATE i18n_key:service_{slug}_desc SET description = "Description du service {svc['Service']}";

""")
    
    with open(f"service_batch{batch}_i18n_keys.surql", "w", encoding="utf-8") as f:
        f.write("".join(keys))
    print(f"   ✓ i18n_keys créé")
    
    # =================================================================
    # FICHIER 3: i18n_translations
    # =================================================================
    trans = []
    trans.append(f"-- Batch {batch}: {len(batch_services) * 2 * 5} traductions Lyxal (5 langues)\n\n")
    
    for svc in batch_services:
        slug = get_slug(svc['Service'])
        display_name = re.sub(r'([a-z])([A-Z])', r'\1 \2', svc['Service'])
        
        trans.append(f"""-- {display_name}
RELATE i18n_key:service_{slug}_name->translation->language:fr SET text = "{display_name}";
RELATE i18n_key:service_{slug}_name->translation->language:en SET text = "{display_name}";
RELATE i18n_key:service_{slug}_name->translation->language:it SET text = "{display_name}";
RELATE i18n_key:service_{slug}_name->translation->language:de SET text = "{display_name}";
RELATE i18n_key:service_{slug}_name->translation->language:es SET text = "{display_name}";
RELATE i18n_key:service_{slug}_desc->translation->language:fr SET text = "Service {display_name} pour automatisation";
RELATE i18n_key:service_{slug}_desc->translation->language:en SET text = "{display_name} service for automation";
RELATE i18n_key:service_{slug}_desc->translation->language:it SET text = "Servizio {display_name} per automazione";
RELATE i18n_key:service_{slug}_desc->translation->language:de SET text = "{display_name}-Dienst für Automatisierung";
RELATE i18n_key:service_{slug}_desc->translation->language:es SET text = "Servicio {display_name} para automatización";

""")
    
    with open(f"service_batch{batch}_i18n_translations.surql", "w", encoding="utf-8") as f:
        f.write("".join(trans))
    print(f"   ✓ i18n_translations créé\n")

print(f"\n✅ TERMINÉ ! {(total_batches - 1) * 3} fichiers générés\n")

