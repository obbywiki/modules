const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const target_file = process.argv[2];

if (!target_file) process.exit(1);

const compat_dir = path.join(__dirname, 'scripts', 'compat');

if (!fs.existsSync(compat_dir)) {
  console.error(`Error: Compatibility directory not found.`);
  process.exit(1);
}

const scripts = fs
  .readdirSync(compat_dir)
  .filter((file) => file.endsWith('.js'));

if (scripts.length === 0) {
  console.log('No compatibility scripts enabled. None were run.');
  process.exit(0);
}

console.log(`Running ${scripts.length} compatibility checks on: ${target_file}`);

scripts.forEach((script) => {
  const scriptPath = path.join(compat_dir, script);
  console.log(`\n[Running]: ${script}`);

  try {
    execSync(`node "${scriptPath}" "${target_file}"`, { stdio: 'inherit' });
  } catch (err) {
    console.error(`\n[Failed]: ${script} encountered an error.`);
    process.exit(1);
  }
});

console.log('Compatibility checks passed successfully.');