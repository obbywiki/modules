const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const target_file = process.argv[2];

if (!target_file) process.exit(1);

const compat_dir = path.join(__dirname, 'compat');

if (!fs.existsSync(compat_dir)) {
  console.error(`Error: Compatibility directory not found.`);
  process.exit(1);
}

const scripts = fs
  .readdirSync(compat_dir)
  .filter((file) => { return file.endsWith('.js') || file.endsWith('.py') });

if (scripts.length === 0) {
  console.log('No post-transpilation compatibility scripts enabled. None were run.');
  process.exit(0);
}

console.log(`Running ${scripts.length} compatibility checks on: ${target_file}`);

scripts.forEach((script) => {
  const scriptPath = path.join(compat_dir, script);
  console.log(`\n[Running]: ${script}`);

  const exec = script.endsWith('.js') ? 'node' : 'python3'

  try {
    execSync(`${exec} "${scriptPath}" "${target_file}"`, { stdio: 'inherit' });
  } catch (err) {
    console.error(`\n[Failed]: ${script} encountered an error.`);
    process.exit(1);
  }

  console.log(`\n[Success]: ${script} ran with no errors.`)
});

console.log('All post-transpilation compatibility checks passed successfully.');