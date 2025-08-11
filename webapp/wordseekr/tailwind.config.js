// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{html,js,svelte,ts}', // Adjust this to your project structure
  ],
  theme: {
    extend: {
      colors: {
        'background-main': 'var(--color-background-main)',
        'background-muted': 'var(--color-background-muted)',
        'background-secondary': 'var(--color-background-secondary)',
        'surface': 'var(--color-surface)',
        'primary': 'var(--color-primary)',
        'text-primary': 'var(--color-text-primary)',
        'text-tertiary': 'var(--color-text-tertiary)',
        'accent': 'var(--color-accent)',
      }
    }
  },
  plugins: [],
}