# icdk (IC Deveplopment Toolkit)  
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/uvmgen)
[![PyPI - Version](https://img.shields.io/pypi/v/uvmgen)](https://pypi.org/project/uvmgen)
![GitHub language count](https://img.shields.io/github/languages/count/Dragon-Git/icdk?logo=python)
[![Latest Release](https://img.shields.io/github/v/release/Dragon-Git/icdk?color=blue&label=Latest%20Release)](https://github.com/Dragon-Git/icdk/releases/latest)
[![downloads](https://pepy.tech/badge/uvmgen)](https://pepy.tech/project/uvmgen)
[![CI](https://github.com/Dragon-Git/icdk/actions/workflows/python-package.yml/badge.svg)](https://github.com/Dragon-Git/icdk/actions/workflows/python-package.yml)
![GitHub deployments](https://img.shields.io/github/deployments/Dragon-Git/icdk/release)

---
## Introduction
uvmgen includes a uvm testbench generation tool `uvmgen` and an experimental code snippets generation tool `sudef`.

- `uvmgen` is a command-line interface (CLI) program for generating testbench structures based on a provided JSON/YAML/TOML/XML configuration file. 
- `sudef` is an command-line tool designed to process SystemVerilog files containing mako-style templates. By parsing specific comment formats, sudef generates SystemVerilog code that adheres to the defined templates.
## Installing
<details>
  <summary>Prerequisites</summary>

- Operating systems
  - Windows
  - Linux
  - macOS
- Python: 3.8 ~ 3.12
</details>

Use Python's package installer pip to install uvmgen:
```bash
python3 -m pip install uvmgen 
```

## uvmgen - uvm testbench generator

### Usage

The basic usage of uvmgen is as follows:
```bash
uvmgen --input <input_cfg_file> --output <output_directory>
```

### Options

- `--input <input_cfg_file>`: Specifies the input configuration file containing the configuration for the testbench structure.  
- `--output <output_directory>`: Specifies the directory where the generated files will be placed.

### Help

For additional help and options, you can use the -h or --help option:

```bash
uvmgen -h
```

### SyoSil ApS UVM Scoreboard
The [SyoSil ApS UVM Scoreboard](https://github.com/Dragon-Git/uvm_syoscb) is a feature of uvmgen that allows you to integrate SyoSil ApS UVM Scoreboard in environments. To use this feature, you need to add `pk_syoscb` to `import_pkgs` of env_pkg, and set the `SYOSCB_HOME` environment variables to SyoSil ApS UVM Scoreboard installed directory. The bash command is printed after uvmgen is successful, and the other shells can be replaced with the corresponding commands.

### Example

Suppose you have a JSON configuration file named testbench_config.json and you want to generate the testbench structure in a directory named tb, you would run the following command:

```bash
uvmgen --input testbench_config.json --output tb
# or
uvmgen -i testbench_config.json -o tb
# or
uvmgen -i testbench_config.json
```

You can use `test/json/example/typical.json` to generate a complete UVM environment, or use `test/json/base_pkg/***.***` to generate a single package.

## sudef - SV File Template Generator

### Overview

sudef is a command-line tool designed to process SystemVerilog (.sv) files that contain mako-style templates in comments. The tool generates code based on the provided templates, supporting both inline code generation and the inclusion of external files. By invoking sudef <svfile>, you can automatically generate the desired SystemVerilog code based on the specified template definitions.

### Usage

The basic usage of sudef is as follows:
```bash
sudef <input>
```
where `<input>` is the path to the SystemVerilog file or directory, and if `<input>` is a directory, sudef will process all .sv files in the directory and subdirectories.
- Inline Mode  
When `super_define()` is called with no arguments, sudef operates in inline mode. In this mode, the generated code is directly inserted into the original .sv file, replacing the template placeholders with the appropriate values.
- External File Mode  
When `super_define()` is called with arguments, sudef enters external file mode. In this mode, the generated code is written to a separate external file. The path and name of the external file are specified as arguments to `super_define()`.
### Experimental Nature
Due to its experimental nature, sudef may contain features that are not yet fully tested. You may encounter unexpected behavior or errors during usage. We encourage you to report any issues or suggested improvements to help us continually improve this program.

### Example

Let's consider a simple example where we have a SystemVerilog file named example.sv that contains a mako template:
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
You can use sudef to generate the code by running:
```bash
sudef example.sv
```
The generated code will be:
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
If you want to generate the code to an external file, you can use super_define() with arguments:
```systemverilog
/* super_define(cfg_inc.svh)
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
This will generate the same code as above but write it to a file named cfg_inc.svh and included by this file.

## Contribute
Contributions are always welcome! Simple fork this repo and submit a pull request.
