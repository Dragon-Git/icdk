"""End-to-end tests for UVMGen.gen with the example configuration set."""

from __future__ import annotations

from pathlib import Path

import pytest

from uvmgen.uvmgen import UVMGen

CONFIG_DIR = Path(__file__).parent / "json" / "example"
CONFIG_PATHS = sorted(CONFIG_DIR.iterdir())

EXPECTED_PACKAGES = {
    "single_pkg.json": ("example_agent", "example_env", "example_tb", "example_test_lib"),
}


@pytest.mark.parametrize("config_path", CONFIG_PATHS, ids=lambda p: p.name)
def test_single_pkg(tmp_path: Path, config_path: Path) -> None:
    """Generate the example testbench and verify output.

    The test asserts that a non-empty directory is created for each expected
    package, which confirms the generator did not silently skip any blocks.
    """
    output_dir = tmp_path / "tb" / "example_tb"
    UVMGen().gen(str(config_path), str(output_dir))

    expected = EXPECTED_PACKAGES.get(config_path.name)
    if expected is None:
        pytest.skip(f"No expected package mapping for {config_path.name}")

    produced_files = [p for p in output_dir.rglob("*") if p.is_file()]
    assert produced_files, "Expected output files but none were produced"

    for pkg_name in expected:
        pkg_dir = output_dir / pkg_name
        assert pkg_dir.is_dir(), f"Missing package directory: {pkg_dir}"
        non_empty = [p for p in pkg_dir.iterdir() if p.is_file() and p.stat().st_size > 0]
        assert non_empty, f"No non-empty files in {pkg_dir}"
