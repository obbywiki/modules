# its a miracle this works honestly; darklua string minification can sometimes default to [[]] for long strings, which lua scribunto easily confuses especially when it comes to nesting.
# TODO convert to js, i dont like PYTHON

import sys
import re
import os

def fix_lua_content(content):
    existing_levels = re.findall(r'\[(=*)\[', content)
    max_level = max([len(l) for l in existing_levels]) if existing_levels else 0

    safe_level = "=" * (max_level + 1)
    
    fixed_content = ""
    i = 0
    while i < len(content):
        if content[i] == '[':
            start_match = re.match(r'\[(=*)\[', content[i:])
            if start_match:
                eq_count = len(start_match.group(1))
                eq_str = "=" * eq_count
                start_tag = f"[{eq_str}["
                end_tag = f"]{eq_str}]"

                start_search = i + len(start_tag)
                end_idx = content.find(end_tag, start_search)
                
                if end_idx != -1:
                    block_content = content[start_search:end_idx]
                    full_block = content[i : end_idx + len(end_tag)]

                    if eq_count == 0 and '[[' in block_content:
                        fixed_content += f"[{safe_level}[{block_content}]{safe_level}]"
                        print(f"[nesting.py Info]: Fixed nested [[ using Level {max_level + 1} brackets.")
                    else:
                        fixed_content += full_block
                    
                    i = end_idx + len(end_tag)
                    continue
        
        fixed_content += content[i]
        i += 1
        
    return fixed_content

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    target_file = sys.argv[1]

    if not os.path.exists(target_file):
        sys.exit(1)

    with open(target_file, 'r', encoding='utf-8') as f:
        original_content = f.read()

    new_content = fix_lua_content(original_content)

    if original_content != new_content:
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"[nesting.py Info]: Successfully patched: {target_file}")
    else:
        print(f"[nesting.py Info]: No patch required for: {target_file}")

if __name__ == "__main__":
    main()