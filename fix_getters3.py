import re

file_path = 'lib/features/library/book_database.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

fixed = []
for line in lines:
    # Remove trailing newline for processing
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
            # Now we need to ensure expr ends with '()' (i.e., a call to the column builder)
            # However, expr might already end with '()' (e.g., 'text()()' or 'integer().autoIncrement()()')
            # We'll check if expr ends with '()' after stripping whitespace.
            expr_stripped = expr.strip()
            if not expr_stripped.endswith('()'):
                # Append '()' to expr (we'll add to the end of expr, before we add back semicolon)
                expr = expr + '()'
            # Reconstruct right side
            right = expr + ';'
        # Reconstruct stripped line
        stripped = left + '=>' + right
        # If original line had leading whitespace, preserve it.
        match = re.match(r'^(\s*)', line)
        leading = match.group(1) if match else ''
        line = leading + stripped
    if has_newline:
        line = line + '\n'
    fixed.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(fixed)

print('Fixed getters')
