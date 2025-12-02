DEFINE FUNCTION fn::test::bunny_check() {
    RETURN function() {
        // Test sur un fichier que vous avez uploadé (ajustez le chemin si nécessaire)
        // URL publique de votre Pull Zone
        const url = 'https://lyxalsolution.b-cdn.net/lucide/home.svg'; 
        
        const response = fetch(url, {
            method: 'GET'
        });

        return response.then(resp => {
             // On ne parse pas le XML (trop lourd), on vérifie juste le statut et la taille
             return {
                 status: resp.status, // Devrait être 200
                 ok: resp.ok,
                 url: url,
                 headers: {
                     type: resp.headers.get('content-type'),
                     length: resp.headers.get('content-length')
                 }
             };
        }).catch(err => {
             return { error: String(err) };
        });
    }
};

