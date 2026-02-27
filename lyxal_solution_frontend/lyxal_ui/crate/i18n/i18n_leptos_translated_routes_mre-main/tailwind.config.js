/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./app/src/**/*.rs"],
    plugins: [
        require('@tailwindcss/forms'),
    ],
}
