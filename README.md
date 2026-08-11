# icdk (IC Development Toolkit)  
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/uvmgen)
[![PyPI - Version](https://img.shields.io/pypi/v/uvmgen)](https://pypi.org/project/uvmgen)
![GitHub language count](https://img.shields.io/github/languages/count/Dragon-Git/icdk?logo=python)
[![Latest Release](https://img.shields.io/github/v/release/Dragon-Git/icdk?color=blue&label=Latest%20Release)](https://github.com/Dragon-Git/icdk/releases/latest)
[![downloads](https://pepy.tech/badge/uvmgen)](https://pepy.tech/project/uvmgen)
[![CI](https://github.com/Dragon-Git/icdk/actions/workflows/python-package.yml/badge.svg)](https://github.com/Dragon-Git/icdk/actions/workflows/python-package.yml)
[![codecov](https://codecov.io/gh/Dragon-Git/icdk/graph/badge.svg?token=ICDK)](https://codecov.io/gh/Dragon-Git/icdk)
![GitHub deployments](https://img.shields.io/github/deployments/Dragon-Git/icdk/release)

---
## Introduction

**icdk** (IC Development Toolkit) is a Python-based toolkit that accelerates UVM (Universal Verification Methodology) testbench development. It ships two CLI utilities:

| Tool | Description |
|------|-------------|
| **`uvmgen`** | Generates a complete UVM testbench directory tree from a JSON/YAML/TOML/XML configuration file. |
| **`sudef`** | Expands `super_define` Mako templates embedded in SystemVerilog comments to produce repetitive SV code. |

### Key Features

- **Multi-format configuration** — JSON, YAML, TOML, and XML are all supported.
- **Template-driven** — All output is rendered from [Mako](https://www.makotemplates.org/) templates that you can customize.
- **Modular packages** — Generate a full testbench or individual packages (agent, env, RAL, seq_lib, test, tb_lib).
- **Third-party integration** — Optional support for [SyoSil UVM Scoreboard](https://github.com/Dragon-Git/uvm_syoscb), [svlib](https://github.com/Dragon-Git/svlib), and [cluelib](https://github.com/Dragon-Git/cluelib).
- **Python 3.9 – 3.13** — Tested across CPython 3.9 through 3.13 on Linux, macOS, and Windows.

## Installing

<details>
  <summary>Prerequisites</summary>

- **Operating systems**: Windows, Linux, macOS
- **Python**: 3.9 – 3.13
</details>

Install from PyPI:

```bash
python3 -m pip install uvmgen
```

Or install from source for development:

```bash
git clone https://github.com/Dragon-Git/icdk.git
cd icdk
python3 -m pip install -e '.[dev]'
```

---

## uvmgen — UVM Testbench Generator

### Quick Start

```bash
uvmgen --input <config_file> --output <output_directory>
```

| Option | Short | Description |
|--------|-------|-------------|
| `--input` | `-i` | Path to the configuration file (JSON/YAML/TOML/XML). |
| `--output` | `-o` | Output directory (default: `tb`). |

```bash
# Generate a full testbench
uvmgen -i testbench_config.json -o tb

# Use default output directory "tb"
uvmgen -i testbench_config.json

# Show help
uvmgen -h
```

### Configuration File Format

Every configuration file is a mapping of **package name → package definition**. Each package definition has three keys:

| Key | Type | Description |
|-----|------|-------------|
| `description` | `str` | Human-readable description (not used in code generation). |
| `type` | `str` | Template group identifier. Must match a sub-directory under `templates/`. |
| `vars` | `dict` | Variables passed to the Mako template renderer. |

#### Supported Package Types

| `type` | Template directory | Generated files |
|--------|--------------------|-----------------|
| `agt_pkg` | `templates/agt_pkg/` | agent, driver, monitor, sequencer, item, config, coverage, interface, reg_adapter, mon2cov_connect, pkg |
| `env_pkg` | `templates/env_pkg/` | env, env_cfg, scoreboard, virtual sequencer, pkg |
| `ral_pkg` | `templates/ral_pkg/` | register abstraction layer pkg |
| `seq_lib_pkg` | `templates/seq_lib_pkg/` | base_seq, seq, seq_lib, vseq, pkg |
| `test_pkg` | `templates/test_pkg/` | base_test, test_builder, pkg |
| `tb_lib` | `templates/tb_lib/` | top-level tb module, filelist |

#### Configuration Examples

The same configuration can be expressed in any of the four supported formats:

**JSON** (`.json`):
```json
{
    "spi_agt_pkg": {
        "description": "SPI agent package",
        "type": "agt_pkg",
        "vars": {
            "pkg_name": "spi_agt_pkg",
            "import_pkgs": [],
            "agent_name": "spi",
            "drv_type": "pull",
            "drv_export_type": "block",
            "mon2cov_con_method": "analysis_port"
        }
    }
}
```

**YAML** (`.yaml`):
```yaml
spi_env_pkg:
  description: SPI env package
  type: env_pkg
  vars:
    pkg_name: spi_env_pkg
    import_pkgs:
      - spi_agt_pkg
      - ral_pkg
    env_name: spi_env
    env_childs:
      m_spi_agt: spi_agt
    scb_name: spi_scb
    vsqr_name: spi_vsqr
    has_regmodel: True
    ral_block_name: empty_reg_block
    reg_agt_name: m_spi_agt
    mon2cov_con_method: analysis_port
```

**TOML** (`.toml`):
```toml
[spi_tb_lib]
  description = "SPI test package"
  type = "tb_lib"

[spi_tb_lib.vars]
  pkg_name = "spi_tb_lib"
  import_pkgs = ["spi_test_pkg"]
  if_name = "spi_if"
  filelist_pkgs = ["spi_agt_pkg", "spi_ral_pkg", "spi_env_pkg", "spi_seq_lib_pkg", "spi_test_pkg", "spi_tb_lib"]
```

**XML** (`.xml`):
```xml
<spi_ral_pkg>
    <description>SPI ral package</description>
    <type>ral_pkg</type>
    <vars>
        <pkg_name>spi_ral_pkg</pkg_name>
    </vars>
</spi_ral_pkg>
```

### Common Template Variables

The `vars` dict varies by package type. Below is a reference for the most commonly used variables:

| Variable | Used by | Description |
|----------|---------|-------------|
| `pkg_name` | all | Package name (used in `` `include `` and class names). |
| `import_pkgs` | all | List of packages to import. |
| `agent_name` | `agt_pkg` | Base name for agent classes (e.g. `spi_agt`, `spi_drv`). |
| `drv_type` | `agt_pkg` | Driver type: `"pull"` or `"push"`. |
| `drv_export_type` | `agt_pkg` | Driver export type: `"block"` or other. |
| `mon2cov_con_method` | `agt_pkg` | Monitor-to-coverage connection: `"analysis_port"` or `"callback"`. |
| `env_name` | `env_pkg`, `test_pkg` | Environment class name. |
| `env_childs` | `env_pkg` | Dict of child component instances. |
| `scb_name` | `env_pkg` | Scoreboard name. |
| `vsqr_name` | `env_pkg`, `seq_lib_pkg` | Virtual sequencer name. |
| `has_regmodel` | `env_pkg` | Whether to include register model integration. |
| `ral_block_name` | `env_pkg` | Register block name. |
| `seq_lib_name` | `seq_lib_pkg`, `test_pkg` | Sequence library name. |
| `seq_name` | `seq_lib_pkg` | Sequence name. |
| `vseq_name` | `seq_lib_pkg`, `test_pkg` | Virtual sequence name. |
| `test_name` | `test_pkg` | Base test class name. |
| `seq_start_method` | `test_pkg` | Method to start the virtual sequence. |
| `if_name` | `tb_lib` | Top-level interface name. |
| `filelist_pkgs` | `tb_lib` | Ordered list of packages for the filelist. |

### Generated Output Structure

Running `uvmgen -i typical.json -o tb` produces:

```
tb/
├── spi_agt_pkg/
│   ├── spi_agt_pkg.gen.sv
│   ├── spi_agt.gen.sv
│   ├── spi_cfg.gen.sv
│   ├── spi_cov.gen.sv
│   ├── spi_drv.gen.sv
│   ├── spi_if.gen.sv
│   ├── spi_item.gen.sv
│   ├── spi_mon.gen.sv
│   ├── spi_mon2cov_connect.gen.sv
│   ├── spi_reg_adapter.gen.sv
│   └── spi_sqr.gen.sv
├── typical_env_pkg/
│   ├── typical_env_pkg.gen.sv
│   ├── typical_env.gen.sv
│   ├── typical_env_cfg.gen.sv
│   ├── typical_scb.gen.sv
│   └── typical_vsqr.gen.sv
├── typical_ral_pkg/
│   └── typical_ral_pkg.gen.sv
├── typical_seq_lib_pkg/
│   ├── typical_seq_lib_pkg.gen.sv
│   ├── spi_base_seq.gen.sv
│   ├── spi_seq.gen.sv
│   ├── spi_seq_lib.gen.sv
│   └── typical_vseq.gen.sv
├── typical_test_pkg/
│   ├── typical_test_pkg.gen.sv
│   ├── spi_base_test.gen.sv
│   └── spi_test_builder.gen.sv
└── typical_tb_lib/
    ├── tb.gen.sv
    └── filelist.f
```

### Running the Generated Testbench

The generated `filelist.f` can be used directly with major simulators:

```bash
# Synopsys VCS
vcs -sverilog -full64 -ntb_opts <uvm_version> \
    -f tb/typical_tb_lib/filelist.f \
    -R +UVM_TESTNAME=base_test +UVM_TEST_SEQ=typical_vseq

# Cadence Xcelium
xrun -sv -64bit -uvmhome <uvm_version> \
    -f tb/typical_tb_lib/filelist.f \
    +UVM_TESTNAME=base_test +UVM_TEST_SEQ=typical_vseq
```

> `<uvm_version>` for VCS: `uvm-1.1`, `uvm-1.2`, `uvm-ieee`, `uvm-ieee-2020`  
> `<uvm_version>` for Xcelium: `CDNS-1.1d`, `CDNS-1.2`, `CDNS-IEEE`

### Optional Libraries

#### SyoSil UVM Scoreboard

The [SyoSil ApS UVM Scoreboard](https://github.com/Dragon-Git/uvm_syoscb) can be integrated into generated environments:

1. Add `"pk_syoscb"` to `import_pkgs` in your `env_pkg` configuration.
2. Set the `SYOSCB_HOME` environment variable to the installed directory.

After generation, `uvmgen` prints the required environment variables:

```bash
export SYOSCB_HOME=/path/to/uvm_syoscb
export TB_PATH=/path/to/tb
```

#### svlib

[svlib](https://github.com/Dragon-Git/svlib) is a free, open-source library of utility functions for SystemVerilog, including file/string manipulation, regex search/replace, configuration file I/O, and more.

#### cluelib

[cluelib](https://github.com/Dragon-Git/cluelib) is a free, open-source generic utility library written in SystemVerilog.

### Custom Templates

Templates are [Mako](https://docs.makotemplates.org/) `.mako.sv` files located under `src/uvmgen/templates/`. To use custom templates:

1. Create a template directory with the same structure (e.g. `my_templates/agt_pkg/agt.mako.sv`).
2. Pass the directory path to the `UVMGen` constructor:

```python
from uvmgen.uvmgen import UVMGen

gen = UVMGen(template_path="my_templates")
gen.gen("config.json", "tb")
```

Template files use the `.mako.sv` extension and can reference any variable from the `vars` dict in the configuration file. Files with `pkg` in their name are rendered last, allowing them to reference previously generated files.

---

## sudef — SV File Template Generator

### Overview

`sudef` is a command-line tool that processes SystemVerilog (`.sv`/`.svh`) files containing Mako-style templates in comments. It expands `super_define()` blocks into rendered SystemVerilog code.

### Usage

```bash
sudef <input>
```

Where `<input>` is a file or directory path. If a directory is given, `sudef` recursively processes all `.sv`/`.svh` files within it.

### Two Modes

| Mode | Syntax | Behavior |
|------|--------|----------|
| **Inline** | `/* super_define() ... */` | Rendered code is inserted directly into the original file. |
| **External file** | `/* super_define(filename.svh) ... */` | Rendered code is written to the specified file; an `` `include `` directive replaces the template block. |

### Example

**Input** (`example.sv`):
```systemverilog
/* super_define()
<%

%>\
% for i in range(3):
int cfg_${i};
% endfor

`uvm_object_utils_begin(mycfg)
% for i in range(3):
`uvm_field_int(cfg_${i}, UVM_DEFAULT)
% endfor
`uvm_object_utils_end

*/
```

**Run**:
```bash
sudef example.sv
```

**Output** (`example.sv`, modified in-place):
```systemverilog
/* super_define()
<%

%>\
% for i in range(3):
int cfg_${i};
% endfor

`uvm_object_utils_begin(mycfg)
% for i in range(3):
`uvm_field_int(cfg_${i}, UVM_DEFAULT)
% endfor
`uvm_object_utils_end

*/
// super_define generate begin
int cfg_0;
int cfg_1;
int cfg_2;

`uvm_object_utils_begin(mycfg)
`uvm_field_int(cfg_0, UVM_DEFAULT)
`uvm_field_int(cfg_1, UVM_DEFAULT)
`uvm_field_int(cfg_2, UVM_DEFAULT)
`uvm_object_utils_end
// super_define generate end
```

**External file mode** — use `super_define(cfg_inc.svh)` to write the generated code to `cfg_inc.svh` and replace the block with an `` `include `` directive.

> **Note:** `sudef` is experimental. Features may not be fully tested. Please report any issues.

---

## Project Structure

```
icdk/
├── src/uvmgen/
│   ├── __init__.py              # Package metadata (__version__, __all__)
│   ├── uvmgen.py                # UVMGen class & uvmgen CLI entry point
│   ├── super_define.py          # sudef CLI entry point
│   └── templates/               # Mako template files
│       ├── agt_pkg/             # Agent package templates (11 files)
│       ├── env_pkg/             # Environment package templates (5 files)
│       ├── ral_pkg/             # Register abstraction layer templates
│       ├── seq_lib_pkg/         # Sequence library templates (5 files)
│       ├── test_pkg/            # Test package templates (3 files)
│       └── tb_lib/              # Top-level testbench & filelist
├── test/
│   ├── json/
│   │   ├── base_pkg/            # Single-package test configs (JSON/YAML/TOML/XML)
│   │   └── example/             # Full testbench example config
│   ├── super_define_data/       # sudef test fixtures
│   ├── test_base.py             # End-to-end tests for uvmgen
│   ├── test_example.py          # Full testbench generation tests
│   └── test_super_define.py     # sudef unit tests
├── .github/workflows/
│   └── python-package.yml       # CI: lint (Ruff) + test (pytest) + build + deploy
├── pyproject.toml               # Project metadata, dependencies, tool config
├── requirements.txt             # Dev-only convenience requirements
├── MANIFEST.in                  # Packaging include rules
└── README.md
```

## Development

### Setup

```bash
git clone https://github.com/Dragon-Git/icdk.git
cd icdk
python3 -m pip install -e '.[dev]'
```

This installs `ruff` (lint), `pytest` + `pytest-cov` (test), and `sphinx` (docs) in addition to the runtime dependencies.

### Lint

```bash
ruff check .
```

### Test

```bash
pytest test/ -v --cov=uvmgen --cov-fail-under=60
```

### CI

The [CI pipeline](https://github.com/Dragon-Git/icdk/actions/workflows/python-package.yml) runs on every push/PR to `master`:

1. **Lint** with `astral-sh/ruff-action`
2. **Test** across Python 3.9–3.13 on Ubuntu, macOS, and Windows
3. **Coverage** reported to Codecov (threshold: 60%)
4. **Build** wheel and sdist on tag push
5. **Deploy** to PyPI on tag push

---

## Contribute

Contributions are always welcome! Fork this repo and submit a pull request.

## License

This project is licensed under the BSD-3-Clause License.
