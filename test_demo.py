"""
Test suite for demo.sql - validates that the file contains the 5 most impactful SQLFluff issues.

This test verifies that demo.sql correctly demonstrates:
1. AL03 (aliasing.expression) - Column expression without alias
2. AM06 (ambiguous.column_references) - Inconsistent column references in GROUP BY
3. AM09 (ambiguous.order_by_limit) - LIMIT without ORDER BY
4. CV05 (convention.is_null) - NULL comparison without IS NULL
5. AL01 (aliasing.table) - Implicit table aliasing
"""

import subprocess
import json
import pytest


def get_sqlfluff_violations(filepath):
    """Run sqlfluff on a file and return violations."""
    result = subprocess.run(
        ["sqlfluff", "lint", filepath, "--dialect", "postgres", "--format", "json"],
        capture_output=True,
        text=True
    )

    if result.returncode not in (0, 1):  # sqlfluff returns 1 if violations found
        raise RuntimeError(f"SQLFluff failed: {result.stderr}")

    try:
        data = json.loads(result.stdout)
        violations = []
        for file_data in data:
            violations.extend(file_data.get('violations', []))
        return violations
    except json.JSONDecodeError:
        raise RuntimeError(f"Failed to parse SQLFluff output: {result.stdout}")


def test_demo_file_exists():
    """Verify demo.sql file exists."""
    import os
    assert os.path.exists("demo.sql"), "demo.sql file not found"


def test_demo_file_size():
    """Verify demo.sql file does not exceed 100 lines."""
    with open("demo.sql", "r") as f:
        lines = f.readlines()
    assert len(lines) <= 100, f"demo.sql exceeds 100 lines ({len(lines)} lines)"


def test_al03_aliasing_expression_detected():
    """Test that AL03 (aliasing.expression) issue is detected."""
    violations = get_sqlfluff_violations("demo.sql")
    al03_violations = [v for v in violations if v['code'] == 'AL03']
    assert len(al03_violations) >= 1, "AL03 (aliasing.expression) not detected in demo.sql"
    assert al03_violations[0]['start_line_no'] > 0


def test_am06_ambiguous_column_references_detected():
    """Test that AM06 (ambiguous.column_references) issue is detected."""
    violations = get_sqlfluff_violations("demo.sql")
    am06_violations = [v for v in violations if v['code'] == 'AM06']
    assert len(am06_violations) >= 1, "AM06 (ambiguous.column_references) not detected in demo.sql"


def test_am09_limit_without_orderby_detected():
    """Test that AM09 (ambiguous.order_by_limit) issue is detected."""
    violations = get_sqlfluff_violations("demo.sql")
    am09_violations = [v for v in violations if v['code'] == 'AM09']
    assert len(am09_violations) >= 1, "AM09 (ambiguous.order_by_limit) not detected in demo.sql"


def test_cv05_is_null_comparison_detected():
    """Test that CV05 (convention.is_null) issue is detected."""
    violations = get_sqlfluff_violations("demo.sql")
    cv05_violations = [v for v in violations if v['code'] == 'CV05']
    assert len(cv05_violations) >= 1, "CV05 (convention.is_null) not detected in demo.sql"


def test_al01_implicit_aliasing_detected():
    """Test that AL01 (aliasing.table) issue is detected."""
    violations = get_sqlfluff_violations("demo.sql")
    al01_violations = [v for v in violations if v['code'] == 'AL01']
    assert len(al01_violations) >= 1, "AL01 (aliasing.table) not detected in demo.sql"


def test_at_least_five_issue_types():
    """Test that at least 5 different types of impactful issues are detected."""
    violations = get_sqlfluff_violations("demo.sql")

    # Extract unique issue codes
    issue_codes = set(v['code'] for v in violations)

    # Define the 5 most impactful issues
    impactful_issues = {'AL01', 'AL03', 'AM06', 'AM09', 'CV05'}

    found_issues = issue_codes & impactful_issues

    assert len(found_issues) >= 5, f"Expected to find at least 5 impactful issues, found: {found_issues}"


def test_violations_have_descriptions():
    """Test that all violations have meaningful descriptions."""
    violations = get_sqlfluff_violations("demo.sql")

    for violation in violations:
        assert 'description' in violation, "Violation missing description"
        assert len(violation['description']) > 0, "Violation has empty description"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
