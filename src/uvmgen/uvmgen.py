"""UVM testbench framework generation library.

Implements the :class:`UVMGen` class, which reads a configuration file
(JSON/YAML/TOML/XML) and produces a full UVM testbench directory tree
rendered from a configurable Mako template set.

.. warning::
   Templates are rendered with the full power of the Python interpreter via
   Mako. Do not render configurations or templates from untrusted sources.
"""

import sys
import tempfile
from pathlib import Path
from typing import IO, Any, Union, cast

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

import json

import fire
import xmltodict
import yaml
from mako.lookup import TemplateLookup

PathLike = Union[str, Path]


def _load_file_data_json(fin: IO[bytes]) -> Any:
    """Load data in JSON format.

    Args:
        fin: Binary file-like object opened in read mode.

    Returns:
        Parsed JSON data (dict, list, or scalar).
    """
    return json.load(fin)


def _load_file_data_xml(fin: IO[bytes]) -> Any:
    """Load data in XML format.

    Args:
        fin: Binary file-like object opened in read mode.

    Returns:
        Parsed XML data as an ordered dict.
    """
    return xmltodict.parse(fin.read())


def _load_file_data_yaml(fin: IO[bytes]) -> Any:
    """Load data in YAML format.

    Args:
        fin: Binary file-like object opened in read mode.

    Returns:
        Parsed YAML data.
    """
    return yaml.safe_load(fin)


def _load_file_data_toml(fin: IO[bytes]) -> Any:
    """Load data in TOML format.

    Args:
        fin: Binary file-like object opened in read mode.

    Returns:
        Parsed TOML data as a dict.
    """
    return tomllib.load(fin)


class UVMGen:
    """UVM testbench framework generator."""

    def __init__(self, template_path: PathLike = ""):
        """Initialize the generator with a template directory.

        Args:
            template_path: Path to the templates directory. If empty, the
                bundled ``templates/`` directory next to this module is used.
        """
        template_path = Path(template_path) if template_path else Path(__file__).parent / "templates"
        self.template_paths: list[Path] = [template_path, *template_path.iterdir()]

    def get_output_name(self, tpl: Path, pkg_name: str, pkg_type: str) -> str:
        """Compute the target file name for a rendered template.

        Args:
            tpl: Template file path.
            pkg_name: Name of the package being generated.
            pkg_type: Package type identifier (e.g. ``"env"``, ``"pkg"``).

        Returns:
            The output file name with ``gen`` suffix.
        """
        prefix = pkg_name.replace(pkg_type, "") if tpl.parent.name != "tb_lib" else ""
        return prefix + tpl.name.replace("mako", "gen")

    def serve_template(self, template_name: str, output_name: str, data: dict[str, Any]) -> None:
        """Render a single template and write the result to disk.

        Args:
            template_name: Name of the template file (relative to any of ``template_paths``).
            output_name: Output file name (written under ``self.output_path``).
            data: Render context, expected to contain a ``"vars"`` sub-dict.
        """
        lookup = TemplateLookup(
            directories=self.template_paths,
            module_directory=Path(tempfile.gettempdir()) / "mako_modules",
            preprocessor=[lambda x: x.replace("\r\n", "\n")],
        )
        tpl = lookup.get_template(template_name)
        self.output_path.mkdir(parents=True, exist_ok=True)
        data["vars"]["files"] = list(self.output_path.iterdir())
        Path(self.output_path / output_name).write_text(tpl.render(**data["vars"]))
        print("*** Generate Target File < " + output_name + " > is Done!")

    def load_data(self, input_path: PathLike) -> Any:
        """Load configuration data from a JSON/XML/YAML/TOML file.

        Args:
            input_path: Path to the configuration file.

        Returns:
            Parsed configuration data.

        Raises:
            ValueError: If the file suffix is not a supported format.
        """
        load_func = {
            ".json": _load_file_data_json,
            ".xml": _load_file_data_xml,
            ".yaml": _load_file_data_yaml,
            ".toml": _load_file_data_toml,
        }

        input_path = Path(input_path)
        suffix = input_path.suffix
        if suffix not in load_func:
            raise ValueError(f"Unsupported file format '{suffix}'. Supported: {', '.join(sorted(load_func))}")
        with open(input_path, "rb") as f:
            return load_func[suffix](f)

    def gen(self, input: PathLike, output: PathLike = "tb") -> None:  # noqa: A002  # match CLI naming
        """Generate a testbench framework from a configuration file.

        For each package defined in the configuration the method iterates the
        matching template directory and renders every template, with ``pkg``
        files sorted last so they can reference previously generated content.

        Args:
            input: Configuration file path (JSON/XML/YAML/TOML) describing the
                testbench structure.
            output: Root directory where the generated output is placed. Each
                package is written to a sub-directory named after the package.
        """
        data: dict[str, Any] = self.load_data(input)
        for k, v in data.items():
            pkg_tpl_path = Path(self.template_paths[0]) / v["type"]
            self.output_path = Path(output) / k
            pkg_tpls = sorted(pkg_tpl_path.iterdir(), key=lambda x: "pkg" in x.name)
            for tpl in pkg_tpls:
                output_name = self.get_output_name(tpl, k, v["type"])
                self.serve_template(tpl.name, output_name, cast(dict[str, Any], v))
        print("Success! If pk_syoscb pkg is used, set the following environment variables:\n")
        print(f"export SYOSCB_HOME={Path(__file__).parent / 'uvm_syoscb'}")
        print(f"export TB_PATH={Path(output)}")


def main() -> None:
    """CLI entry point for ``uvmgen``."""
    fire.Fire(UVMGen().gen)


if __name__ == "__main__":
    main()
