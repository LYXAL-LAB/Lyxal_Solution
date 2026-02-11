/**
 * Encode SVG for use in url()
 *
 * Short alternative to encodeURIComponent() that encodes only stuff used in SVG, generating
 * smaller code.
 */
export function encodeSVGforURL(svg: string): string {
	return (
		svg
			.trim()
			.replace(/\s+/g, ' ')
			.replace(/"/g, "'")
			.replace(/%/g, '%25')
			.replace(/#/g, '%23')
			.replace(/</g, '%3C')
			.replace(/>/g, '%3E')
			.replace(/\(/g, '%28')
			.replace(/\)/g, '%29')
	);
}

/**
 * Generate data: URL from SVG
 */
export function svgToData(svg: string): string {
	return 'data:image/svg+xml,' + encodeSVGforURL(svg);
}

/**
 * Generate url() from SVG
 */
export function svgToURL(svg: string): string {
	return 'url("' + svgToData(svg) + '")';
}
