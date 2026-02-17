# Documentation Rules

## When to Document

**Document public APIs**. Every public function, class, method, and module needs documentation. Users need to know how to use your code.
**Document complex logic**. Algorithms, state machines, and non-obvious implementations need explanations. Future readers will thank you.
**Document business rules**. Encode domain knowledge directly in comments. Don't make anyone reverse-engineer requirements from code.
**Document trade-offs**. When you choose between alternatives, explain why. Help future maintainers understand the decision context.
**Do NOT document obvious code**. Comments like `// get user` add noise. Delete them.

## Docstring Formats

### Python (Google Style)

```python
def calculate_price(quantity: int, unit_price: float, discount: float = 0.0) -> float:
    """Calculate total price after discount.
    Args:
        quantity: Number of items ordered.
        unit_price: Price per item in USD.
        discount: Decimal discount rate (0.0 to 1.0).
    Returns:
        Final price in USD.
    Raises:
        ValueError: If quantity is negative.
    """
```

### JavaScript/TypeScript (JSDoc)

```javascript
/**
 * Validates user input against security rules.
 * @param {string} input - Raw user input from form.
 * @param {Object} rules - Validation constraints.
 * @param {number} rules.maxLength - Maximum allowed length.
 * @returns {boolean} True if input passes all rules.
 * @throws {ValidationError} If input violates security constraints.
 */
function validateInput(input, rules) {
```

### Bash

```bash
#!/usr/bin/env bash
# Deploy application to production environment.
#
# Usage: ./deploy.sh [environment]
#
# Args:
#   environment: Target environment (staging|production). Default: staging.
#
# Exits:
#   0 on success, 1 on deployment failure.
```

## Inline Comments: WHY Not WHAT

**Incorrect:**
```python
# Iterate through all users
for user in users:
    # Check if user is active
    if user.active:
        # Increment counter
        count += 1
```

**Correct:**
```python
# Count only active users to calculate monthly revenue
for user in users:
    if user.active:
        count += 1
```

**Incorrect:**
```javascript
// Set timeout to 5000
setTimeout(() => {
  // Show error message
  alert('Error');
}, 5000);
```

**Correct:**
```javascript
// 5000ms delay prevents duplicate alerts during rapid retries
setTimeout(() => {
  alert('Error');
}, 5000);
```

**Incorrect:**
```bash
# Remove temporary files
rm -rf /tmp/app/*
```

**Correct:**
```bash
# Clear temp directory before batch import to prevent partial state
rm -rf /tmp/app/*
```

**Rule:** Describe the intent and context. Never describe what the code obviously does.

## README Standards

Every project needs a README at the top level.

**Required sections:**
1. **What it does** - One sentence summary
2. **Installation** - Setup commands
3. **Usage** - Basic example
4. **Configuration** - Environment variables and settings
5. **Contributing** - How to contribute

**Example structure:**

```markdown
# Project Name

One-line description of what this project does.

## Installation
```bash
npm install
```

## Usage
```bash
npm start
```

## Configuration

Create `.env` file:
```
API_KEY=your_key_here
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
```

**Keep READMEs focused**. Link to separate docs for complex topics. Don't make the README a tutorial.
