# Naming Conventions

Use consistent naming across all code. Follow language-specific conventions.

## Language Reference

| Type | Python | TypeScript | Nix | Shell |
|------|--------|------------|-----|-------|
| Variables | snake_case | camelCase | camelCase | UPPER_SNAKE |
| Functions | snake_case | camelCase | camelCase | lower_case |
| Classes | PascalCase | PascalCase | - | - |
| Constants | UPPER_SNAKE | UPPER_SNAKE | camelCase | UPPER_SNAKE |
| Files | snake_case | camelCase | hyphen-case | hyphen-case |
| Modules | snake_case | camelCase | - | - |

## General Rules

**Files**: Use hyphen-case for documentation, snake_case for Python, camelCase for TypeScript. Names should describe content.

**Variables**: Use descriptive names. Avoid single letters except loop counters. No Hungarian notation.

**Functions**: Use verb-noun pattern. Name describes what it does, not how it does it.

**Classes**: Use PascalCase with descriptive nouns. Avoid abbreviations.

**Constants**: Use UPPER_SNAKE with descriptive names. Group related constants.

## Examples

Python:
```python
# Variables
user_name = "alice"
is_authenticated = True

# Functions
def get_user_data(user_id):
    pass

# Classes
class UserProfile:
    pass

# Constants
MAX_RETRIES = 3
API_ENDPOINT = "https://api.example.com"
```

TypeScript:
```typescript
// Variables
const userName = "alice";
const isAuthenticated = true;

// Functions
function getUserData(userId: string): User {
    return null;
}

// Classes
class UserProfile {
    private name: string;
}

// Constants
const MAX_RETRIES = 3;
const API_ENDPOINT = "https://api.example.com";
```

Nix:
```nix
# Variables
let
  userName = "alice";
  isAuthenticated = true;
in
# ...
```

Shell:
```bash
# Variables
USER_NAME="alice"
IS_AUTHENTICATED=true

# Functions
get_user_data() {
    echo "Getting data"
}

# Constants
MAX_RETRIES=3
API_ENDPOINT="https://api.example.com"
```

## File Naming

Use these patterns consistently. No exceptions.

- Skills: `hyphen-case`
- Python: `snake_case.py`
- TypeScript: `camelCase.ts` or `hyphen-case.ts`
- Nix: `hyphen-case.nix`
- Shell: `hyphen-case.sh`
- Markdown: `UPPERCASE.md` or `sentence-case.md`
