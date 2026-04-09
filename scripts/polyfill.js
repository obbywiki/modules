const fs = require('fs');
const file_path = process.argv[2];

if (!file_path) process.exit(1);

const POLYFILL_MAP = {
  'table.find': 'table.find=table.find or function(t,v,i) for j=i or 1,#t do if t[j]==v then return j end end end',
  'table.clear': 'table.clear=table.clear or function(t) for k in pairs(t) do t[k]=nil end end',
  'table.create': 'table.create=table.create or function(n,v) local t={} for i=1,n do t[i]=v end return t end'
};

try {
  let content = fs.readFileSync(file_path, 'utf8');
  let injections = [];

  for (const [key, code] of Object.entries(POLYFILL_MAP)) {
    if (content.includes(key)) {
      injections.push(code);
    }
  }

  if (injections.length > 0) {
    const header = injections.join(';') + ';\n';
    fs.writeFileSync(file_path, header + content);
    console.log(`Injected ${injections.length} polyfills into ${file_path}`);
  } else {
    console.log(`No polyfills needed for ${file_path}`);
  }
} catch (err) {
  console.error(err);
  process.exit(1);
}