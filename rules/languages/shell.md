# Shell Scripting Rules

## Shebang

Always use `#!/usr/bin/env bash` for portability. Never hardcode `/bin/bash`.

```bash
#!/usr/bin/env bash
```

## Strict Mode

Enable strict mode in every script.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `-e`: Exit on error
- `-u`: Error on unset variables
- `-o pipefail`: Return exit status of last failed pipe command

## Shellcheck

Run shellcheck on all scripts before committing.

```bash
shellcheck script.sh
```

## Quoting

Quote all variable expansions and command substitutions. Use arrays instead of word-splitting strings.

```bash
# Good
"${var}"
files=("file1.txt" "file2.txt")
for f in "${files[@]}"; do
  process "$f"
done

# Bad
$var
files="file1.txt file2.txt"
for f in $files; do
  process $f
done
```

## Functions

Define with parentheses, use `local` for variables.

```bash
my_function() {
  local result
  result=$(some_command)
  echo "$result"
}
```

## Command Substitution

Use `$()` not backticks. Nests cleanly.

```bash
# Good
output=$(ls "$dir")

# Bad
output=`ls $dir`
```

## POSIX Portability

Write POSIX-compliant scripts when targeting `/bin/sh`.

- Use `[[` only for bash scripts
- Use `printf` instead of `echo -e`
- Avoid `[[`, `((`, `&>` in sh scripts

## Error Handling

Use `trap` for cleanup.

```bash
cleanup() {
  rm -f /tmp/lockfile
}
trap cleanup EXIT
```

## Readability

- Use 2-space indentation
- Limit lines to 80 characters
- Add comments for non-obvious logic
- Separate sections with blank lines
