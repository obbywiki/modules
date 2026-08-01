const fs = require('fs')
const path = require('path')

const root = process.cwd()

function collect_keys(value, prefix = '') {
	if (value === null || typeof value !== 'object' || Array.isArray(value)) {
		return prefix ? [prefix] : []
	}
	const keys = []
	for (const [key, child] of Object.entries(value)) {
		const next = prefix ? `${prefix}.${key}` : key
		if (child !== null && typeof child === 'object' && !Array.isArray(child)) {
			keys.push(...collect_keys(child, next))
		} else {
			keys.push(next)
		}
	}
	return keys
}

function find_i18n_dirs(dir) {
	const results = []
	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		if (entry.name === 'node_modules' || entry.name === '.git') continue
		const full = path.join(dir, entry.name)
		if (!entry.isDirectory()) continue
		if (entry.name === 'i18n') {
			results.push(full)
		} else {
			results.push(...find_i18n_dirs(full))
		}
	}
	return results
}

let failed = false
for (const i18n_dir of find_i18n_dirs(root)) {
	const files = fs
		.readdirSync(i18n_dir)
		.filter((name) => name.endsWith('.json'))
		.sort()
	
	if (files.length < 2) { continue }

	const locale_keys = {}
	for (const file of files) {
		const full = path.join(i18n_dir, file)
		const data = JSON.parse(fs.readFileSync(full, 'utf8'))

		locale_keys[file] = new Set(collect_keys(data))
	}

	const all_keys = new Set()
	for (const keys of Object.values(locale_keys)) {
		for (const key of keys) { all_keys.add(key) }
	}

	const rel_dir = path.relative(root, i18n_dir)
	for (const [file, keys] of Object.entries(locale_keys)) {
		const missing = [...all_keys].filter((key) => !keys.has(key)).sort()
		if (missing.length === 0) { continue }

		failed = true
		console.error(`${rel_dir}/${file} missing keys:`)

		for (const key of missing) { console.error(`  - ${key}`) }
	}
}

if (failed) {
	process.exit(1)
}

console.log('i18n key parity OK')
