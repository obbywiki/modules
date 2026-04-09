const fs = require('fs');
const file_path = process.argv[2];

if (!file_path) {
  console.error('Usage: node polyfill.js <file-path>');
  process.exit(1);
}

const POLYFILLs = [
  'table.find = table.find or function(t, v, i) for j = i or 1, #t do if t[j] == v then return j end end end',
  'table.clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end',
  'table.create = table.create or function(n, v) local t = {} for i = 1, n do t[i] = v end return t end',
].join('; ') + ';\n';

try {
  const content = fs.readFileSync(file_path, 'utf8');
  
  fs.writeFileSync(file_path, POLYFILLs + content);
  console.log(`Polyfilled ${file_path}`);
} catch (err) {
  console.error(`Error processing ${file_path}: ${err.message}`);
  process.exit(1);
}