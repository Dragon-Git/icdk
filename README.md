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

uvmgen is a command-line interface (CLI) program for generating testbench structures based on a provided JSON/YAML/TOML/XML configuration file. 

## Installing
<details>
  <summary>Prerequisites</summary>

- Operating systems
  - Windows
  - Linux
  - macOS
- Python: 3.6 ~ 3.12
</details>

Use Python's package installer pip to install uvmgen:
```bash
python3 -m pip install uvmgen 
```

## Usage

The basic usage of uvmgen is as follows:
```bash
uvmgen --input <input_json_file> --output <output_directory>
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

## Example

Suppose you have a JSON configuration file named testbench_config.json and you want to generate the testbench structure in a directory named tb, you would run the following command:

```bash
uvmgen --input testbench_config.json --output tb
# or
uvmgen -i testbench_config.json -o tb
# or
uvmgen -i testbench_config.json
```

You can use `test/json/example/typical.json` to generate a complete UVM environment, or use `test/json/base_pkg/***.***` to generate a single package.

## Contribute
Contributions are always welcome! Simple fork this repo and submit a pull request.
