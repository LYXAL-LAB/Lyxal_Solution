import { defineConfig } from 'tsup';

export default defineConfig({
	entry: ['src/Lyxal.ts'],
	format: ['cjs', 'esm'],
	splitting: false,
	sourcemap: false,
	clean: true,
	dts: true,
	target: 'esnext',
});
