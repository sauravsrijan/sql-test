"""Test suite for SQL files using SQLFluff linter.

This module provides comprehensive testing for SQL files by leveraging SQLFluff,
a production-grade SQL linter. Tests verify both specific rule violations and
overall code quality standards.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Any


def run_sqlfluff_lint(sql_file: str) -> list[dict[str, Any]]:
    """Run SQLFluff linter on a SQL file and return violations.

    Args:
        sql_file: Path to the SQL file to lint.

    Returns:
        List of violation dictionaries from SQLFluff output. Returns empty list
        if linting fails or produces no violations.

    Raises:
        No exceptions raised; errors are handled gracefully.
    """
    result = subprocess.run(
        ["sqlfluff", "lint", sql_file, "--dialect", "postgres", "--format", "json"],
        capture_output=True,
        text=True,
    )
    if result.returncode not in (0, 1):
        return []

    try:
        data = json.loads(result.stdout)
        if isinstance(data, list) and len(data) > 0:
            return data[0].get("violations", [])
        return data.get("violations", []) if isinstance(data, dict) else []
    except json.JSONDecodeError:
        return []


def test_am09_limit_without_order_by() -> None:
    """Verify AM09 violations are detected for LIMIT without ORDER BY."""
    violations = run_sqlfluff_lint("demo.sql")
    am09_violations = [v for v in violations if v["code"] == "AM09"]
    assert len(am09_violations) > 0, "AM09 (LIMIT without ORDER BY) should be detected"


def test_am05_unqualified_join() -> None:
    """Verify AM05 violations are detected for unqualified join clauses."""
    violations = run_sqlfluff_lint("demo.sql")
    am05_violations = [v for v in violations if v["code"] == "AM05"]
    assert len(am05_violations) > 0, "AM05 (Unqualified join) should be detected"


def test_am08_implicit_cross_join() -> None:
    """Verify AM08 violations are detected for implicit cross joins."""
    violations = run_sqlfluff_lint("demo.sql")
    am08_violations = [v for v in violations if v["code"] == "AM08"]
    assert len(am08_violations) > 0, "AM08 (Implicit cross join) should be detected"


def test_cp01_keyword_capitalization() -> None:
    """Verify CP01 violations are detected for inconsistent keyword capitalization."""
    violations = run_sqlfluff_lint("demo.sql")
    cp01_violations = [v for v in violations if v["code"] == "CP01"]
    assert len(cp01_violations) > 0, "CP01 (Keyword capitalization) should be detected"


def test_al01_implicit_aliasing() -> None:
    """Verify AL01 violations are detected for implicit/explicit table aliasing."""
    violations = run_sqlfluff_lint("demo.sql")
    al01_violations = [v for v in violations if v["code"] == "AL01"]
    assert len(al01_violations) > 0, "AL01 (Implicit aliasing) should be detected"


def test_all_five_violations_present() -> None:
    """Integration test: verify all 5 key violations are present in demo.sql."""
    violations = run_sqlfluff_lint("demo.sql")
    rule_codes = {v["code"] for v in violations}

    required_rules = {"AM09", "AM05", "AM08", "CP01", "AL01"}
    assert required_rules.issubset(rule_codes), (
        f"All 5 rules should be present. "
        f"Found: {required_rules & rule_codes}, "
        f"Missing: {required_rules - rule_codes}"
    )


def test_demo_sql_file_exists() -> None:
    """Verify demo.sql file exists."""
    demo_file = Path("demo.sql")
    assert demo_file.exists(), "demo.sql file should exist"


def test_demo_sql_under_100_lines() -> None:
    """Verify demo.sql file size is under 100 lines."""
    with open("demo.sql") as f:
        lines = f.readlines()
    assert len(lines) <= 100, f"demo.sql should be under 100 lines, got {len(lines)}"


def test_demo_sql_has_production_context() -> None:
    """Verify demo.sql contains realistic production-level SQL patterns."""
    with open("demo.sql") as f:
        content = f.read()

    realistic_keywords = ["orders", "customers", "products", "categories", "users"]
    has_realistic_content = any(keyword in content for keyword in realistic_keywords)
    assert has_realistic_content, "demo.sql should contain realistic production-level SQL"
