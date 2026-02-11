import { downloadGitRepo } from '@Lyxal/tools';

(async () => {
	console.log(
		await downloadGitRepo({
			target: 'downloads/boxicons-{hash}',
			remote: 'git@github.com:atisawd/boxicons.git',
			branch: 'master',
			ifModifiedSince: true,
			log: true,
		})
	);
})();
