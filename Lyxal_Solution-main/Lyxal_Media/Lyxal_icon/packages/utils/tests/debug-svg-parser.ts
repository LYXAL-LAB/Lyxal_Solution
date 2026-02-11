import { parseSVGContent } from '../src/svg/parse';

console.log('--- Simple SVG ---');
const body =
    '<path d="M12,21L15.6,16.2C14.6,15.45 13.35,15 12,15C10.65,15 9.4,15.45 8.4,16.2L12,21" opacity="0"><animate id="spinner_jbAr" begin="0;spinner_8ff3.end+0.2s" attributeName="opacity" calcMode="discrete" dur="0.25s" values="0;1" fill="freeze"/><animate id="spinner_8ff3" begin="spinner_aTlH.end+0.5s" attributeName="opacity" dur="0.001s" values="1;0" fill="freeze"/></path><path d="M12,9C9.3,9 6.81,9.89 4.8,11.4L6.6,13.8C8.1,12.67 9.97,12 12,12C14.03,12 15.9,12.67 17.4,13.8L19.2,11.4C17.19,9.89 14.7,9 12,9Z" opacity="0"><animate id="spinner_dof4" begin="spinner_jbAr.end" attributeName="opacity" calcMode="discrete" dur="0.25s" values="0;1" fill="freeze"/><animate begin="spinner_aTlH.end+0.5s" attributeName="opacity" dur="0.001s" values="1;0" fill="freeze"/></path><path d="M12,3C7.95,3 4.21,4.34 1.2,6.6L3,9C5.5,7.12 8.62,6 12,6C15.38,6 18.5,7.12 21,9L22.8,6.6C19.79,4.34 16.05,3 12,3" opacity="0"><animate id="spinner_aTlH" begin="spinner_dof4.end" attributeName="opacity" calcMode="discrete" dur="0.25s" values="0;1" fill="freeze"/><animate begin="spinner_aTlH.end+0.5s" attributeName="opacity" dur="0.001s" values="1;0" fill="freeze"/></path>';
const svg = `<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">${body}</svg>`;

const parsed = parseSVGContent(svg);
// console.log('Parsed Simple SVG:', JSON.stringify(parsed, null, 2));

const expectedAttribs: Record<string, string> = {
    width: '24',
    height: '24',
    viewBox: '0 0 24 24',
    xmlns: 'http://www.w3.org/2000/svg',
};

// Check equality manually
let match = true;
for (const key in expectedAttribs) {
    if (parsed?.attribs[key] !== expectedAttribs[key]) {
        console.log(`Mismatch key ${key}: expected '${expectedAttribs[key]}', got '${parsed?.attribs[key]}'`);
        match = false;
    }
}
for (const key in parsed?.attribs) {
    if (!expectedAttribs[key]) {
        console.log(`Extra key ${key}: '${parsed?.attribs[key]}'`);
        match = false;
    }
}
if (match) console.log('Simple SVG Attribs Match!');

console.log('--- Nested SVG ---');
const nestedBody = `<circle cx="50" cy="50" r="40" />
		<circle cx="150" cy="50" r="4" />
	  
		<svg viewBox="0 0 10 10" x="200" width="100">
		  <circle cx="5" cy="5" r="4" />
		</svg>`;

const nestedSvg = `<svg
		viewBox="0 0 300 100"
		xmlns="http://www.w3.org/2000/svg"
		stroke="red"
		fill="grey">
		${nestedBody}
	  </svg>
	  `;

const parsedNested = parseSVGContent(nestedSvg);
console.log('Parsed Nested SVG Body Length:', parsedNested?.body.length);
console.log('Expected Nested SVG Body Length:', nestedBody.length);
console.log('Parsed Nested SVG Body:', JSON.stringify(parsedNested?.body));
console.log('Expected Nested SVG Body:', JSON.stringify(nestedBody));

if (parsedNested?.body !== nestedBody) {
    console.log('Nested SVG Body Mismatch!');
} else {
    console.log('Nested SVG Body Match!');
}

console.log('--- Fill SVG ---');
const fillBody = `<g filter="url(#filter0_iii_18_1526)">
            <path d="M14.0346 3.55204L18.2991 10.8362L12.2834 12.5469C8.12828 11.172 5.68075 8.52904 4.20532 5.8125C3.58307 4.66681 3.58813 2.5625 6.06108 2.5625H12.3087C13.0189 2.5625 13.6758 2.93914 14.0346 3.55204Z" fill="#4686EC"/>
            <path d="M14.0346 3.55204L18.2991 10.8362L12.2834 12.5469C8.12828 11.172 5.68075 8.52904 4.20532 5.8125C3.58307 4.66681 3.58813 2.5625 6.06108 2.5625H12.3087C13.0189 2.5625 13.6758 2.93914 14.0346 3.55204Z" fill="url(#paint0_radial_18_1526)"/>
            <path d="M14.0346 3.55204L18.2991 10.8362L12.2834 12.5469C8.12828 11.172 5.68075 8.52904 4.20532 5.8125C3.58307 4.66681 3.58813 2.5625 6.06108 2.5625H12.3087C13.0189 2.5625 13.6758 2.93914 14.0346 3.55204Z" fill="url(#paint1_linear_18_1526)"/>
            </g>
    `;
const fillSvg = `<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">${fillBody}</svg>`;

const parsedFill = parseSVGContent(fillSvg);
const expectedFillBody = fillBody.trim();

if (parsedFill?.body !== expectedFillBody) {
    console.log('Fill SVG Body Mismatch!');
    console.log('Expected Length:', expectedFillBody.length);
    console.log('Received Length:', parsedFill?.body.length);
    // console.log('Expected:', JSON.stringify(expectedFillBody));
    // console.log('Received:', JSON.stringify(parsedFill?.body));

    // Find first difference
    for (let i = 0; i < Math.max(expectedFillBody.length, parsedFill?.body.length || 0); i++) {
        if (expectedFillBody[i] !== parsedFill?.body[i]) {
            console.log(`Difference at index ${i}: expected code ${expectedFillBody.charCodeAt(i)}, got ${parsedFill?.body.charCodeAt(i)}`);
            console.log(`Context: ...${expectedFillBody.substring(i - 10, i + 10)}... vs ...${parsedFill?.body.substring(i - 10, i + 10)}...`);
            break;
        }
    }
} else {
    console.log('Fill SVG Body Match!');
}
