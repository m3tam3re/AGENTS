# Testing Rules

## Arrange-Act-Assert Pattern

Structure every test in three distinct phases:

```python
# Arrange: Set up the test data and conditions
user = User(name="Alice", role="admin")
session = create_test_session(user.id)

# Act: Execute the behavior under test
result = grant_permission(session, "read_documents")

# Assert: Verify the expected outcome
assert result.granted is True
assert result.permissions == ["read_documents"]
```

Never mix phases. Comment each phase clearly for complex setups. Keep Act phase to one line if possible.

## Behavior vs Implementation Testing

Test behavior, not implementation details:

```python
# GOOD: Tests the observable behavior
def test_user_can_login():
    response = login("alice@example.com", "password123")
    assert response.status_code == 200
    assert "session_token" in response.cookies

# BAD: Tests internal implementation
def test_login_sets_database_flag():
    login("alice@example.com", "password123")
    user = User.get(email="alice@example.com")
    assert user._logged_in_flag is True  # Private field
```

Focus on inputs and outputs. Test public contracts. Refactor internals freely without breaking tests.

## Mocking Philosophy

Mock external dependencies, not internal code:

```python
# GOOD: Mock external services
@patch("requests.post")
def test_sends_notification_to_slack(mock_post):
    send_notification("Build complete!")
    mock_post.assert_called_once_with(
        "https://slack.com/api/chat.postMessage",
        json={"text": "Build complete!"}
    )

# BAD: Mock internal methods
@patch("NotificationService._format_message")
def test_notification_formatting(mock_format):
    # Don't mock private methods
    send_notification("Build complete!")
```

Mock when:
- Dependency is slow (database, network, file system)
- Dependency is unreliable (external APIs)
- Dependency is expensive (third-party services)

Don't mock when:
- Testing the dependency itself
- The dependency is fast and stable
- The mock becomes more complex than real implementation

## Coverage Expectations

Write tests for:
- Critical business logic (aim for 90%+)
- Edge cases and error paths (aim for 80%+)
- Public APIs and contracts (aim for 100%)

Don't obsess over:
- Trivial getters/setters
- Generated code
- One-line wrappers

Coverage is a floor, not a ceiling. A test suite at 100% coverage that doesn't verify behavior is worthless.

## Test-Driven Development

Follow the red-green-refactor cycle:
1. Red: Write failing test for new behavior
2. Green: Write minimum code to pass
3. Refactor: improve code while tests stay green

Write tests first for new features. Write tests after for bug fixes. Never refactor without tests.

## Test Organization

Group tests by feature or behavior, not by file structure. Name tests to describe the scenario:

```python
class TestUserAuthentication:
    def test_valid_credentials_succeeds(self):
        pass

    def test_invalid_credentials_fails(self):
        pass

    def test_locked_account_fails(self):
        pass
```

Each test should stand alone. Avoid shared state between tests. Use fixtures or setup methods to reduce duplication.

## Test Data

Use realistic test data that reflects production scenarios:

```python
# GOOD: Realistic values
user = User(
    email="alice@example.com",
    name="Alice Smith",
    age=28
)

# BAD: Placeholder values
user = User(
    email="test@test.com",
    name="Test User",
    age=999
)
```

Avoid magic strings and numbers. Use named constants for expected values that change often.
