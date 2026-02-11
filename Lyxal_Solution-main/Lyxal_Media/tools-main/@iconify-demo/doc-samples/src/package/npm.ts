import { downloadNPMPackage } from '@Lyxal/tools';

(async () => {
	console.log(
		await downloadNPMPackage({
			target: 'downloads/icon-sets/mdi-light',
			package: '@Lyxal-json/mdi-light',
		})
	);
})();
