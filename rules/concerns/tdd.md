# Test-Driven Development (Strict Enforcement)

## Critical Rules (MUST follow)

**NEVER write production code without a failing test first.**
**ALWAYS follow the red-green-refactor cycle. No exceptions.**
**NEVER skip the refactor step. Code quality is mandatory.**
**ALWAYS commit after green, never commit red tests.**

---

## The Red-Green-Refactor Cycle

### Phase 1: Red (Write Failing Test)

The test MUST fail for the right reason—not a syntax error or missing import.

```python
# CORRECT: Test fails because behavior doesn't exist yet
def test_calculate_discount_for_premium_members():
    user = User(tier="premium")
    cart = Cart(items=[Item(price=100)])
    
    discount = calculate_discount(user, cart)
    
    assert discount == 10  # Fails: calculate_discount not implemented

# INCORRECT: Test fails for wrong reason (will pass accidentally)
def test_calculate_discount():
    discount = calculate_discount()  # Fails: missing required args
    assert discount is not None
```

**Red Phase Checklist:**
- [ ] Test describes ONE behavior
- [ ] Test name clearly states expected outcome
- [ ] Test fails for the intended reason
- [ ] Error message is meaningful

### Phase 2: Green (Write Minimum Code)

Write the MINIMUM code to make the test pass. Do not implement future features.

```python
# CORRECT: Minimum implementation
def calculate_discount(user, cart):
    if user.tier == "premium":
        return 10
    return 0

# INCORRECT: Over-engineering for future needs
def calculate_discount(user, cart):
    discounts = {
        "premium": 10,
        "gold": 15,      # Not tested
        "silver": 5,     # Not tested
        "basic": 0       # Not tested
    }
    return discounts.get(user.tier, 0)
```

**Green Phase Checklist:**
- [ ] Code makes the test pass
- [ ] No extra functionality added
- [ ] Code may be ugly (refactor comes next)
- [ ] All existing tests still pass

### Phase 3: Refactor (Improve Code Quality)

Refactor ONLY when all tests are green. Make small, incremental changes.

```python
# BEFORE (Green but messy)
def calculate_discount(user, cart):
    if user.tier == "premium":
        return 10
    return 0

# AFTER (Refactored)
DISCOUNT_RATES = {"premium": 0.10}

def calculate_discount(user, cart):
    rate = DISCOUNT_RATES.get(user.tier, 0)
    return int(cart.total * rate)
```

**Refactor Phase Checklist:**
- [ ] All tests still pass after each change
- [ ] One refactoring at a time
- [ ] Commit if significant improvement made
- [ ] No behavior changes (tests remain green)

---

## Enforcement Rules

### 1. Test-First Always

```python
# WRONG: Code first, test later
class PaymentProcessor:
    def process(self, amount):
        return self.gateway.charge(amount)

# Then write test... (TOO LATE!)

# CORRECT: Test first
def test_process_payment_charges_gateway():
    mock_gateway = MockGateway()
    processor = PaymentProcessor(gateway=mock_gateway)
    
    processor.process(100)
    
    assert mock_gateway.charged_amount == 100
```

### 2. No Commented-Out Tests

```python
# WRONG: Commented test hides failing behavior
# def test_refund_processing():
#     # TODO: fix this later
#     assert False

# CORRECT: Use skip with reason
@pytest.mark.skip(reason="Refund flow not yet implemented")
def test_refund_processing():
    assert False
```

### 3. Commit Hygiene

```bash
# WRONG: Committing with failing tests
git commit -m "WIP: adding payment"
# Tests fail in CI

# CORRECT: Only commit green
git commit -m "Add payment processing"
# All tests pass locally and in CI
```

---

## AI-Assisted TDD Patterns

### Pattern 1: Explicit Test Request

When working with AI assistants, request tests explicitly:

```
CORRECT PROMPT:
"Write a failing test for calculating user discounts based on tier.
Then implement the minimum code to make it pass."

INCORRECT PROMPT:
"Implement a discount calculator with tier support."
```

### Pattern 2: Verification Request

After AI generates code, verify test coverage:

```
PROMPT:
"The code you wrote for calculate_discount is missing tests.
First, show me a failing test for the edge case where cart is empty.
Then make it pass with minimum code."
```

### Pattern 3: Refactor Request

Request refactoring as a separate step:

```
CORRECT:
"Refactor calculate_discount to use a lookup table.
Run tests after each change."

INCORRECT:
"Refactor and add new features at the same time."
```

### Pattern 4: Red-Green-Refactor in Prompts

Structure AI prompts to follow the cycle:

```
PROMPT TEMPLATE:
"Phase 1 (Red): Write a test that [describes behavior]. 
The test should fail because [reason].
Show me the failing test output.

Phase 2 (Green): Write the minimum code to pass this test.
No extra features.

Phase 3 (Refactor): Review the code. Suggest improvements.
I'll approve before you apply changes."
```

### AI Anti-Patterns to Avoid

```python
# ANTI-PATTERN: AI generates code without tests
# User: "Create a user authentication system"
# AI generates 200 lines of code with no tests

# CORRECT APPROACH:
# User: "Let's build authentication with TDD.
# First, write a failing test for successful login."

# ANTI-PATTERN: AI generates tests after implementation
# User: "Write tests for this code"
# AI writes tests that pass trivially (not TDD)

# CORRECT APPROACH:
# User: "I need a new feature. Write the failing test first."
```

---

## Legacy Code Strategy

### 1. Characterization Tests First

Before modifying legacy code, capture existing behavior:

```python
def test_legacy_calculate_price_characterization():
    """
    This test documents existing behavior, not desired behavior.
    Do not change expected values without understanding impact.
    """
    # Given: Current production inputs
    order = Order(items=[Item(price=100, quantity=2)])
    
    # When: Execute legacy code
    result = legacy_calculate_price(order)
    
    # Then: Capture ACTUAL output (even if wrong)
    assert result == 215  # Includes mystery 7.5% surcharge
```

### 2. Strangler Fig Pattern

```python
# Step 1: Write test for new behavior
def test_calculate_price_with_new_algorithm():
    order = Order(items=[Item(price=100, quantity=2)])
    result = calculate_price_v2(order)
    assert result == 200  # No mystery surcharge

# Step 2: Implement new code with TDD
def calculate_price_v2(order):
    return sum(item.price * item.quantity for item in order.items)

# Step 3: Route new requests to new code
def calculate_price(order):
    if order.use_new_pricing:
        return calculate_price_v2(order)
    return legacy_calculate_price(order)

# Step 4: Gradually migrate, removing legacy path
```

### 3. Safe Refactoring Sequence

```python
# 1. Add characterization tests
# 2. Extract method (tests stay green)
# 3. Add unit tests for extracted method
# 4. Refactor extracted method with TDD
# 5. Inline or delete old method
```

---

## Integration Test TDD

### Outside-In (London School)

```python
# 1. Write acceptance test (fails end-to-end)
def test_user_can_complete_purchase():
    user = create_user()
    add_item_to_cart(user, item)
    
    result = complete_purchase(user)
    
    assert result.status == "success"
    assert user.has_receipt()

# 2. Drop down to unit test for first component
def test_cart_calculates_total():
    cart = Cart()
    cart.add(Item(price=100))
    
    assert cart.total == 100

# 3. Implement with TDD, working inward
```

### Contract Testing

```python
# Provider contract test
def test_payment_api_contract():
    """External services must match this contract."""
    response = client.post("/payments", json={
        "amount": 100,
        "currency": "USD"
    })
    
    assert response.status_code == 201
    assert "transaction_id" in response.json()

# Consumer contract test
def test_payment_gateway_contract():
    """We expect the gateway to return transaction IDs."""
    mock_gateway = MockPaymentGateway()
    mock_gateway.expect_charge(amount=100).and_return(
        transaction_id="tx_123"
    )
    
    result = process_payment(mock_gateway, amount=100)
    
    assert result.transaction_id == "tx_123"
```

---

## Refactoring Rules

### Rule 1: Refactor Only When Green

```python
# WRONG: Refactoring with failing test
def test_new_feature():
    assert False  # Failing

def existing_code():
    # Refactoring here is DANGEROUS
    pass

# CORRECT: All tests pass before refactoring
def existing_code():
    # Safe to refactor now
    pass
```

### Rule 2: One Refactoring at a Time

```python
# WRONG: Multiple refactorings at once
def process_order(order):
    # Changed: variable name
    # Changed: extracted method
    # Changed: added caching
    # Which broke it? Who knows.
    pass

# CORRECT: One change, test, commit
# Commit 1: Rename variable
# Commit 2: Extract method  
# Commit 3: Add caching
```

### Rule 3: Baby Steps

```python
# WRONG: Large refactoring
# Before: 500-line monolith
# After: 10 new classes
# Risk: Too high

# CORRECT: Extract one method at a time
# Step 1: Extract calculate_total (commit)
# Step 2: Extract validate_items (commit)
# Step 3: Extract apply_discounts (commit)
```

---

## Test Quality Gates

### Pre-Commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run fast unit tests
uv run pytest tests/unit -x -q || exit 1

# Check test coverage threshold
uv run pytest --cov=src --cov-fail-under=80 || exit 1
```

### CI/CD Requirements

```yaml
# .github/workflows/test.yml
- name: Run Tests
  run: |
    pytest --cov=src --cov-report=xml --cov-fail-under=80
    
- name: Check Test Quality
  run: |
    # Fail if new code lacks tests
    diff-cover coverage.xml --fail-under=80
```

### Code Review Checklist

```markdown
## TDD Verification
- [ ] New code has corresponding tests
- [ ] Tests were written FIRST (check commit order)
- [ ] Each test tests ONE behavior
- [ ] Test names describe the scenario
- [ ] No commented-out or skipped tests without reason
- [ ] Coverage maintained or improved
```

---

## When TDD Is Not Appropriate

TDD may be skipped ONLY for:

### 1. Exploratory Prototypes

```python
# prototype.py - Delete after learning
# No tests needed for throwaway exploration
def quick_test_api():
    response = requests.get("https://api.example.com")
    print(response.json())
```

### 2. One-Time Scripts

```python
# migrate_data.py - Run once, discard
# Tests would cost more than value provided
```

### 3. Trivial Changes

```python
# Typo fix or comment change
# No behavior change = no new test needed
```

**If unsure, write the test.**

---

## Quick Reference

| Phase   | Rule                                    | Check                              |
|---------|-----------------------------------------|-------------------------------------|
| Red     | Write failing test first                | Test fails for right reason        |
| Green   | Write minimum code to pass              | No extra features                  |
| Refactor| Improve code while tests green          | Run tests after each change        |
| Commit  | Only commit green tests                 | All tests pass in CI               |

## TDD Mantra

```
Red. Green. Refactor. Commit. Repeat.

No test = No code.
No green = No commit.
No refactor = Technical debt.
```
