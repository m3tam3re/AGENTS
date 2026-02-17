# Python Language Rules

## Toolchain

### Package Management (uv)
```bash
uv init my-project --package
uv add numpy pandas
uv add --dev pytest ruff pyright hypothesis
uv run python -m pytest
uv lock --upgrade-package numpy
```

### Linting & Formatting (ruff)
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
```

### Type Checking (pyright)
```toml
[tool.pyright]
typeCheckingMode = "strict"
reportMissingTypeStubs = true
reportUnknownMemberType = true
```

### Testing (pytest + hypothesis)
```python
import pytest
from hypothesis import given, strategies as st

@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
    assert a + b == b + a

@pytest.fixture
def user_data():
    return {"name": "Alice", "age": 30}

def test_user_creation(user_data):
    user = User(**user_data)
    assert user.name == "Alice"
```

### Data Validation (Pydantic)
```python
from pydantic import BaseModel, Field, validator

class User(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=0, le=150)
    email: str

    @validator('email')
    def email_must_contain_at(cls, v):
        if '@' not in v:
            raise ValueError('must contain @')
        return v
```

## Idioms

### Comprehensions
```python
# List comprehension
squares = [x**2 for x in range(10) if x % 2 == 0]

# Dict comprehension
word_counts = {word: text.count(word) for word in unique_words}

# Set comprehension
unique_chars = {char for char in text if char.isalpha()}
```

### Context Managers
```python
# Built-in context managers
with open('file.txt', 'r') as f:
    content = f.read()

# Custom context manager
from contextlib import contextmanager

@contextmanager
def timer():
    start = time.time()
    yield
    print(f"Elapsed: {time.time() - start:.2f}s")
```

### Generators
```python
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

def read_lines(file_path):
    with open(file_path) as f:
        for line in f:
            yield line.strip()
```

### F-strings
```python
name = "Alice"
age = 30

# Basic interpolation
msg = f"Name: {name}, Age: {age}"

# Expression evaluation
msg = f"Next year: {age + 1}"

# Format specs
msg = f"Price: ${price:.2f}"
msg = f"Hex: {0xFF:X}"
```

## Anti-Patterns

### Bare Except
```python
# AVOID: Catches all exceptions including SystemExit
try:
    risky_operation()
except:
    pass

# USE: Catch specific exceptions
try:
    risky_operation()
except ValueError as e:
    log_error(e)
except KeyError as e:
    log_error(e)
```

### Mutable Defaults
```python
# AVOID: Default argument created once
def append_item(item, items=[]):
    items.append(item)
    return items

# USE: None as sentinel
def append_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Global State
```python
# AVOID: Global mutable state
counter = 0

def increment():
    global counter
    counter += 1

# USE: Class-based state
class Counter:
    def __init__(self):
        self.count = 0

    def increment(self):
        self.count += 1
```

### Star Imports
```python
# AVOID: Pollutes namespace, unclear origins
from module import *

# USE: Explicit imports
from module import specific_function, MyClass
import module as m
```

## Project Setup

### pyproject.toml Structure
```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0",
    "httpx>=0.25",
]

[project.optional-dependencies]
dev = ["pytest", "ruff", "pyright", "hypothesis"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### src Layout
```
my-project/
├── pyproject.toml
└── src/
    └── my_project/
        ├── __init__.py
        ├── main.py
        └── utils/
            ├── __init__.py
            └── helpers.py
```
