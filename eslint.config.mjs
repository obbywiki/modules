import js from '@eslint/js'
import globals from 'globals'

export default [
	js.configs.recommended,
	{
		files: ['mediawiki/**/*.js'],
		languageOptions: {
			ecmaVersion: 2022,
			sourceType: 'script',
			globals: {
				...globals.browser,
				...globals.jquery,
				mw: 'readonly',
				mediaWiki: 'readonly',
			},
		},
		rules: {
			'no-var': 'off',
			'prefer-const': 'off',
			'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
		},
	},
]
