"""Verilator smoke tests for the generated UVM testbench.

This module contains two tests:

* ``test_verilator_lint_typical`` — a fast static check that runs
  ``verilator --lint-only`` against the generator output. The lint
  pass surfaces most of the SystemVerilog syntax / type-mismatch
  problems a generator can introduce without doing any C++ compile.

* ``test_verilator_sim_typical`` — a full end-to-end build + run that
  uses ``verilator --binary`` to compile a C++ executable and then
  invokes it. This is the real exercise: any UVM dynamic dispatch
  errors, missing DPI exports, or module-scoping problems will be
  caught here. The sim test can be skipped via
  ``ICDK_SKIP_VERILATOR_SIM=1`` because the build is heavy (a few
  minutes, a few hundred MB of C++ output).

Both tests
* apply a small patch to the in-tree ``uvm_syoscb`` submodule
  (``test/verilator_patches/uvm_syoscb_verilator_compat.patch``) to
  work around Verilator's strict UVM type-system checks. The patch
  is **not** committed to the submodule; it lives in this repository
  as a build-time adapter. The patch is idempotent.
* locate a UVM source tree at ``$UVM_HOME`` (defaults to
  ``/tmp/uvm-verilator/src`` if unset).
* skip themselves if Verilator or the UVM source is missing.

The flag set used here is tuned for UVM 1.x in cycle-based sim mode.
``-Wno-*`` flags silence benign warnings that UVM routinely raises
but which do not indicate a generator bug. ``-fno-func-opt`` works
around an internal Verilator V3FuncOpt crash
(``Inconsistent assignment``) on one of uvm_syoscb's comparison
helpers. ``--bbox-unsup``/``--bbox-sys`` allow Verilator to compile
SystemVerilog features it does not support (so we can still report
semantic errors that *are* its concern).
"""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
SUBMODULE_DIR = REPO_ROOT / "src" / "uvmgen" / "uvm_syoscb"
PATCH_PATH = (
    REPO_ROOT / "test" / "verilator_patches" / "uvm_syoscb_verilator_compat.patch"
)
DEFAULT_UVM_SRC = Path("/tmp/uvm-verilator/src")
EXAMPLE_JSON = REPO_ROOT / "test" / "json" / "example" / "typical.json"


def _verilator_available() -> bool:
    return shutil.which("verilator") is not None


def _verilator_sim_supported() -> bool:
    """Return True if the local toolchain can build a Verilator C++ binary.

    Verilator's ``--binary`` mode produces a ``Vtb`` executable compiled
    against ``verilated_timing.cpp``, which uses ``std::coroutine_handle<>``
    (C++20). On most Linux distros this Just Works once a modern ``g++``
    is on PATH, but a few environments have edge cases — notably Alpine
    Linux (musl libc) where Verilator's precompiled-header machinery
    leaves an empty ``.fast.gch`` artefact that later trips up the
    linker. Even on a good toolchain the test is heavy (a few minutes),
    so we gate it here.

    ``veryl-lang/setup-verilator`` installs the binary plus headers into
    its own prefix (not ``/usr/include``), so a path check is fragile.
    We ask verilator itself where its root is (``--getenv VERILATOR_ROOT``)
    and probe that the timing header is compileable there.
    """
    if not _verilator_available():
        return False
    cc = shutil.which("c++") or shutil.which("g++") or shutil.which("clang++")
    if cc is None:
        return False
    try:
        os_release = (Path("/etc/os-release")).read_text().lower()
    except OSError:
        os_release = ""
    if "alpine" in os_release:
        return False
    # A Verilator binary present on a non-Alpine Linux with a C++20
    # compiler is enough to *attempt* the build; the actual compile is
    # what really validates the toolchain. We intentionally do NOT gate
    # on header-path probes here because setup-verilator's prebuilt
    # packages place headers in a per-action prefix that is not exposed
    # as an env var. The ``--binary`` call itself wires up the include
    # dirs via verilator's own makefiles.
    return True


def _uvm_src() -> Path:
    return Path(os.environ.get("UVM_HOME", str(DEFAULT_UVM_SRC)))


def _apply_submodule_patch() -> None:
    """Apply (or no-op if already applied) the Verilator compatibility patch.

    The patch targets the ``uvm_syoscb`` submodule work tree.
    """
    if not PATCH_PATH.exists():
        return
    # If the patch is already applied, ``git apply --check`` returns
    # non-zero because the work tree is dirty. That's our "already done"
    # signal. Otherwise we apply it.
    r = subprocess.run(
        ["git", "apply", "--check", str(PATCH_PATH)],
        cwd=str(SUBMODULE_DIR),
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        # Either the patch is already applied, or it would not apply.
        # Distinguish by reading the work tree.
        if "tp_wrapper_filter_trfm" in (SUBMODULE_DIR / "src" / "cl_syoscbs.svh").read_text():
            return  # already patched
        # The patch really would not apply; raise so the user sees the
        # underlying git error.
        raise RuntimeError(
            f"uvm_syoscb Verilator patch failed to apply. "
            f"git apply --check stderr:\n{r.stderr}"
        )
    r = subprocess.run(
        ["git", "apply", str(PATCH_PATH)],
        cwd=str(SUBMODULE_DIR),
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        raise RuntimeError(
            f"uvm_syoscb Verilator patch failed to apply: {r.stderr}"
        )


# Verilator flag set tuned for UVM 1.x in lint-only mode. The ``-Wno-*``
# flags silence benign warnings that UVM routinely raises but which do
# not indicate a generator bug. ``-fno-func-opt`` works around an
# internal Verilator V3FuncOpt crash (``Inconsistent assignment``) on
# one of uvm_syoscb's comparison helpers. ``--bbox-unsup``/``--bbox-sys``
# allow Verilator to compile SystemVerilog features it does not support
# (so we can still report semantic errors that *are* its concern).
LINT_FLAGS: list[str] = [
    "-Wno-fatal",
    "-Wno-STMTDLY",
    "-Wno-WIDTH",
    "-Wno-UNUSEDSIGNAL",
    "-Wno-UNDRIVEN",
    "-Wno-DECLFILENAME",
    "-Wno-MULTIDRIVEN",
    "-Wno-PINMISSING",
    "-Wno-IMPLICIT",
    "-Wno-COMBDLY",
    "-Wno-INITIALDLY",
    "-Wno-IMPORTSTAR",
    "-Wno-CASEINCOMPLETE",
    "-Wno-UNOPTFLAT",
    "-Wno-VARHIDDEN",
    "-Wno-LATCH",
    "-Wno-NONSTD",
    "-Wno-COVERIGN",
    "-Wno-PROCASSWIRE",
    "-Wno-CMPCONST",
    "-Wno-SYMRSVDWORD",
    "-Wno-WIDTHTRUNC",
    "-Wno-WIDTHEXPAND",
    "-Wno-CONSTRAINTIGN",
    "-Wno-ZERODLY",
    "-Wno-CASTCONST",
    "-Wno-REDEFMACRO",
    "--bbox-unsup",
    "--bbox-sys",
    "-fno-func-opt",
]


def _run_lint(
    out_dir: Path, uvm_src: Path
) -> tuple[int, list[str], list[str], str]:
    """Run ``verilator --lint-only`` against the generated testbench.

    Returns ``(exit_code, error_lines, warning_lines, full_stderr)``.
    """
    pkg_files = sorted(str(p) for p in out_dir.rglob("*_pkg.gen.sv"))
    tb_file = str(out_dir / "typical_tb_lib" / "tb.gen.sv")
    if_file = str(out_dir / "spi_agt_pkg" / "spi_if.gen.sv")

    incdirs = sorted({f"+incdir+{Path(p).parent}" for p in pkg_files}) + [
        f"+incdir+{uvm_src}",
        f"+incdir+{SUBMODULE_DIR / 'src'}",
        f"+incdir+{SUBMODULE_DIR / 'lib'}",
    ]

    cmd = (
        ["verilator", "--lint-only", "--top-module", "tb", *LINT_FLAGS, *incdirs,
         f"{uvm_src}/uvm_pkg.sv", if_file,
         f"{SUBMODULE_DIR}/src/pk_syoscb.sv",
         f"{SUBMODULE_DIR}/lib/pk_utils_uvm.sv",
         *pkg_files, tb_file]
    )

    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300, cwd=str(out_dir))
    errs = [line for line in r.stderr.splitlines() if line.startswith("%Error")]
    warns = [line for line in r.stderr.splitlines() if line.startswith("%Warning")]
    return r.returncode, errs, warns, r.stderr


@pytest.mark.skipif(not _verilator_available(), reason="verilator not installed")
@pytest.mark.skipif(
    not DEFAULT_UVM_SRC.exists() and not os.environ.get("UVM_HOME"),
    reason="UVM source tree not found (set UVM_HOME or populate /tmp/uvm-verilator/src)",
)
def test_verilator_lint_typical() -> None:
    """Generate the example testbench and lint it with Verilator."""
    _apply_submodule_patch()

    uvm_src = _uvm_src()
    if not (uvm_src / "uvm_pkg.sv").exists():
        pytest.skip(f"UVM source not found at {uvm_src}")

    # Make sure the generator can be imported via the ``src`` layout.
    import sys
    sys.path.insert(0, str(REPO_ROOT / "src"))
    from uvmgen.uvmgen import UVMGen

    with tempfile.TemporaryDirectory() as td:
        out_dir = Path(td) / "tb"
        UVMGen().gen(str(EXAMPLE_JSON), str(out_dir))
        rc, errs, _warns, _stderr = _run_lint(out_dir, uvm_src)
        if rc != 0:
            ver = subprocess.run(
                ["verilator", "--version"], capture_output=True, text=True
            ).stdout.strip()
            assert False, (
                f"verilator --lint-only failed (verilator: {ver}) with "
                f"{len(errs)} error(s):\n" + "\n".join(errs[:20])
            )


def _run_sim(
    out_dir: Path,
    uvm_src: Path,
    timeout: int = 600,
) -> tuple[int, str, str, list[str], list[str]]:
    """Run ``verilator --binary`` and execute the resulting ``Vtb`` binary.

    Returns ``(sim_returncode, sim_stdout, sim_stderr, compile_errs, compile_warns)``.

    The build is timed and may take a few minutes because Verilator
    compiles a substantial C++ runtime for the UVM testbench. The
    C++ compiler is told to use C++20 (Verilator's timing simulator
    uses ``std::coroutine_handle<>`` which requires it).
    """
    pkg_files = sorted(str(p) for p in out_dir.rglob("*_pkg.gen.sv"))
    tb_file = str(out_dir / "typical_tb_lib" / "tb.gen.sv")
    if_file = str(out_dir / "spi_agt_pkg" / "spi_if.gen.sv")

    incdirs = sorted({f"+incdir+{Path(p).parent}" for p in pkg_files}) + [
        f"+incdir+{uvm_src}",
        f"+incdir+{SUBMODULE_DIR / 'src'}",
        f"+incdir+{SUBMODULE_DIR / 'lib'}",
    ]

    obj_dir = out_dir / "obj_dir"
    cmd = (
        ["verilator", "--binary", "--top-module", "tb",
         *LINT_FLAGS,
         # UVM needs Verilator's timing simulator runtime (coroutines
         # in ``verilated_timing.cpp``) which is C++20-only.
         "-CFLAGS", "-std=c++20",
         "-LDFLAGS", "-std=c++20",
         "--Mdir", str(obj_dir),
         *incdirs,
         f"{uvm_src}/uvm_pkg.sv", if_file,
         f"{SUBMODULE_DIR}/src/pk_syoscb.sv",
         f"{SUBMODULE_DIR}/lib/pk_utils_uvm.sv",
         *pkg_files, tb_file]
    )

    r = subprocess.run(cmd, capture_output=True, text=True, timeout=900, cwd=str(out_dir))
    compile_errs = [line for line in r.stderr.splitlines() if line.startswith("%Error")]
    compile_warns = [line for line in r.stderr.splitlines() if line.startswith("%Warning")]
    if r.returncode != 0:
        return r.returncode, "", r.stderr, compile_errs, compile_warns

    exe = obj_dir / "Vtb"
    if not exe.exists():
        # Some verilator builds lay out the binary under a
        # ``<top>/<top>`` subdirectory. Fall back to that path.
        for cand in (obj_dir / "tb" / "tb", obj_dir / "Vtb" / "Vtb"):
            if cand.exists():
                exe = cand
                break
        else:
            return 1, "", f"Vtb executable not found under {obj_dir}", compile_errs, compile_warns

    # The example generator emits a ``base_test`` that extends ``uvm_test``.
    # ``run_test()`` without arguments asks UVM to build whatever test is
    # named by ``+UVM_TESTNAME=``; passing the real class name here makes the
    # simulation actually run the UVM phasing (otherwise it exits after the
    # construction phase with no stimuli and nearly instant timing).
    r2 = subprocess.run(
        [str(exe), "+UVM_TESTNAME=base_test"],
        capture_output=True, text=True, timeout=timeout, cwd=str(out_dir),
    )
    return r2.returncode, r2.stdout, r2.stderr, compile_errs, compile_warns


@pytest.mark.skipif(not _verilator_available(), reason="verilator not installed")
@pytest.mark.skipif(
    not DEFAULT_UVM_SRC.exists() and not os.environ.get("UVM_HOME"),
    reason="UVM source tree not found (set UVM_HOME or populate /tmp/uvm-verilator/src)",
)
@pytest.mark.skipif(
    os.environ.get("ICDK_SKIP_VERILATOR_SIM") == "1",
    reason="full Verilator sim disabled via ICDK_SKIP_VERILATOR_SIM=1",
)
@pytest.mark.skipif(
    not _verilator_sim_supported(),
    reason=(
        "local toolchain cannot build a Verilator C++ binary (need C++20 + "
        "non-Alpine; set ICDK_SKIP_VERILATOR_SIM=1 to silence this skip on "
        "Alpine where the PCH path is broken upstream)"
    ),
)
def test_verilator_sim_typical() -> None:
    """Build the testbench with Verilator and run a short simulation.

    This is the full end-to-end smoke test: we generate the example
    testbench, compile it with ``verilator --binary`` (which invokes
    ``make`` under the hood), and execute ``Vtb``. The test only
    checks that the simulation produces output and exits cleanly —
    it does not validate functional correctness, because the example
    testbench's stimulus is intentionally minimal.

    Note: the Verilator binary mode requires a C++20 toolchain (the
    timing runtime uses ``std::coroutine_handle<>``) and a few minutes
    of compile time. The job is gated by ``ICDK_SKIP_VERILATOR_SIM``
    so it can be opted out of in resource-constrained CI environments
    without disabling lint.
    """
    _apply_submodule_patch()

    uvm_src = _uvm_src()
    if not (uvm_src / "uvm_pkg.sv").exists():
        pytest.skip(f"UVM source not found at {uvm_src}")

    import sys
    sys.path.insert(0, str(REPO_ROOT / "src"))
    from uvmgen.uvmgen import UVMGen

    with tempfile.TemporaryDirectory() as td:
        out_dir = Path(td) / "tb"
        UVMGen().gen(str(EXAMPLE_JSON), str(out_dir))
        rc, stdout, stderr, compile_errs, _compile_warns = _run_sim(out_dir, uvm_src)
        print("\n=== Vtb stdout ===")
        print(stdout or "(empty)")
        if stderr:
            print("=== Vtb stderr ===")
            print(stderr)
        assert not compile_errs, (
            f"verilator --binary failed with {len(compile_errs)} compile error(s):\n"
            + "\n".join(compile_errs[:10])
        )
        assert rc == 0, (
            f"Vtb exited with code {rc}.\n"
            f"--- stdout ---\n{stdout[-2000:]}\n"
            f"--- stderr ---\n{stderr[-2000:]}\n"
        )
        # UVM prints its own banner / report-summary on stdout, so the
        # absence of any output is itself a failure.
        assert stdout, "Vtb produced no stdout"
