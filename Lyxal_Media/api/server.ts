import { serve } from 'bun';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Surreal } from 'surrealdb';

// Chemins & Config
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BASE_DIR = path.resolve(__dirname, '..');
const CONFIG_FILE = path.join(BASE_DIR, 'packs.config.json');

const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

let GITHUB_TOKEN = '';

// Initialisation : Récupérer le token GitHub depuis la DB
async function initToken() {
    try {
        const db = new Surreal();
        await db.connect(DB_CONFIG.endpoint, { auth: { username: DB_CONFIG.username, password: DB_CONFIG.password } });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
        
        const results = await db.select<Record<string, any>>('svg_config');
        const config = Array.isArray(results) 
            ? results.find((r: any) => r.id === 'svg_config:main' || r.id?.toString() === 'svg_config:main') || results[0]
            : results;

        if (config && config.github && config.github.token) {
            GITHUB_TOKEN = config.github.token;
            console.log('✅ GitHub Token chargé depuis la DB.');
        } else {
            console.warn('⚠️ Pas de Token GitHub trouvé en DB (table svg_config). Rate limit sera faible.');
        }
        await db.close();
    } catch (e) {
        console.error('❌ Erreur init DB:', e);
    }
}

// Lancer l'init au démarrage (non bloquant)
initToken();

const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
};

// Helper fetch GitHub avec Auth
async function fetchGitHub(url: string) {
    const headers: Record<string, string> = {
        "User-Agent": "Lyxal-Studio",
        "Accept": "application/vnd.github.v3+json"
    };
    if (GITHUB_TOKEN && !GITHUB_TOKEN.includes('YOUR_TOKEN')) {
        headers["Authorization"] = `Bearer ${GITHUB_TOKEN}`;
    }
    return fetch(url, { headers });
}

console.log('🚀 Lyxal SVG API Server running on http://localhost:3000');

serve({
    port: 3000,
    async fetch(req) {
        const url = new URL(req.url);

        if (req.method === 'OPTIONS') {
            return new Response(null, { headers: CORS_HEADERS });
        }

        // 1. GET /api/search
        if (req.method === 'GET' && url.pathname === '/api/search') {
            const query = url.searchParams.get('q');
            if (!query) return new Response('Missing query', { status: 400, headers: CORS_HEADERS });

            try {
                console.log(`🔍 Search: ${query}`);
                
                // Calibration : on force le contexte "icon" si pas présent
                let q = query;
                const terms = query.toLowerCase();
                if (!terms.includes('icon') && !terms.includes('svg') && !terms.includes('font') && !terms.includes('glyph')) {
                    q += ' icon';
                }

                const ghRes = await fetchGitHub(`https://api.github.com/search/repositories?q=${encodeURIComponent(q)}&sort=stars&order=desc`);
                const data = await ghRes.json();
                return new Response(JSON.stringify(data), { 
                    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } 
                });
            } catch (e) {
                return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        // 2. GET /api/preview (Nouveau Endpoint)
        if (req.method === 'GET' && url.pathname === '/api/preview') {
            const repo = url.searchParams.get('repo');
            console.log(`📡 Request Preview for repo: "${repo}"`);
            
            if (!repo) return new Response('Missing repo', { status: 400, headers: CORS_HEADERS });

            try {
                // Etape A : Trouver la branche par défaut
                console.log('   -> Fetching repo info (default branch)...');
                const repoRes = await fetchGitHub(`https://api.github.com/repos/${repo}`);
                
                if (!repoRes.ok) {
                     throw new Error(`Repo not found: ${repoRes.status}`);
                }
                
                const repoInfo = await repoRes.json();
                const defaultBranch = repoInfo.default_branch || 'main';
                console.log(`   -> Default branch: ${defaultBranch}`);

                // Etape B : Récupérer l'arbre récursif
                console.log('   -> Fetching tree from GitHub...');
                const treeRes = await fetchGitHub(`https://api.github.com/repos/${repo}/git/trees/${defaultBranch}?recursive=1`);
                
                if (!treeRes.ok) {
                    console.error(`   ❌ GitHub Error: ${treeRes.status} ${treeRes.statusText}`);
                    return new Response(JSON.stringify({ error: `GitHub API Error: ${treeRes.status}` }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
                }

                const treeData = await treeRes.json();
                console.log(`   ✅ Tree received. ${treeData.tree?.length || 0} items.`);

                if (!treeData.tree) {
                     return new Response(JSON.stringify({ error: 'No tree found', items: [] }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
                }

                // Etape C : Filtrer les SVG (Heuristique améliorée)
                let svgs = treeData.tree.filter((n: any) => 
                    n.path.endsWith('.svg') && 
                    n.size < 20000 && // Max 20KB (évite les bannières)
                    !n.path.includes('node_modules') && 
                    !n.path.includes('.github') &&
                    !n.path.includes('test') &&
                    !n.path.includes('demo') &&
                    n.path.includes('/') // Exclure les fichiers à la racine (logos README)
                );

                // Raffinement : Si on trouve des dossiers explicites "icons" ou "svg", on se concentre dessus
                const iconFolders = svgs.filter((n: any) => 
                    n.path.includes('/icons/') || 
                    n.path.includes('/svg/') ||
                    n.path.includes('/outline/') || // Heroicons/Tabler
                    n.path.includes('/solid/')
                );

                if (iconFolders.length > 5) {
                    svgs = iconFolders; // On garde uniquement les "vrais" dossiers d'icônes
                }
                
                console.log(`   -> Found ${svgs.length} potential icons.`);

                // Echantillon aléatoire (12 items)
                const sample = svgs.sort(() => 0.5 - Math.random()).slice(0, 12);
                console.log(`   -> Downloading ${sample.length} previews...`);

                // Etape D : Télécharger le contenu Raw
                const previews = await Promise.all(sample.map(async (file: any) => {
                    const rawUrl = `https://raw.githubusercontent.com/${repo}/${defaultBranch}/${file.path}`;
                    try {
                        const contentRes = await fetch(rawUrl);
                        if (!contentRes.ok) {
                            console.warn(`      ⚠️ Preview failed (${contentRes.status}) for ${rawUrl}`);
                            return null;
                        }
                        const content = await contentRes.text();
                        // Vérif rapide
                        if (!content.trim().startsWith('<svg') && !content.trim().startsWith('<?xml')) return null;
                        return { name: file.path.split('/').pop(), content };
                    } catch (e) {
                        return null;
                    }
                }));

                const validPreviews = previews.filter(p => p !== null);
                console.log(`   ✅ Sending ${validPreviews.length} previews.`);

                return new Response(JSON.stringify({ items: validPreviews }), { 
                    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } 
                });

            } catch (e) {
                console.error('   ❌ Server Exception:', e);
                return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        // 3. POST /api/config/add
        if (req.method === 'POST' && url.pathname === '/api/config/add') {
            try {
                const body = await req.json();
                const { name, repo, branch, description, license, website } = body;

                if (!name || !repo) return new Response('Missing info', { status: 400, headers: CORS_HEADERS });

                // Lire config existante
                let config = {};
                if (fs.existsSync(CONFIG_FILE)) {
                    config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
                }

                // Ajouter/Update pack
                config[name] = {
                    url: `https://github.com/${repo}/archive/refs/heads/${branch || 'main'}.zip`,
                    filter: "icons/.*\\.svg$", 
                    transformName: "lowercase",
                    license: license || 'Unknown',
                    description: description || '',
                    website: website || `https://github.com/${repo}`,
                    version: "0.0.0" 
                };

                fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
                console.log(`✅ Pack ${name} ajouté à la config.`);

                return new Response(JSON.stringify({ success: true, pack: name }), { 
                    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } 
                });

            } catch (e) {
                return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        // 4. GET /api/tree (Navigation GitHub)
        if (req.method === 'GET' && url.pathname === '/api/tree') {
            const repo = url.searchParams.get('repo');
            const sha = url.searchParams.get('sha') || 'main'; // Par défaut main, mais on supportera les SHA de dossier
            
            if (!repo) return new Response('Missing repo', { status: 400, headers: CORS_HEADERS });

            try {
                // Si c'est 'main' ou une branche, on doit d'abord résoudre le SHA de la racine si on veut être propre,
                // mais l'API trees accepte les noms de branche.
                // SAUF QUE: pour naviguer dans un sous-dossier, on a besoin du SHA du dossier (fourni par l'appel précédent).
                
                // Si c'est la première demande (pas de SHA explicite, juste la branche)
                let targetSha = sha;
                if (sha === 'main' || sha === 'master') {
                    // On récupère la branche par défaut réelle
                    const repoRes = await fetchGitHub(`https://api.github.com/repos/${repo}`);
                    if (repoRes.ok) {
                        const repoInfo = await repoRes.json();
                        targetSha = repoInfo.default_branch;
                    }
                }

                console.log(`📂 Browsing tree: ${repo} @ ${targetSha}`);
                const treeRes = await fetchGitHub(`https://api.github.com/repos/${repo}/git/trees/${targetSha}`);
                
                if (!treeRes.ok) throw new Error(`GitHub Error: ${treeRes.status}`);
                
                const data = await treeRes.json();
                
                // On trie : Dossiers d'abord, puis Fichiers
                const sortedTree = (data.tree || []).sort((a: any, b: any) => {
                    if (a.type === 'tree' && b.type !== 'tree') return -1;
                    if (a.type !== 'tree' && b.type === 'tree') return 1;
                    return a.path.localeCompare(b.path);
                });

                return new Response(JSON.stringify({ 
                    sha: data.sha, 
                    tree: sortedTree,
                    url: data.url 
                }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });

            } catch (e) {
                return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        // 4. GET /api/Lyxal/list (Catalogue Lyxal)
        if (req.method === 'GET' && url.pathname === '/api/Lyxal/list') {
            try {
                console.log('📦 Fetching Lyxal collection list...');
                
                const rootRes = await fetchGitHub('https://api.github.com/repos/Lyxal/icon-sets/git/trees/master');
                const rootData = await rootRes.json();
                const jsonFolder = rootData.tree?.find((n: any) => n.path === 'json');

                if (!jsonFolder) throw new Error('Folder /json not found in Lyxal repo');

                const jsonRes = await fetchGitHub(jsonFolder.url);
                const jsonData = await jsonRes.json();

                // On transforme en liste propre
                const collections = jsonData.tree
                    .filter((n: any) => n.path.endsWith('.json'))
                    .map((n: any) => ({
                        id: n.path.replace('.json', ''),
                        name: n.path.replace('.json', '').replace(/-/g, ' ').replace(/\b\w/g, (l: string) => l.toUpperCase()),
                        file: n.path,
                        url: `https://raw.githubusercontent.com/Lyxal/icon-sets/master/json/${n.path}`,
                        size: n.size
                    }));

                // Vérifier ce qui est installé (via DB)
                const db = new Surreal();
                await db.connect(DB_CONFIG.endpoint, { auth: { username: DB_CONFIG.username, password: DB_CONFIG.password } });
                await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
                
                // On récupère tous les packs installés
                // Note: On utilise une query brute car select('icon_pack') retourne parfois des objets complexes
                const installedPacks = await db.query('SELECT * FROM icon_pack');
                await db.close();

                // Mapping (installedPacks[0] est le tableau de résultats)
                const packsList: any[] = Array.isArray(installedPacks[0]) ? installedPacks[0] : [];
                // On utilise identity.slug pour la comparaison (car slug == prefix JSON)
                const installedIds = new Set(packsList.map((p: any) => p.identity.slug));
                
                const result = collections.map((c: any) => ({
                    ...c,
                    isInstalled: installedIds.has(c.id) // c.id est le nom du fichier sans .json (prefix)
                }));

                return new Response(JSON.stringify({ items: result }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });

            } catch (e) {
                return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        // 5. POST /api/Lyxal/install (Installation)
        if (req.method === 'POST' && url.pathname === '/api/Lyxal/install') {
            const body = await req.json();
            const { url } = body;
            
            if (!url) return new Response('Missing url', { status: 400, headers: CORS_HEADERS });

            console.log(`🚀 Installing from ${url}...`);
            
            const proc = Bun.spawn(['bun', 'scripts/importFromLyxalJSON.ts', url], {
                cwd: BASE_DIR,
                stdout: 'inherit',
            });
            
            await proc.exited; 

            return new Response(JSON.stringify({ success: true }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });
        }

        // 6. DELETE /api/Lyxal/delete (Suppression)
        if (req.method === 'DELETE' && url.pathname === '/api/Lyxal/delete') {
            const body = await req.json();
            const { prefix } = body;
            
            if (!prefix) return new Response('Missing prefix', { status: 400, headers: CORS_HEADERS });

            console.log(`🗑️ Deleting pack ${prefix}...`);
            
            try {
                const db = new Surreal();
                await db.connect(DB_CONFIG.endpoint, { auth: { username: DB_CONFIG.username, password: DB_CONFIG.password } });
                await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });

                // Suppression du pack (via slug) et des icônes associées
                // identity.slug match le prefix du JSON
                // DELETE retourne les records supprimés, on ne s'en sert pas forcément
                await db.query(`
                    DELETE icon_pack WHERE identity.slug = $prefix;
                    DELETE icon WHERE identity.pack = $prefix; 
                `, { prefix });
                
                await db.close();
                console.log(`✅ Pack ${prefix} deleted.`);
                
                return new Response(JSON.stringify({ success: true }), { headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } });

            } catch(e) {
                 console.error('❌ Delete error:', e);
                 return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
            }
        }

        return new Response('Not Found', { status: 404, headers: CORS_HEADERS });
    },
});
