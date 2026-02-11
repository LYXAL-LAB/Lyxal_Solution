import { fetch } from 'bun';

async function main() {
    const query = process.argv[2];
    if (!query) {
        console.error('❌ Usage: bun scripts/searchRepo.ts <nom_du_repo>');
        process.exit(1);
    }

    console.log(`🔍 Recherche de "${query}" sur GitHub...`);

    try {
        const response = await fetch(`https://api.github.com/search/repositories?q=${encodeURIComponent(query)}&sort=stars&order=desc`, {
            headers: {
                "User-Agent": "Lyxal-Search",
                "Accept": "application/vnd.github.v3+json"
            }
        });

        if (!response.ok) {
            console.error(`❌ Erreur API: ${response.status}`);
            return;
        }

        const data = await response.json();
        
        if (data.total_count === 0) {
            console.log('⚠️ Aucun repository trouvé.');
            return;
        }

        console.log(`✅ ${data.total_count} résultats trouvés. Top 3 :\n`);

        const top3 = data.items.slice(0, 3);
        
        top3.forEach((repo: any, index: number) => {
            console.log(`${index + 1}. ⭐ [${repo.stargazers_count}] ${repo.full_name}`);
            console.log(`   📝 Desc: ${repo.description}`);
            console.log(`   🔗 URL: ${repo.html_url}`);
            console.log(`   📦 Zip: ${repo.html_url}/archive/refs/heads/${repo.default_branch}.zip`);
            console.log(`   📜 Licence: ${repo.license ? repo.license.name : 'Aucune'}`);
            console.log('---------------------------------------------------');
        });

    } catch (e) {
        console.error('❌ Erreur:', e);
    }
}

main();

