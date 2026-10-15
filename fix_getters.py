import re

file_path = 'lib/features/library/book_database.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Pattern to match a column getter line:
# starts with whitespace, then (IntColumn|TextColumn|DateTimeColumn|IntEnumColumn|BoolColumn|RealColumn) space get space identifier space => space .* ;
# We'll process each line.
fixed = []
for line in lines:
    stripped = line.rstrip()
    # Check if line contains '=>' and ends with ';' (after possible whitespace)
    if '=>' in stripped and stripped.rstrip().endswith(';'):
        # Split into left and right at '=>'
        left, right = stripped.split('=>', 1)
        # right should end with ';' maybe with trailing spaces
        right = right.rstrip()
        if right.endswith(';'):
            expr = right[:-1]  # remove semicolon
            # Now expr should be something like 'text()' or 'text().nullable()' etc.
            # We need to ensure expr ends with '()' (i.e., a call to the builder).
            # If expr already ends with '()', we leave it.
            # Otherwise, we append '()'.
            # But careful: expr might have spaces at ends.
            expr_stripped = expr.strip()
            if not expr_stripped.endswith('()'):
                # Append '()' to expr (we'll add to the end of expr, before we add back semicolon)
                expr = expr + '()'
            # Reconstruct right side
            right = expr + ';'
        # Reconstruct line with original indentation (left includes indentation up to before '=>')
        # Actually left includes everything before '=>', including indentation.
        # We'll keep left as is, then add '=>' then right.
        line = left + '=>' + right
    fixed.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(fixed)

print('Fixed getters')
