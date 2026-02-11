import { getNPMVersion } from '@Lyxal/tools';

(async () => {
	console.log(
		await getNPMVersion({
			package: '@Lyxal-json/mdi-light',
			// tag: 'latest',
		})
	);
})();
