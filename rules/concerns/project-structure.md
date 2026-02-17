# Project Structure

## Python

Use src layout for all projects. Place application code in `src/<project>/`, tests in `tests/`.

```
project/
├── src/myproject/
│   ├── __init__.py
│   ├── main.py          # Entry point
│   └── core/
│       └── module.py
├── tests/
│   ├── __init__.py
│   └── test_module.py
├── pyproject.toml       # Config
├── README.md
└── .gitignore
```

**Rules:**
- One module per directory file
- `__init__.py` in every package
- Entry point in `src/myproject/main.py`
- Config in root: `pyproject.toml`, `requirements.txt`

## TypeScript

Use `src/` for source, `dist/` for build output.

```
project/
├── src/
│   ├── index.ts         # Entry point
│   ├── core/
│   │   └── module.ts
│   └── types.ts
├── tests/
│   └── module.test.ts
├── package.json         # Config
├── tsconfig.json
└── README.md
```

**Rules:**
- One module per file
- Index exports from `src/index.ts`
- Entry point in `src/index.ts`
- Config in root: `package.json`, `tsconfig.json`

## Nix

Use `modules/` for NixOS modules, `pkgs/` for packages.

```
nix-config/
├── modules/
│   ├── default.nix      # Module list
│   └── my-service.nix
├── pkgs/
│   └── my-package/
│       └── default.nix
├── flake.nix            # Entry point
├── flake.lock
└── README.md
```

**Rules:**
- One module per file in `modules/`
- One package per directory in `pkgs/`
- Entry point in `flake.nix`
- Config in root: `flake.nix`, shell.nix

## General

- Use hyphen-case for directories
- Use kebab-case for file names
- Config files in project root
- Tests separate from source
- Docs in root: README.md, CHANGELOG.md
- Hidden configs: .env, .gitignore
