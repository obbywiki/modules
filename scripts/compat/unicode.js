const fs = require("fs");
const path = require("path");

const file_path = process.argv[2];

if (!file_path) process.exit(1);


if (!fs.existsSync(file_path)) {
  console.error(`[unicode.js Error]: File not found at ${file_path}`);
  
  process.exit(1);
}

const replacement_map = {
  "\\u{2014}": "—",
  "\\u{2705}": "✅",
  "\\u{00B7}": "·",
};

function fix_unicode_syntax(input) {
  let output = input;
  let total_changes = 0;

  for (const [pattern, char] of Object.entries(replacement_map)) {
    const escaped = pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const regex = new RegExp(escaped, "g");

    output = output.replace(regex, () => {
      console.log(`[unicode.js Info]: Replacing "${pattern}" with "${char}"`);

      total_changes++;

      return char;
    });
  }

  return { output, total_changes };
}

try {
  const input = fs.readFileSync(file_path, "utf8");
  const { output, total_changes } = fix_unicode_syntax(input);

  if (total_changes > 0) {
    fs.writeFileSync(file_path, output, "utf8");
    console.log(`[unicode.js Info]: Successfully updated ${file_path}. Total changes: ${total_changes}`);
  } else {
    console.log("[unicode.js Info]: No matching Unicode escape sequences found. No changes made.");
  }
} catch (err) {
  console.error(`[unicode.js Error]: Failed to process file: ${err.message}`);

  process.exit(1);
}