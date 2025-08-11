// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{html,js,svelte,ts}', // Adjust this to your project structure
  ],
  theme: {
    extend: {
      colors: {
        'background-main': '#121212',
        'background-muted': '#242424',
        'background-secondary': '#F3F4F6',
        'surface': '#FFFFFF',
        'surface-hover': '#F9FAFB',
        'primary': '#FFFFFF',
        'text-primary': '#d0d0d0',
        'text-tertiary': '#6a6a6a',
        'accent': '#4F46E5',
      }
    }
  },
  plugins: [],
}