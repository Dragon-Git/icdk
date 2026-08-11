"""Tests for :func:`uvmgen.super_define.super_define`."""

from __future__ import annotations

import filecmp
import shutil
from pathlib import Path

from uvmgen.super_define import super_define

FIXTURE_DIR = Path(__file__).parent / "super_define_data"


def _copy_fixture_to_tmp(tmp_path: Path, name: str) -> Path:
    """Copy a fixture file into ``tmp_path`` and return its path."""
    src = FIXTURE_DIR / name
    dst = tmp_path / name
    shutil.copy2(src, dst)
    return dst


def test_super_define_inline(tmp_path: Path) -> None:
    """Inline mode generates the expected content without mutating fixtures."""
    test_file = _copy_fixture_to_tmp(tmp_path, "sudef_inline.sv")
    exp_file = FIXTURE_DIR / "sudef_inline_exp.sv"

    super_define(str(test_file))

    assert filecmp.cmp(test_file, exp_file)


def test_super_define_inc(tmp_path: Path) -> None:
    """Include mode emits a separate include file and rewrites the caller."""
    test_file = _copy_fixture_to_tmp(tmp_path, "sudef_inc.sv")
    exp_file = FIXTURE_DIR / "sudef_inc_exp.sv"
    inc_exp_file = FIXTURE_DIR / "cfg_inc_exp.svh"

    super_define(str(test_file))

    inc_file = tmp_path / "cfg_inc.svh"
    assert filecmp.cmp(test_file, exp_file)
    assert inc_file.exists(), f"Expected generated include file: {inc_file}"
    assert filecmp.cmp(inc_file, inc_exp_file)


def test_super_define_no_match(tmp_path: Path) -> None:
    """A file without super_define markers is left unchanged."""
    src = FIXTURE_DIR / "sudef_inline.sv"
    target = tmp_path / "plain.sv"
    original = src.read_text().replace("super_define", "no_template_here")
    target.write_text(original)

    super_define(str(target))

    assert target.read_text() == original
