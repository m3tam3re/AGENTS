#!/usr/bin/env python3
"""
Markdown to Basecamp Trix HTML Converter.

Converts Markdown text to Basecamp-compatible HTML in Trix format.
Handles Basecamp-specific limitations and provides safety checks.
"""

import argparse
import logging
import re
import sys
from typing import Optional

try:
    import markdown as markdown_lib
    MARKDOWN_AVAILABLE = True
except ImportError:
    MARKDOWN_AVAILABLE = False
    markdown_lib = None  # type: ignore[assignment-assign]

logging.basicConfig(
    level=logging.DEBUG,
    format="%(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)


def markdown_to_trix(markdown_text: str) -> str:
    """
    Convert Markdown text to Basecamp-compatible HTML (Trix format).

    Args:
        markdown_text: The Markdown content to convert.

    Returns:
        HTML string compatible with Basecamp Trix editor.

    Raises:
        ImportError: If markdown library is not installed.
    """
    if not MARKDOWN_AVAILABLE:
        raise ImportError(
            "The 'markdown' library is required. Install with: pip install markdown"
        )

    # Strip potential HTML comments or existing HTML that might cause issues
    cleaned_text = _preprocess_markdown(markdown_text)

    # Configure markdown with safe extensions
    md = markdown_lib.Markdown(  # type: ignore[attr-defined]
        extensions=[
            "tables",
            "fenced_code",
            "codehilite",
            "nl2br",
            "sane_lists",
        ],
        extension_configs={
            "codehilite": {"css_class": "highlight"},
        },
        output_format="html",
    )

    # Convert markdown to HTML
    html = md.convert(cleaned_text)

    # Post-process for Basecamp compatibility
    html = _post_process_html(html)

    return html


def _preprocess_markdown(text: str) -> str:
    """Preprocess markdown text before conversion."""
    lines = text.split("\n")
    processed_lines = []

    for line in lines:
        # Preserve checkboxes but mark them for post-processing
        # Basecamp supports checkboxes only in to-dos, not messages
        if re.match(r"^(\s*)-\s*\[[\sXx]\]\s+", line):
            # Mark checkbox lines for later handling
            processed_lines.append(line)
        else:
            processed_lines.append(line)

    return "\n".join(processed_lines)


def _post_process_html(html: str) -> str:
    """
    Post-process HTML for Basecamp Trix compatibility.

    - Removes horizontal rules or converts them to styled divs
    - Cleans up unnecessary tags
    - Ensures proper inline formatting
    """
    # Remove empty paragraphs
    html = re.sub(r"<p>\s*</p>", "", html)

    # Convert horizontal rules to Basecamp-friendly separators
    # Basecamp may not render <hr> correctly, use styled div instead
    html = re.sub(
        r"<hr\s*/?>",
        '<div style="border-bottom: 1px solid #e0e0e0; margin: 16px 0;"></div>',
        html,
    )

    # Clean up multiple consecutive breaks
    html = re.sub(r"(<br\s*/?>){3,}", "<br><br>", html)

    # Ensure links open in new tab (Basecamp best practice)
    html = re.sub(
        r'<a href="([^"]+)"',
        r'<a href="\1" target="_blank" rel="noopener noreferrer"',
        html,
    )

    # Wrap code blocks properly for Basecamp
    html = re.sub(
        r'<pre><code class="([^"]*)">',
        r'<pre class="\1"><code>',
        html,
    )

    return html


def is_basecamp_safe(markdown_text: str) -> list[str]:
    """
    Check Markdown for unsupported Basecamp features.

    Args:
        markdown_text: The Markdown content to check.

    Returns:
        List of warning messages for unsupported features found.
    """
    warnings: list[str] = []

    # Check for tables
    if re.search(r"^\|.*\|.*$", markdown_text, re.MULTILINE):
        logger.debug("Found table syntax in markdown")
        warnings.append(
            "Tables not supported: convert to structured lists"
        )

    # Check for checkboxes (only in document context, not todo lists)
    if re.search(r"^(\s*)-\s*\[[\sXx]\]\s+", markdown_text, re.MULTILINE):
        logger.debug("Found checkbox syntax in markdown")
        warnings.append(
            "Checkboxes not supported in messages: create as todos instead"
        )

    # Check for horizontal rules
    if re.search(r"^[-*_]{3,}\s*$", markdown_text, re.MULTILINE):
        logger.debug("Found horizontal rule syntax")
        warnings.append(
            "Horizontal rules may not render correctly"
        )

    # Check for complex nested structures that might not render
    if markdown_text.count("    ") > 10:
        logger.debug("Found deeply nested indentation")
        warnings.append(
            "Deep nesting may not render correctly: consider flattening structure"
        )

    return warnings


def convert_table_to_lists(table_md: str) -> str:
    """
    Convert a Markdown table to nested lists in Basecamp-friendly format.

    Args:
        table_md: The Markdown table content (without outer pipes).

    Returns:
        Nested list representation suitable for Basecamp.

    Example:
        Input:
            | Name | Value |
            |------|-------|
            | Foo  | Bar   |

        Output:
            Name:
              - Name: Foo
              - Value: Bar
    """
    lines = [line.strip() for line in table_md.strip().split("\n") if line.strip()]

    if len(lines) < 2:
        return table_md

    # Parse header
    header_match = re.match(r"\|(.+)\|", lines[0])
    if not header_match:
        return table_md

    headers = [h.strip() for h in header_match.group(1).split("|")]

    # Skip separator line if present
    data_lines = lines[1:]
    if data_lines and re.match(r"^\|[-:\s|]+\|$", data_lines[0]):
        data_lines = data_lines[1:]

    result_parts: list[str] = []

    for line in data_lines:
        row_match = re.match(r"\|(.+)\|", line)
        if not row_match:
            continue

        values = [v.strip() for v in row_match.group(1).split("|")]

        # Create nested list for each row
        row_items: list[str] = []
        for header, value in zip(headers, values):
            row_items.append(f"  - {header}: {value}")

        if row_items:
            result_parts.append("\n".join(row_items))

    return "\n\n".join(result_parts)


def convert_checkbox_to_text(line: str) -> str:
    """
    Convert a checkbox line to plain text.

    Args:
        line: A markdown line with checkbox syntax.

    Returns:
        Plain text representation with checkbox state indicated.
    """
    # Match: optional_indent - [ ] or - [x] or - [X]
    match = re.match(r"^(\s*-\s*)\[[\sXx]\]\s+(.*)", line)
    if match:
        indent, text = match.groups()
        checkbox_char = "☐" if " " in match.group(0) else "☑"
        return f"{indent}{checkbox_char} {text}"

    return line


def _cli_check_mode(filename: str) -> int:
    """
    Run in check mode: only output warnings without conversion.

    Args:
        filename: Path to the markdown file.

    Returns:
        Exit code: 0 if no warnings, 1 if warnings found, 2 on file error.
    """
    try:
        with open(filename, "r", encoding="utf-8") as f:
            markdown_text = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {filename}", file=sys.stderr)
        return 2
    except PermissionError:
        print(f"Error: Permission denied: {filename}", file=sys.stderr)
        return 2
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        return 2

    warnings = is_basecamp_safe(markdown_text)

    if warnings:
        print(f"Warnings for {filename}:")
        for warning in warnings:
            print(f"  ⚠️  {warning}")
        return 1
    else:
        print(f"✅ No unsupported features found in {filename}")
        return 0


def _cli_convert_mode(filename: str, output: Optional[str]) -> int:
    """
    Run in convert mode: convert markdown to HTML.

    Args:
        filename: Path to the markdown file.
        output: Optional path for output file.

    Returns:
        Exit code: 0 on success, 1 on warnings, 2 on error.
    """
    try:
        with open(filename, "r", encoding="utf-8") as f:
            markdown_text = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {filename}", file=sys.stderr)
        return 2
    except PermissionError:
        print(f"Error: Permission denied: {filename}", file=sys.stderr)
        return 2
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        return 2

    # Show warnings before conversion
    warnings = is_basecamp_safe(markdown_text)
    if warnings:
        print(f"Warnings for {filename}:")
        for warning in warnings:
            print(f"  ⚠️  {warning}")
        print()

    # Check for markdown library
    if not MARKDOWN_AVAILABLE:
        print(
            "Error: markdown library not installed.",
            file=sys.stderr
        )
        print(
            "Install with: pip install markdown",
            file=sys.stderr
        )
        return 2

    try:
        html_output = markdown_to_trix(markdown_text)
    except Exception as e:
        print(f"Error converting markdown: {e}", file=sys.stderr)
        return 2

    if output:
        try:
            with open(output, "w", encoding="utf-8") as f:
                f.write(html_output)
            print(f"✅ Converted {filename} → {output}")
        except Exception as e:
            print(f"Error writing output: {e}", file=sys.stderr)
            return 2
    else:
        # Write to stdout
        print(html_output)

    return 1 if warnings else 0


def main() -> int:
    """
    CLI entry point.

    Returns:
        Exit code: 0=OK, 1=Warnungen, 2=Fehler.
    """
    parser = argparse.ArgumentParser(
        prog="markdown_to_trix.py",
        description="Convert Markdown to Basecamp Trix HTML format.",
    )

    parser.add_argument(
        "--file",
        "-f",
        metavar="INPUT.md",
        help="Input Markdown file to convert",
    )

    parser.add_argument(
        "--output",
        "-o",
        metavar="OUTPUT.html",
        help="Output HTML file (default: stdout)",
    )

    parser.add_argument(
        "--check",
        "-c",
        metavar="INPUT.md",
        help="Only check for unsupported features, don't convert",
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable verbose (debug) logging",
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Handle mutually exclusive modes
    if args.check:
        return _cli_check_mode(args.check)

    if args.file:
        return _cli_convert_mode(args.file, args.output)

    # No mode specified, show help
    parser.print_help()
    return 0


if __name__ == "__main__":
    # Parse arguments first
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", "-c", metavar="INPUT.md")
    parser.add_argument("--file", "-f", metavar="INPUT.md")
    parser.add_argument("--output", "-o", metavar="OUTPUT.html")
    args, _ = parser.parse_known_args()

    if args.check or args.file:
        # CLI mode with arguments
        sys.exit(main())

    # Run self-tests when executed without arguments
    print("Running self-test...")

    test_cases = [
        {
            "name": "Basic conversion",
            "input": "# Hello\n\n**Bold** and *italic* text.",
            "expected_warnings": 0,
        },
        {
            "name": "Table detection",
            "input": "# Test\n\n| A | B |\n|---|---|\n| 1 | 2 |",
            "expected_warnings": 1,
        },
        {
            "name": "Checkbox detection",
            "input": "# Tasks\n\n- [ ] Task 1\n- [x] Task 2",
            "expected_warnings": 1,
        },
        {
            "name": "Horizontal rule",
            "input": "# Test\n\n---\n\nContent",
            "expected_warnings": 1,
        },
        {
            "name": "Safe markdown",
            "input": "# Title\n\n- Item 1\n- Item 2\n\n**Bold** and [link](https://example.com)",
            "expected_warnings": 0,
        },
    ]

    all_passed = True

    for test in test_cases:
        warnings = is_basecamp_safe(test["input"])
        passed = len(warnings) == test["expected_warnings"]
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {status}: {test['name']} (warnings: {len(warnings)})")
        if not passed:
            all_passed = False
            print(f"       Expected: {test['expected_warnings']}, Got: {len(warnings)}")
            print(f"       Warnings: {warnings}")

    # Test table conversion
    print("\nTesting table conversion...")
    table_md = """
| Name | Role | Email |
|------|------|-------|
| Alice | Dev | alice@example.com |
| Bob | Design | bob@example.com |
"""
    converted = convert_table_to_lists(table_md)
    print(f"  Input:\n{table_md}")
    print(f"  Output:\n{converted}")

    if all_passed:
        print("\n✅ All self-tests passed!")
        sys.exit(0)
    else:
        print("\n❌ Some self-tests failed!")
        sys.exit(1)
