# Coding Style

## Critical Rules (MUST follow)

Always prioritize readability over cleverness. Never write code that requires mental gymnastics to understand.
Always fail fast and explicitly. Never silently swallow errors or hide exceptions.
Always keep functions under 20 lines. Never create monolithic functions that do multiple things.
Always validate inputs at function boundaries. Never trust external data implicitly.

## Formatting

Prefer consistent indentation throughout the codebase. Never mix tabs and spaces.
Prefer meaningful variable names over short abbreviations. Never use single letters except for loop counters.

### Correct:
```lang
const maxRetryAttempts = 3;
const connectionTimeout = 5000;

for (let attempt = 1; attempt <= maxRetryAttempts; attempt++) {
    // process attempt
}
```

### Incorrect:
```lang
const m = 3;
const t = 5000;

for (let i = 1; i <= m; i++) {
    // process attempt
}
```

## Patterns and Anti-Patterns

Never repeat yourself. Always extract duplicated logic into reusable functions.
Prefer composition over inheritance. Never create deep inheritance hierarchies.
Always use guard clauses to reduce nesting. Never write arrow-shaped code.

### Correct:
```lang
def process_user(user):
    if not user:
        return None
    if not user.is_active:
        return None
    return user.calculate_score()
```

### Incorrect:
```lang
def process_user(user):
    if user:
        if user.is_active:
            return user.calculate_score()
        else:
            return None
    else:
        return None
```

## Error Handling

Always handle specific exceptions. Never use broad catch-all exception handlers.
Always log error context, not just the error message. Never let errors vanish without trace.

### Correct:
```lang
try:
    data = fetch_resource(url)
    return parse_data(data)
except NetworkError as e:
    log_error(f"Network failed for {url}: {e}")
    raise
except ParseError as e:
    log_error(f"Parse failed for {url}: {e}")
    return fallback_data
```

### Incorrect:
```lang
try:
    data = fetch_resource(url)
    return parse_data(data)
except Exception:
    pass
```

## Type Safety

Always use type annotations where supported. Never rely on implicit type coercion.
Prefer explicit type checks over duck typing for public APIs. Never assume type behavior.

### Correct:
```lang
function calculateTotal(price: number, quantity: number): number {
    return price * quantity;
}
```

### Incorrect:
```lang
function calculateTotal(price, quantity) {
    return price * quantity;
}
```

## Function Design

Always write pure functions when possible. Never mutate arguments unless required.
Always limit function parameters to 3 or fewer. Never pass objects to hide parameter complexity.

### Correct:
```lang
def create_user(name: str, email: str) -> User:
    return User(name=name, email=email, created_at=now())
```

### Incorrect:
```lang
def create_user(config: dict) -> User:
    return User(
        name=config['name'],
        email=config['email'],
        created_at=config['timestamp']
    )
```

## SOLID Principles

Never let classes depend on concrete implementations. Always depend on abstractions.
Always ensure classes are open for extension but closed for modification. Never change working code to add features.
Prefer many small interfaces over one large interface. Never force clients to depend on methods they don't use.

### Correct:
```lang
class EmailSender {
    send(message: Message): void {
        // implementation
    }
}

class NotificationService {
    constructor(private sender: EmailSender) {}
}
```

### Incorrect:
```lang
class NotificationService {
    sendEmail(message: Message): void { }
    sendSMS(message: Message): void { }
    sendPush(message: Message): void { }
}
```

## Critical Rules (REPEAT)

Always write self-documenting code. Never rely on comments to explain complex logic.
Always refactor when you see code smells. Never let technical debt accumulate.
Always test edge cases explicitly. Never assume happy path only behavior.
Never commit commented-out code. Always remove it or restore it.
