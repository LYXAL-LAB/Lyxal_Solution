#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GENERATION DES ERROR MAPPINGS
Génère les error mappings HTTP standards + spécifiques aux services n8n
"""

import json
from pathlib import Path
from typing import List, Dict

# Chemins
BASE_DIR = Path(__file__).parent
OUTPUT_PATH = BASE_DIR / "error_mappings_flat.json"
SERVICES_PATH = BASE_DIR.parent / "service" / "services_mapping.json"

# Langues
LANGUAGES = {
    'fr': 'Français',
    'en': 'English',
    'it': 'Italiano',
    'de': 'Deutsch',
    'es': 'Español'
}

# Définition des error mappings HTTP génériques
GENERIC_HTTP_ERRORS = [
    {
        'http_code': 400,
        'error_category': 'validation',
        'user_message_en': 'Invalid request. Please check your input.',
        'technical_message_en': 'Bad Request - The request could not be understood or was missing required parameters.',
        'severity': 'error',
        'is_retryable': False,
        'action_type': 'check_input',
        'action_message_en': 'Please verify that all required fields are filled correctly.',
        'icon': 'alert-circle',
        'color': '#f59e0b'
    },
    {
        'http_code': 401,
        'error_category': 'auth',
        'user_message_en': 'Authentication failed. Your credentials are invalid.',
        'technical_message_en': 'Unauthorized - Authentication is required and has failed or has not been provided.',
        'severity': 'error',
        'is_retryable': False,
        'action_type': 'check_credentials',
        'action_message_en': 'Please check your API credentials or refresh your token.',
        'icon': 'lock',
        'color': '#ef4444'
    },
    {
        'http_code': 403,
        'error_category': 'permission',
        'user_message_en': 'Access denied. You don\'t have permission to access this resource.',
        'technical_message_en': 'Forbidden - The server understood the request but refuses to authorize it.',
        'severity': 'error',
        'is_retryable': False,
        'action_type': 'check_permissions',
        'action_message_en': 'Please verify that your account has the necessary permissions.',
        'icon': 'shield-off',
        'color': '#ef4444'
    },
    {
        'http_code': 404,
        'error_category': 'not_found',
        'user_message_en': 'Resource not found.',
        'technical_message_en': 'Not Found - The requested resource could not be found.',
        'severity': 'warning',
        'is_retryable': False,
        'action_type': 'check_input',
        'action_message_en': 'Please verify that the resource ID or name is correct.',
        'icon': 'search-x',
        'color': '#f59e0b'
    },
    {
        'http_code': 409,
        'error_category': 'conflict',
        'user_message_en': 'Conflict detected. The resource already exists or is in use.',
        'technical_message_en': 'Conflict - The request could not be completed due to a conflict with the current state.',
        'severity': 'warning',
        'is_retryable': False,
        'action_type': 'check_input',
        'action_message_en': 'Please use a different name or check existing resources.',
        'icon': 'alert-triangle',
        'color': '#f59e0b'
    },
    {
        'http_code': 429,
        'error_category': 'rate_limit',
        'user_message_en': 'Rate limit exceeded. Too many requests.',
        'technical_message_en': 'Too Many Requests - You have sent too many requests in a given amount of time.',
        'severity': 'warning',
        'is_retryable': True,
        'retry_after_seconds': 60,
        'max_retries': 3,
        'backoff_strategy': 'exponential',
        'action_type': 'retry_later',
        'action_message_en': 'Please wait a moment before trying again.',
        'icon': 'clock',
        'color': '#f59e0b'
    },
    {
        'http_code': 500,
        'error_category': 'server',
        'user_message_en': 'Server error. Something went wrong on our end.',
        'technical_message_en': 'Internal Server Error - The server encountered an unexpected condition.',
        'severity': 'critical',
        'is_retryable': True,
        'max_retries': 2,
        'backoff_strategy': 'exponential',
        'should_notify_admin': True,
        'action_type': 'contact_support',
        'action_message_en': 'If the problem persists, please contact support.',
        'icon': 'server-crash',
        'color': '#ef4444'
    },
    {
        'http_code': 502,
        'error_category': 'server',
        'user_message_en': 'Bad gateway. The server is temporarily unavailable.',
        'technical_message_en': 'Bad Gateway - The server received an invalid response from an upstream server.',
        'severity': 'error',
        'is_retryable': True,
        'max_retries': 3,
        'backoff_strategy': 'exponential',
        'action_type': 'retry_later',
        'action_message_en': 'The service is temporarily unavailable. Please try again in a few moments.',
        'icon': 'server-off',
        'color': '#ef4444'
    },
    {
        'http_code': 503,
        'error_category': 'server',
        'user_message_en': 'Service unavailable. The server is under maintenance.',
        'technical_message_en': 'Service Unavailable - The server is currently unable to handle the request.',
        'severity': 'warning',
        'is_retryable': True,
        'retry_after_seconds': 300,
        'max_retries': 3,
        'backoff_strategy': 'linear',
        'action_type': 'retry_later',
        'action_message_en': 'The service is under maintenance. Please try again later.',
        'icon': 'tool',
        'color': '#f59e0b'
    },
    {
        'http_code': 504,
        'error_category': 'server',
        'user_message_en': 'Gateway timeout. The server took too long to respond.',
        'technical_message_en': 'Gateway Timeout - The server did not receive a timely response from an upstream server.',
        'severity': 'error',
        'is_retryable': True,
        'max_retries': 2,
        'backoff_strategy': 'exponential',
        'action_type': 'retry_later',
        'action_message_en': 'The request timed out. Please try again.',
        'icon': 'clock-x',
        'color': '#ef4444'
    }
]

# Error mappings spécifiques trouvés dans n8n
SERVICE_SPECIFIC_ERRORS = [
    {
        'service_slug': 'awsiam',
        'http_code': 403,
        'error_code': 'INVALID_CREDENTIALS',
        'error_category': 'auth',
        'user_message_en': 'The AWS credentials are not valid!',
        'technical_message_en': 'AWS IAM returned 403 - Invalid credentials or insufficient permissions.',
        'severity': 'error',
        'is_retryable': False,
        'action_type': 'check_credentials',
        'action_message_en': 'Please verify your AWS Access Key ID and Secret Access Key.',
        'icon': 'key-off',
        'color': '#ef4444'
    }
]

def slugify(text: str) -> str:
    """Convertit un texte en slug"""
    import re
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '_', text)
    text = re.sub(r'_+', '_', text)
    return text.strip('_')

def generate_error_mappings() -> List[Dict]:
    """Génère la liste complète des error mappings"""
    mappings = []
    mapping_id = 1
    
    print("\n" + "="*80)
    print("GENERATION DES ERROR MAPPINGS")
    print("="*80 + "\n")
    
    # Mappings génériques
    print(f"Génération des error mappings HTTP génériques...")
    for error in GENERIC_HTTP_ERRORS:
        slug = f"http_{error['http_code']}_generic"
        
        mapping = {
            'id': mapping_id,
            'slug': slug,
            'http_code': error['http_code'],
            'error_code': None,
            'error_category': error['error_category'],
            'service_slug': None,
            'tool_slug': None,
            'user_message_en': error['user_message_en'],
            'technical_message_en': error['technical_message_en'],
            'severity': error['severity'],
            'is_retryable': error.get('is_retryable', False),
            'retry_after_seconds': error.get('retry_after_seconds'),
            'max_retries': error.get('max_retries', 0),
            'backoff_strategy': error.get('backoff_strategy'),
            'should_notify_admin': error.get('should_notify_admin', False),
            'action_type': error.get('action_type'),
            'action_message_en': error.get('action_message_en'),
            'icon': error.get('icon'),
            'color': error.get('color'),
            'i18n_key_user_msg': f"error_{slug}_user_msg",
            'i18n_key_tech_msg': f"error_{slug}_tech_msg",
            'i18n_key_action': f"error_{slug}_action"
        }
        
        mappings.append(mapping)
        mapping_id += 1
    
    print(f"  ✓ {len(GENERIC_HTTP_ERRORS)} error mappings génériques créés")
    
    # Mappings spécifiques aux services
    print(f"\nGénération des error mappings spécifiques aux services...")
    for error in SERVICE_SPECIFIC_ERRORS:
        slug = f"{error['service_slug']}_{error['http_code']}_{error.get('error_code', 'specific')}"
        slug = slugify(slug)
        
        mapping = {
            'id': mapping_id,
            'slug': slug,
            'http_code': error['http_code'],
            'error_code': error.get('error_code'),
            'error_category': error['error_category'],
            'service_slug': error['service_slug'],
            'tool_slug': error.get('tool_slug'),
            'user_message_en': error['user_message_en'],
            'technical_message_en': error['technical_message_en'],
            'severity': error['severity'],
            'is_retryable': error.get('is_retryable', False),
            'retry_after_seconds': error.get('retry_after_seconds'),
            'max_retries': error.get('max_retries', 0),
            'backoff_strategy': error.get('backoff_strategy'),
            'should_notify_admin': error.get('should_notify_admin', False),
            'action_type': error.get('action_type'),
            'action_message_en': error.get('action_message_en'),
            'icon': error.get('icon'),
            'color': error.get('color'),
            'i18n_key_user_msg': f"error_{slug}_user_msg",
            'i18n_key_tech_msg': f"error_{slug}_tech_msg",
            'i18n_key_action': f"error_{slug}_action"
        }
        
        mappings.append(mapping)
        mapping_id += 1
    
    print(f"  ✓ {len(SERVICE_SPECIFIC_ERRORS)} error mappings spécifiques créés")
    
    return mappings

def save_error_mappings(mappings: List[Dict]):
    """Sauvegarde les error mappings en JSON"""
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(mappings, f, indent=2, ensure_ascii=False)
    
    print("\n" + "="*80)
    print(f"GENERATION TERMINEE")
    print(f"Total error mappings : {len(mappings)}")
    print(f"  - Génériques : {len(GENERIC_HTTP_ERRORS)}")
    print(f"  - Spécifiques : {len(SERVICE_SPECIFIC_ERRORS)}")
    print(f"Fichier de sortie : {OUTPUT_PATH}")
    print("="*80 + "\n")

def main():
    """Fonction principale"""
    mappings = generate_error_mappings()
    save_error_mappings(mappings)

if __name__ == "__main__":
    main()

