"""End-to-end tests for UVMGen.gen with the base_pkg configuration set."""

from __future__ import annotations

from pathlib import Path

import pytest

from uvmgen.uvmgen import UVMGen

CONFIG_DIR = Path(__file__).parent / "json" / "base_pkg"
CONFIG_PATHS = sorted(CONFIG_DIR.iterdir())

EXPECTED_PACKAGES = {
    "agt.json": ("spi_agt_pkg",),
    "env.yaml": ("spi_env_pkg",),
    "ral.xml": ("spi_ral_pkg",),
    "seq_lib.json": ("spi_seq_lib_pkg",),
    "tb.toml": ("spi_tb_lib",),
    "test.json": ("spi_test_pkg",),
}


@pytest.mark.parametrize("config_path", CONFIG_PATHS, ids=lambda p: p.name)
def test_agt(tmp_path: Path, config_path: Path) -> None:
    """Generate a testbench and verify that the expected output files exist.

    The test runs :meth:`UVMGen.gen` against each of the sample configurations
    shipped with the project and ensures that for every declared package at
    least one non-empty output file is produced.
    """
    output_dir = tmp_path / "tb" / "base_pkg"
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
