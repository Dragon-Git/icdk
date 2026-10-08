"""XeZIM smoke test for the generated UVM testbench.

Runs *the same* generated testbench as the Verilator tests — same example
config (``test/json/example/typical.json``), same generated ``filelist.f``,
same plusargs, and the same ``uvm_syoscb`` compat patch — but under XeZIM,
so any construct the two simulators disagree on shows up as a failure here.

Deliberate differences from the Verilator run (only what the toolchain
forces):

* UVM sources come from XeZIM's bundled copy (``$XEZIM_PREFIX/share/uvm``).
  The generated testbench itself is byte-identical; only the UVM library
  differs, because Verilator needs the ``uvm-verilator`` fork while XeZIM
  ships its own supported UVM plus a matching ``uvm_dpi_xezim.cc``.
* XeZIM builds DPI export trampolines by spawning a bare ``cc``;
  ``test/xezim_cc_wrapper.sh`` fixes up its hardcoded flags (see the
  comments in that script).

Known XeZIM gaps this test currently trips over — candidates for upstream
bug reports:

* ``uvm_syoscb``'s ``extern virtual local function M [15:0] ...`` (a packed
  range on a typedef'd return type) is rejected at parse time.
* ``let`` declarations inside a function body
  (``cl_syoscbs_base::report_phase``) are rejected at parse time.
* ``uvm_config_db#(T)`` appears to treat typedef aliases of the same
  virtual interface as *different* types, so the
  tb → agent → driver interface hand-off dies with ``[NO_CONN]`` even
  though the identical sources run clean under Verilator.

Set ``ICDK_SKIP_XEZIM=1`` to skip.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest
from test_verilator_lint import _apply_submodule_patch

REPO_ROOT = Path(__file__).resolve().parent.parent
SUBMODULE_DIR = REPO_ROOT / "src" / "uvmgen" / "uvm_syoscb"
EXAMPLE_JSON = REPO_ROOT / "test" / "json" / "example" / "typical.json"
CC_WRAPPER = REPO_ROOT / "test" / "xezim_cc_wrapper.sh"

# Cap on simulated time; a run that never reaches UVM's report summary
# (hang, or XeZIM silently stopping) is a failure either way.
MAX_TIME = "10ms"
RUN_TIMEOUT = 600


def _xezim() -> Path | None:
    """Return the ``xezim`` binary on PATH, or None when not installed."""
    exe = shutil.which("xezim")
    return Path(exe) if exe else None


def _build_uvm_dpi(prefix: Path, uvm_src: Path, out: Path) -> None:
    """Compile UVM's DPI-C layer into a shared library XeZIM can dlopen.

    XeZIM does not link UVM's DPI functions into the simulator binary;
    ``uvm_dpi_xezim.cc`` (shipped in the XeZIM tarball) is the adapter
    that implements them against plain IEEE 1800 VPI and must be passed
    via ``--dpi-lib``.

    Args:
        prefix: Unpacked XeZIM install prefix (``bin/``, ``include/``, ...).
        uvm_src: The bundled UVM ``src/`` directory.
        out: Path of the ``.so``/``.dylib`` to write.

    Raises:
        AssertionError: If the compiler rejects the source.
    """
    cxx = shutil.which("c++") or shutil.which("g++") or shutil.which("clang++")
    assert cxx is not None, "no C++ compiler on PATH (needed for uvm_dpi_xezim.cc)"
    undef = ["-Wl,-undefined,dynamic_lookup"] if sys.platform == "darwin" else []
    cmd = [
        cxx, "-shared", "-fPIC", "-std=c++17", "-Wno-format-security",
        "-DUVM_NO_MALLOC",
        *undef,
        "-I", str(prefix / "include"),
        "-I", str(uvm_src / "dpi"),
        str(prefix / "include" / "uvm_dpi_xezim.cc"),
        "-o", str(out),
    ]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    assert r.returncode == 0, f"uvm_dpi_xezim.cc failed to build:\n{r.stderr[-4000:]}"


def _run_xezim(
    xezim: Path, out_dir: Path, uvm_src: Path, dpi_so: Path
) -> tuple[int, str]:
    """Run the generated testbench under XeZIM.

    Prepends a directory holding the ``cc`` wrapper so XeZIM's
    export-trampoline link picks it up (XeZIM resolves a bare ``cc``
    through PATH), exports the two variables the generated
    ``filelist.f`` expands, and runs with the same plusargs the
    Verilator test uses.

    Args:
        xezim: Path to the xezim binary.
        out_dir: Directory the testbench was generated into (``$TB_PATH``).
        uvm_src: The bundled UVM ``src/`` directory.
        dpi_so: The UVM DPI shared library built by :func:`_build_uvm_dpi`.

    Returns:
        ``(returncode, combined stdout+stderr log)``.
    """
    real_cc = shutil.which("cc") or shutil.which("gcc") or shutil.which("clang")
    assert real_cc is not None, "no C compiler on PATH (XEZIM_REAL_CC)"
    wrap_dir = out_dir / "ccwrap"
    wrap_dir.mkdir(exist_ok=True)
    (wrap_dir / "cc").symlink_to(CC_WRAPPER)

    env = os.environ.copy()
    env["PATH"] = f"{wrap_dir}{os.pathsep}{env['PATH']}"
    env["XEZIM_REAL_CC"] = str(real_cc)
    env["TB_PATH"] = str(out_dir)
    env["SYOSCB_HOME"] = str(SUBMODULE_DIR)

    cmd = [
        str(xezim), "--simulate", "-s", "tb",
        "--dpi-lib", str(dpi_so),
        "--max-time", MAX_TIME,
        "--error-exit",
        "-I", str(uvm_src),
        str(uvm_src / "uvm_pkg.sv"),
        "-f", str(out_dir / "typical_tb_lib" / "filelist.f"),
        "+UVM_TESTNAME=base_test",
        "+UVM_TEST_SEQ=typical_vseq",
    ]
    r = subprocess.run(
        cmd, capture_output=True, text=True, timeout=RUN_TIMEOUT,
        cwd=str(out_dir), env=env,
    )
    return r.returncode, r.stdout + r.stderr


@pytest.mark.skipif(_xezim() is None, reason="xezim not installed")
@pytest.mark.skipif(
    os.environ.get("ICDK_SKIP_XEZIM") == "1",
    reason="XeZIM test disabled via ICDK_SKIP_XEZIM=1",
)
def test_xezim_typical() -> None:
    """Run the example testbench under XeZIM and require a clean UVM run.

    The pass criteria mirror what the Verilator sim actually produces for
    this testbench: the simulator exits 0, UVM prints its report summary,
    and no UVM_ERROR / UVM_FATAL was reported. Parse / elaboration errors
    are asserted first so the log shows XeZIM's own diagnostics.
    """
    xezim = _xezim()
    assert xezim is not None
    prefix = xezim.parent.parent
    uvm_src = prefix / "share" / "uvm" / "src"
    if not (uvm_src / "uvm_pkg.sv").exists():
        pytest.skip(f"bundled UVM not found at {uvm_src}")

    _apply_submodule_patch()

    sys.path.insert(0, str(REPO_ROOT / "src"))
    from uvmgen.uvmgen import UVMGen

    with tempfile.TemporaryDirectory() as td:
        out_dir = Path(td) / "tb"
        UVMGen().gen(str(EXAMPLE_JSON), str(out_dir))

        dpi_so = Path(td) / "uvm_dpi_xezim.so"
        _build_uvm_dpi(prefix, uvm_src, dpi_so)

        rc, log = _run_xezim(xezim, out_dir, uvm_src, dpi_so)
        print("\n=== xezim log (tail) ===")
        print("\n".join(log.splitlines()[-120:]))

        errors = [ln for ln in log.splitlines() if " error:" in ln or ln.startswith("%Error")]
        assert not errors, (
            f"xezim reported {len(errors)} error line(s):\n" + "\n".join(errors[:20])
        )
        assert rc == 0, f"xezim exited with code {rc}:\n{log[-3000:]}"
        assert "UVM Report Summary" in log, (
            "UVM never reached its report summary (hang, or --max-time "
            f"{MAX_TIME} cap hit):\n{log[-3000:]}"
        )
        assert re.search(r"^UVM_ERROR :\s+0\s*$", log, re.M), (
            "UVM_ERROR count is not zero:\n" + log[-3000:]
        )
        assert re.search(r"^UVM_FATAL :\s+0\s*$", log, re.M), (
            "UVM_FATAL count is not zero:\n" + log[-3000:]
        )
