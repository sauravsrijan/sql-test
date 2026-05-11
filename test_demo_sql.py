"""Test suite for demo.sql - verifies 5 most impactful SQLFluff issues"""

import subprocess
import json
from pathlib import Path


def run_sqlfluff_lint(sql_file: str) -> list:
    """Run sqlfluff lint and return violations as list of dicts"""
    result = subprocess.run(
        ["sqlfluff", "lint", sql_file, "--dialect", "postgres", "--format", "json"],
        capture_output=True,
        text=True,
    )
    if result.returncode in (0, 1):  # 0 = no violations, 1 = violations found
        try:
            data = json.loads(result.stdout)
            # sqlfluff returns array of file objects with violations nested
            if isinstance(data, list) and len(data) > 0:
                return data[0].get("violations", [])
            return data.get("violations", []) if isinstance(data, dict) else []
        except json.JSONDecodeError:
            return []
    return []


def test_am09_limit_without_order_by():
    """Test that AM09 violation is detected: LIMIT without ORDER BY"""
    violations = run_sqlfluff_lint("demo.sql")
    am09_violations = [v for v in violations if v["code"] == "AM09"]
    assert len(am09_violations) > 0, "AM09 (LIMIT without ORDER BY) should be detected"
    print(f"✓ AM09 detected: {len(am09_violations)} violation(s)")


def test_am05_unqualified_join():
    """Test that AM05 violation is detected: Join clauses should be fully qualified"""
    violations = run_sqlfluff_lint("demo.sql")
    am05_violations = [v for v in violations if v["code"] == "AM05"]
    assert len(am05_violations) > 0, "AM05 (Unqualified join) should be detected"
    print(f"✓ AM05 detected: {len(am05_violations)} violation(s)")


def test_am08_implicit_cross_join():
    """Test that AM08 violation is detected: Implicit cross join"""
    violations = run_sqlfluff_lint("demo.sql")
    am08_violations = [v for v in violations if v["code"] == "AM08"]
    assert len(am08_violations) > 0, "AM08 (Implicit cross join) should be detected"
    print(f"✓ AM08 detected: {len(am08_violations)} violation(s)")


def test_cp01_keyword_capitalization():
    """Test that CP01 violation is detected: Inconsistent keyword capitalization"""
    violations = run_sqlfluff_lint("demo.sql")
    cp01_violations = [v for v in violations if v["code"] == "CP01"]
    assert len(cp01_violations) > 0, "CP01 (Keyword capitalization) should be detected"
    print(f"✓ CP01 detected: {len(cp01_violations)} violation(s)")


def test_al01_implicit_aliasing():
    """Test that AL01 violation is detected: Implicit/explicit aliasing of table"""
    violations = run_sqlfluff_lint("demo.sql")
    al01_violations = [v for v in violations if v["code"] == "AL01"]
    assert len(al01_violations) > 0, "AL01 (Implicit aliasing) should be detected"
    print(f"✓ AL01 detected: {len(al01_violations)} violation(s)")


def test_all_five_violations_present():
    """Integration test: verify all 5 key violations are present in demo.sql"""
    violations = run_sqlfluff_lint("demo.sql")
    rule_codes = {v["code"] for v in violations}

    required_rules = {"AM09", "AM05", "AM08", "CP01", "AL01"}
    assert required_rules.issubset(rule_codes), (
        f"All 5 rules should be present. "
        f"Found: {required_rules & rule_codes}, "
        f"Missing: {required_rules - rule_codes}"
    )
    print(f"✓ All 5 violations detected: {sorted(required_rules)}")


def test_demo_sql_file_exists():
    """Test that demo.sql file exists"""
    demo_file = Path("demo.sql")
    assert demo_file.exists(), "demo.sql file should exist"
    print("✓ demo.sql exists")


def test_demo_sql_under_100_lines():
    """Test that demo.sql is under 100 lines"""
    with open("demo.sql", "r") as f:
        lines = f.readlines()
    assert len(lines) <= 100, f"demo.sql should be under 100 lines, got {len(lines)}"
    print(f"✓ demo.sql is {len(lines)} lines (under 100 limit)")


def test_demo_sql_has_production_context():
    """Test that demo.sql has realistic production-level SQL"""
    with open("demo.sql", "r") as f:
        content = f.read()

    # Check for realistic keywords and patterns
    realistic_keywords = ["orders", "customers", "products", "categories", "users"]
    has_realistic_content = any(keyword in content for keyword in realistic_keywords)
    assert has_realistic_content, "demo.sql should contain realistic production-level SQL"
    print("✓ demo.sql contains production-level SQL patterns")
