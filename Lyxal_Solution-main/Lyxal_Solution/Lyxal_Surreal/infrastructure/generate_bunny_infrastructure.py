#!/usr/bin/env python3
"""
Générateur automatique d'infrastructure SurrealDB pour Bunny.net
Parser les fichiers OpenAPI et génère :
- Les tables SurrealDB (database/)
- Les fonctions d'API SurrealDB (resources/)
- La documentation complète
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any, Optional
import re


class BunnyInfrastructureGenerator:
    """Générateur d'infrastructure Bunny.net pour SurrealDB"""
    
    def __init__(self, base_path: Path):
        self.base_path = base_path
        self.doc_path = base_path / "documentation" / "bunny"
        self.db_path = base_path / "database"
        self.resources_path = base_path / "resources" / "bunny" / "bunny_net_api"
        
        # Mapping des types OpenAPI vers SurrealDB
        self.type_mapping = {
            'string': 'string',
            'integer': 'int',
            'number': 'float',
            'boolean': 'bool',
            'array': 'array',
            'object': 'object',
        }
        
        # Mapping des formats
        self.format_mapping = {
            'int32': 'int',
            'int64': 'int',
            'float': 'float',
            'double': 'float',
            'date': 'datetime',
            'date-time': 'datetime',
        }
        
        # APIs déjà implémentées manuellement (à exclure)
        self.excluded_endpoints = [
            '/country',  # Déjà implémenté
        ]
        
        # Schémas déjà implémentés manuellement (à exclure)
        self.excluded_schemas = [
            'CountryModel',  # Déjà implémenté dans bunny_country
        ]
        
        # Suffixes de schémas à exclure (modèles temporaires, pas des entités)
        self.excluded_schema_suffixes = [
            'AddModel',           # Modèles de création (requête POST)
            'UpdateModel',        # Modèles de mise à jour (requête POST/PUT)
            'CreateModel',        # Modèles de création
            'RequestModel',       # Modèles de requête
            'Request',            # Modèles de requête
            'Response',           # Modèles de réponse
            'Result',             # Résultats d'opération
            'ResultModel',        # Résultats d'opération
            'PaginationListModelOf',  # Wrappers de pagination
            'PaginationListOf',   # Wrappers de pagination
            'ImportResultModel',  # Résultats d'import
            'SettingsModel',      # Peut-être à inclure selon le cas
        ]
        
        # Préfixes de schémas à exclure
        self.excluded_schema_prefixes = [
            'Get',     # GetShieldZoneResponse, GetCustomWafRulesResponse
            'Add',     # AddCertificateRequestModel, AddHostnameRequestModel
            'Remove',  # RemoveHostnameRequestModel
            'Update',  # UpdateDnsZoneModel
            'Create',  # CreateCustomWafRuleModel
            'Delete',  # DeleteXXXModel
        ]
    
    def load_openapi_file(self, filename: str) -> Dict[str, Any]:
        """Charge un fichier OpenAPI JSON"""
        file_path = self.doc_path / filename
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def snake_case(self, text: str) -> str:
        """Convertit un texte en snake_case"""
        # Remplace les espaces et tirets par des underscores
        text = text.replace(' ', '_').replace('-', '_')
        # Insère des underscores avant les majuscules
        text = re.sub(r'(?<!^)(?=[A-Z])', '_', text)
        return text.lower()
    
    def get_surreal_type(self, schema: Dict[str, Any], required: bool = False) -> str:
        """Convertit un schéma OpenAPI en type SurrealDB"""
        schema_type = schema.get('type', 'string')
        schema_format = schema.get('format')
        nullable = schema.get('x-nullable', False) or schema.get('nullable', False)
        
        # Gestion des références
        if '$ref' in schema:
            ref = schema['$ref'].split('/')[-1]
            base_type = f'record<{self.snake_case(ref)}>'
        # Gestion des formats spécifiques
        elif schema_format and schema_format in self.format_mapping:
            base_type = self.format_mapping[schema_format]
        # Gestion des types de base
        elif schema_type in self.type_mapping:
            base_type = self.type_mapping[schema_type]
            
            # Cas spécial pour les arrays
            if schema_type == 'array' and 'items' in schema:
                item_type = self.get_surreal_type(schema['items'], False)
                base_type = f'array<{item_type}>'
        else:
            base_type = 'string'
        
        # Gestion de l'option (nullable ou non required)
        if nullable or not required:
            return f'option<{base_type}>'
        
        return base_type
    
    def generate_table_schema(self, schema_name: str, schema: Dict[str, Any]) -> str:
        """Génère le schéma SurrealDB pour une table"""
        table_name = f"bunny_{self.snake_case(schema_name)}"
        properties = schema.get('properties', {})
        required_fields = schema.get('required', [])
        description = schema.get('description', f'Table pour {schema_name}')
        
        lines = []
        lines.append(f"-- Table: {table_name}")
        lines.append(f"-- Source: {schema_name}")
        lines.append(f"-- Description: {description}")
        lines.append("")
        lines.append(f"DEFINE TABLE IF NOT EXISTS {table_name} TYPE NORMAL SCHEMAFULL")
        lines.append(f"  COMMENT '{description}';")
        lines.append("")
        
        # Génération des champs
        for prop_name, prop_schema in properties.items():
            field_name = self.snake_case(prop_name)
            is_required = prop_name in required_fields
            field_type = self.get_surreal_type(prop_schema, is_required)
            field_desc = prop_schema.get('description', '')
            
            lines.append(f"DEFINE FIELD IF NOT EXISTS {field_name} ON {table_name}")
            lines.append(f"  TYPE {field_type}")
            
            # Assertion pour les champs requis
            if is_required and 'option' not in field_type:
                lines.append(f"  ASSERT $value != NONE")
            
            # Valeur par défaut
            if 'default' in prop_schema:
                default_value = prop_schema['default']
                if isinstance(default_value, str):
                    lines.append(f"  DEFAULT '{default_value}'")
                elif isinstance(default_value, bool):
                    lines.append(f"  DEFAULT {str(default_value).lower()}")
                else:
                    lines.append(f"  DEFAULT {default_value}")
            
            if field_desc:
                # Échapper les apostrophes dans la description
                field_desc = field_desc.replace("'", "\\'")
                lines.append(f"  COMMENT '{field_desc}';")
            else:
                lines.append(";")
            lines.append("")
        
        # Métadonnées Lyxal
        lines.append(f"-- Métadonnées de synchronisation")
        lines.append(f"DEFINE FIELD IF NOT EXISTS metadata ON {table_name}")
        lines.append(f"  TYPE object")
        lines.append(f"  COMMENT 'Métadonnées de synchronisation Lyxal';")
        lines.append("")
        lines.append(f"DEFINE FIELD IF NOT EXISTS metadata.synced_at ON {table_name}")
        lines.append(f"  TYPE datetime")
        lines.append(f"  DEFAULT time::now()")
        lines.append(f"  COMMENT 'Date de dernière synchronisation';")
        lines.append("")
        
        return "\n".join(lines)
    
    def generate_api_function(self, 
                            endpoint: str, 
                            method: str, 
                            operation: Dict[str, Any],
                            api_base_url: str) -> tuple[str, str]:
        """Génère une fonction SurrealDB pour un endpoint API"""
        operation_id = operation.get('operationId', '')
        summary = operation.get('summary', '')
        description = operation.get('description', summary)
        parameters = operation.get('parameters', [])
        
        # Nom de la fonction
        func_name = f"fn::bunny_{self.snake_case(operation_id)}"
        
        # Paramètres de la fonction
        func_params = []
        query_params = []
        path_params = []
        
        for param in parameters:
            param_name = param.get('name')
            param_in = param.get('in')
            param_schema = param.get('schema', {})
            param_required = param.get('required', False)
            
            param_type = self.get_surreal_type(param_schema, param_required)
            func_params.append(f"${param_name}: {param_type}")
            
            if param_in == 'query':
                query_params.append(param_name)
            elif param_in == 'path':
                path_params.append(param_name)
        
        # Construction de l'URL
        url_parts = [f"'{api_base_url}{endpoint}'"]
        
        # Génération du code de fonction
        lines = []
        lines.append(f"-- Fonction: {func_name}")
        lines.append(f"-- Endpoint: {method.upper()} {endpoint}")
        lines.append(f"-- Description: {summary}")
        lines.append("")
        lines.append(f"DEFINE FUNCTION IF NOT EXISTS {func_name}(")
        if func_params:
            lines.append(f"  {', '.join(func_params)}")
        lines.append(") {")
        lines.append("")
        lines.append("  RETURN function() {")
        lines.append("")
        lines.append("    // Récupérer la clé API")
        lines.append('    const apiKey = await surrealdb.value("$bunny_api_key");')
        lines.append("")
        lines.append("    if (!apiKey) {")
        lines.append("      return {")
        lines.append("        success: false,")
        lines.append("        error: 'api_key_missing',")
        lines.append("        message: 'Bunny API key is not configured'")
        lines.append("      };")
        lines.append("    }")
        lines.append("")
        
        # Construction de l'URL avec paramètres
        if path_params or query_params:
            lines.append("    // Construire l'URL")
            
            # Récupérer les paramètres
            for param_name in func_params:
                clean_name = param_name.split(':')[0].replace('$', '')
                lines.append(f'    const {clean_name}Param = await surrealdb.value("${clean_name}");')
            
            lines.append(f"    let url = '{api_base_url}{endpoint}';")
            
            # Remplacer les paramètres de path
            for param in path_params:
                url_pattern = f"{{{param}}}"
                lines.append(f"    url = url.replace('{url_pattern}', {param}Param);")
            
            # Ajouter les query params
            if query_params:
                lines.append("")
                lines.append("    const params = [];")
                for param in query_params:
                    lines.append(f"    if ({param}Param !== null && {param}Param !== undefined) {{")
                    lines.append(f"      params.push('{param}=' + encodeURIComponent({param}Param));")
                    lines.append("    }")
                lines.append("")
                lines.append("    if (params.length > 0) {")
                lines.append("      url += '?' + params.join('&');")
                lines.append("    }")
        else:
            lines.append(f"    const url = '{api_base_url}{endpoint}';")
        
        lines.append("")
        lines.append("    try {")
        lines.append("      // Appel API")
        lines.append("      const response = await fetch(url, {")
        lines.append(f"        method: '{method.upper()}',")
        lines.append("        headers: {")
        lines.append("          'Accept': 'application/json',")
        lines.append("          'Accesskey': apiKey")
        lines.append("        }")
        lines.append("      });")
        lines.append("")
        lines.append("      // Logger l'appel API")
        lines.append("      await surrealdb.query(`")
        lines.append("        CREATE infrastructure_log CONTENT {")
        lines.append("          type: 'api_call',")
        lines.append(f"          resource_type: '{operation.get('tags', ['unknown'])[0]}',")
        lines.append("          bunny_api: {")
        lines.append(f"            endpoint: '{endpoint}',")
        lines.append(f"            method: '{method.upper()}',")
        lines.append("            status_code: ${response.status}")
        lines.append("          },")
        lines.append("          status: '${response.ok ? 'success' : 'failed'}',")
        lines.append("          timestamp: time::now()")
        lines.append("        }")
        lines.append("      `);")
        lines.append("")
        lines.append("      // Gestion des erreurs HTTP")
        lines.append("      if (!response.ok) {")
        lines.append("        const errorData = response.status !== 401 ? await response.json() : null;")
        lines.append("        return {")
        lines.append("          success: false,")
        lines.append("          status: response.status,")
        lines.append("          error: errorData?.ErrorKey || 'http_error',")
        lines.append("          message: errorData?.Message || `HTTP error! status: ${response.status}`")
        lines.append("        };")
        lines.append("      }")
        lines.append("")
        lines.append("      const data = await response.json();")
        lines.append("      return {")
        lines.append("        success: true,")
        lines.append("        data: data")
        lines.append("      };")
        lines.append("")
        lines.append("    } catch (e) {")
        lines.append("      return {")
        lines.append("        success: false,")
        lines.append("        error: 'exception',")
        lines.append("        message: e.message")
        lines.append("      };")
        lines.append("    }")
        lines.append("  };")
        lines.append("};")
        
        return func_name, "\n".join(lines)
    
    def process_openapi_file(self, filename: str):
        """Traite un fichier OpenAPI complet"""
        print(f"\n{'='*80}")
        print(f"Traitement de {filename}")
        print(f"{'='*80}\n")
        
        spec = self.load_openapi_file(filename)
        
        api_title = spec['info']['title']
        api_base_url = spec['servers'][0]['url'].rstrip('/')
        
        print(f"API: {api_title}")
        print(f"Base URL: {api_base_url}")
        
        # Créer les dossiers nécessaires
        api_name = self.snake_case(api_title.replace('.net', '').replace('API', ''))
        
        # Traitement des schémas (tables)
        schemas = spec.get('components', {}).get('schemas', {})
        print(f"\n📦 Schémas trouvés: {len(schemas)}")
        
        generated_tables = []
        for schema_name, schema in schemas.items():
            if schema_name in self.excluded_schemas:
                print(f"  ⏭️  {schema_name} (déjà implémenté)")
                continue
            
            # Vérifier les suffixes à exclure
            skip = False
            for suffix in self.excluded_schema_suffixes:
                if schema_name.endswith(suffix):
                    print(f"  ⏭️  {schema_name} (modèle temporaire)")
                    skip = True
                    break
            
            if skip:
                continue
            
            # Vérifier les préfixes à exclure
            for prefix in self.excluded_schema_prefixes:
                if schema_name.startswith(prefix):
                    print(f"  ⏭️  {schema_name} (modèle temporaire)")
                    skip = True
                    break
            
            if skip:
                continue
            
            # Ignorer les enums et types simples
            if schema.get('type') != 'object' or 'properties' not in schema:
                continue
            
            table_name = f"bunny_{self.snake_case(schema_name)}"
            table_file = self.db_path / f"{table_name}.surql"
            
            # Ne pas écraser les tables existantes
            if table_file.exists():
                print(f"  ⏭️  {table_name} (fichier existe)")
                continue
            
            table_content = self.generate_table_schema(schema_name, schema)
            
            # Créer le dossier si nécessaire
            table_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(table_file, 'w', encoding='utf-8') as f:
                f.write(table_content)
            
            generated_tables.append(table_name)
            print(f"  ✅ {table_name}")
        
        # Traitement des endpoints (fonctions)
        paths = spec.get('paths', {})
        print(f"\n🔧 Endpoints trouvés: {len(paths)}")
        
        generated_functions = []
        for endpoint, methods in paths.items():
            if endpoint in self.excluded_endpoints:
                print(f"  ⏭️  {endpoint} (déjà implémenté)")
                continue
            
            for method, operation in methods.items():
                if method not in ['get', 'post', 'put', 'delete', 'patch']:
                    continue
                
                operation_id = operation.get('operationId', '')
                if not operation_id:
                    continue
                
                func_name, func_content = self.generate_api_function(
                    endpoint, method, operation, api_base_url
                )
                
                # Organiser par tag (catégorie)
                tags = operation.get('tags', ['misc'])
                tag = self.snake_case(tags[0]) if tags else 'misc'
                
                func_dir = self.resources_path / tag
                func_dir.mkdir(parents=True, exist_ok=True)
                
                func_file = func_dir / f"fn_bunny_{self.snake_case(operation_id)}.surql"
                
                # Ne pas écraser les fonctions existantes
                if func_file.exists():
                    print(f"  ⏭️  {func_name} (fichier existe)")
                    continue
                
                with open(func_file, 'w', encoding='utf-8') as f:
                    f.write(func_content)
                
                generated_functions.append((tag, func_name))
                print(f"  ✅ {func_name} → {tag}/")
        
        print(f"\n✨ Génération terminée pour {filename}:")
        print(f"   - {len(generated_tables)} tables créées")
        print(f"   - {len(generated_functions)} fonctions créées")
    
    def run(self):
        """Exécute le générateur sur tous les fichiers OpenAPI"""
        print("🚀 Générateur d'infrastructure Bunny.net pour SurrealDB")
        print("=" * 80)
        
        openapi_files = [
            'bunnynet-api-1.json',
            'stream-api.json',
            'edge-scripting-api.json',
            'bunnynet-edge-storage-api.json',
            'bunny-shield-api.json',
        ]
        
        for filename in openapi_files:
            try:
                self.process_openapi_file(filename)
            except Exception as e:
                print(f"❌ Erreur lors du traitement de {filename}: {e}")
                import traceback
                traceback.print_exc()
        
        print("\n" + "=" * 80)
        print("✅ Génération terminée !")
        print("=" * 80)


if __name__ == "__main__":
    # Déterminer le chemin de base
    script_dir = Path(__file__).parent
    
    # Créer et exécuter le générateur
    generator = BunnyInfrastructureGenerator(script_dir)
    generator.run()

