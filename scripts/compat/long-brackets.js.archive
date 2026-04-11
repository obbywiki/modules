const fs = require('fs');
const file_path = process.argv[2];

if (!file_path) process.exit(1);

function match_long_open(s, i) {
  if (s[i] !== '[') {
    return -1;
  }

  let j = i + 1;

  while (j < s.length && s[j] === '=') {
    j++;
  }

  if (s[j] !== '[') {
    return -1;
  }

  return j - i - 1;
}

function is_long_close_at(s, i, eq) {
  if (s[i] !== ']') {
    return false;
  }

  for (let k = 0; k < eq; k++) {
    if (s[i + 1 + k] !== '=') {
      return false;
    }
  }

  return s[i + 1 + eq] === ']';
}

function rewrite_l0_brackets(input) {
  let out = '';
  let i = 0;

  while (i < input.length) {
    const ch = input[i];

    if (ch === '"' || ch === "'") {
      const quote = ch;
      out += ch;
      i++;

      while (i < input.length) {
        const c = input[i];
        out += c;
        i++;

        if (c === '\\') {
          if (i < input.length) {
            out += input[i];
            i++;
          }
          continue;
        }

        if (c === quote) {
          break;
        }
      }

      continue;
    }

    if (ch === '-' && input[i + 1] === '-') {
      const eq = match_long_open(input, i + 2);

      if (eq === 0) {
        const start = i + 2;
        const bodyStart = start + 2;
        let j = bodyStart;

        while (j < input.length && !is_long_close_at(input, j, 0)) {
          j++;
        }

        if (j >= input.length) {
          throw new Error('Unterminated long comment');
        }

        const body = input.slice(bodyStart, j);
        out += `--[=[${body}]=]`;
        i = j + 2;
        continue;
      }

      out += '--';
      i += 2;

      while (i < input.length && input[i] !== '\n') {
        out += input[i];
        i++;
      }

      continue;
    }

    const eq = match_long_open(input, i);

    if (eq === 0) {
      const bodyStart = i + 2;
      let j = bodyStart;

      while (j < input.length && !is_long_close_at(input, j, 0)) {
        j++;
      }

      if (j >= input.length) {
        throw new Error('Unterminated long string');
      }

      const body = input.slice(bodyStart, j);
      out += `[=[${body}]=]`;
      i = j + 2;
      continue;
    }

    out += ch;
    i++;
  }

  return out;
}

const input = fs.readFileSync(file_path, 'utf8');
const output = rewrite_l0_brackets(input);

fs.writeFileSync(file_path, output);
console.log(`Rewrote level-0 long brackets in ${file_path}`);