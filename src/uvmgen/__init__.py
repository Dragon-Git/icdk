"""UVM testbench framework generator toolkit.

The :mod:`uvmgen` package exposes two CLI utilities:

* ``uvmgen`` — generates a complete UVM testbench from a JSON/YAML/TOML/XML
  configuration file.
* ``sudef`` — expands ``super_define`` Mako templates embedded inside
  SystemVerilog comments.
"""

from __future__ import annotations

__version__ = "0.7.1"

__all__ = ["__version__"]
