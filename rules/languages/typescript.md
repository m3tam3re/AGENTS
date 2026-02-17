# TypeScript Patterns

## Strict tsconfig

Always enable strict mode and key safety options:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

## Discriminated Unions

Use discriminated unions for exhaustive type safety:

```ts
type Result =
  | { success: true; data: string }
  | { success: false; error: Error };

function handleResult(result: Result): string {
  if (result.success) {
    return result.data;
  }
  throw result.error;
}
```

## Branded Types

Prevent type confusion with nominal branding:

```ts
type UserId = string & { readonly __brand: unique symbol };
type Email = string & { readonly __brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}

function sendEmail(email: Email, userId: UserId) {}
```

## satisfies Operator

Use `satisfies` for type-safe object literal inference:

```ts
const config = {
  port: 3000,
  host: "localhost",
} satisfies {
  port: number;
  host: string;
  debug?: boolean;
};

config.port; // number
config.host; // string
```

## as const Assertions

Freeze literal types with `as const`:

```ts
const routes = {
  home: "/",
  about: "/about",
  contact: "/contact",
} as const;

type Route = typeof routes[keyof typeof routes];
```

## Modern Features

```ts
// Promise.withResolvers()
const { promise, resolve, reject } = Promise.withResolvers<string>();

// Object.groupBy()
const users = [
  { name: "Alice", role: "admin" },
  { name: "Bob", role: "user" },
];
const grouped = Object.groupBy(users, u => u.role);

// using statement for disposables
class Resource implements Disposable {
  async [Symbol.asyncDispose]() {
    await this.cleanup();
  }
}
async function withResource() {
  using r = new Resource();
}
```

## Toolchain

Prefer modern tooling:
- Runtime: `bun` or `tsx` (no `tsc` for execution)
- Linting: `biome` (preferred) or `eslint`
- Formatting: `biome` (built-in) or `prettier`

## Anti-Patterns

Avoid these TypeScript patterns:

```ts
// NEVER use as any
const data = response as any;

// NEVER use @ts-ignore
// @ts-ignore
const value = unknownFunction();

// NEVER use ! assertion (non-null)
const element = document.querySelector("#foo")!;

// NEVER use enum (prefer union)
enum Status { Active, Inactive } // ❌

// Prefer const object or union
type Status = "Active" | "Inactive"; // ✅
const Status = { Active: "Active", Inactive: "Inactive" } as const; // ✅
```

## Indexed Access Safety

With `noUncheckedIndexedAccess`, handle undefined:

```ts
const arr: string[] = ["a", "b"];
const item = arr[0]; // string | undefined

const item2 = arr.at(0); // string | undefined

const map = new Map<string, number>();
const value = map.get("key"); // number | undefined
```
