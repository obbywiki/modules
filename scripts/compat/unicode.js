const fs = require('fs');
const file_path = process.argv[2];

if (!file_path) process.exit(1);

function fix_unicode_syntax(input) {
    let fixed;

    fixed = input.replace(/\\u\{2014\}/g, '—');

    return fixed;
}

const input = fs.readFileSync(file_path, 'utf8');
const output = fix_unicode_syntax(input);

fs.writeFileSync(file_path, output);