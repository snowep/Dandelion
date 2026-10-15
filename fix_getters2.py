import re

file_path = 'lib/features/library/book_database.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

fixed = []
for line in lines:
    # Remove trailing newline for processing, we'll add back later.
    if line.endswith('\n'):
        line = line[:-1]
        has_newline = True
    else:
        has_newline = False
    
    # Check if line contains '=>' and ends with ';' (after stripping whitespace)
    stripped = line.strip()
    if '=>' in stripped and stripped.endswith(';'):
        # Split at '=>'
        left, right = stripped.split('=>', 1)
        # right should end with ';'
        right = right.rstrip()
        if right.endswith(';'):
            expr = right[:-1]  # remove semicolon
            expr_stripped = expr.strip()
            # If expr_stripped does not end with '()', add '()'
            if not expr_stripped.endswith('()'):
                expr = expr + '()'
            # Reconstruct right side
            right = expr + ';'
        # Reconstruct stripped line
        stripped = left + '=>' + right
        # If original line had leading whitespace, preserve it.
        # We can keep the original leading whitespace from line (before stripping).
        # Find leading whitespace length.
        match = re.match(r'^(\s*)', line)
        leading = match.group(1) if match else ''
        line = leading + stripped
    if has_newline:
        line = line + '\n'
    fixed.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(fixed)

print('Fixed getters')
