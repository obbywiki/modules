import re
import sys
import os

if len(sys.argv) < 2:
    sys.exit(1)

target_file = sys.argv[1]

if not os.path.exists(target_file):
    print(f"File not found: {target_file}")
    sys.exit(1)

with open(target_file, 'r', encoding='utf-8') as f:
    content = f.read()

new_content = re.sub(r'\[\[(.*?)\]\]', r'[==[\1]==]', content, flags=re.DOTALL)

if content != new_content:
    with open(target_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
else:
    print(f"[nesting.py Info]: No patch required for: {target_file}")