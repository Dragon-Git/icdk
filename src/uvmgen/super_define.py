"""``super_define`` source-to-source expansion for SystemVerilog.

Exposes a CLI entry point (``sudef``) that scans ``.sv`` / ``.svh`` files for
``/* super_define(ARGS) TEMPLATE */`` comment blocks and replaces them with
the rendered Mako template.

.. warning::
   Templates are executed with full Python privileges by Mako. Only process
   files from trusted sources.
"""

import re
from pathlib import Path
from re import Match

import fire
from mako.template import Template


def super_define(input: str) -> None:
    """Process a SystemVerilog file or directory, expanding ``super_define`` templates.

    When a directory is provided the method recursively finds all ``.sv`` and
    ``.svh`` files and processes each one.

    Args:
        input: File or directory path.
    """
    root = Path(input)
    if root.is_dir():
        for sv_file in root.glob("**/*.sv*"):
            if sv_file.is_file():
                process_file(sv_file)
    else:
        process_file(root)


def process_file(sv_file: Path) -> None:
    """Process a single SystemVerilog file in-place.

    The method finds specially marked ``/* super_define(...) ... */`` comment
    blocks and uses Mako to render their body. When the ``super_define`` call
    includes an argument the rendered content is written to a separate include
    file and the original location is replaced with a `` `include`` directive.

    Args:
        sv_file: Path to the SystemVerilog file.
    """
    content = sv_file.read_text()
    # Two alternations:
    #   1. /* super_define(ARGS) ... super_define generate end    (legacy block mode)
    #   2. /* super_define(ARGS) ... */                           (single comment)
    pattern = (
        r"/\* super_define\((?:[^\*/]*)\)((?!super_define generate end).)*super_define generate end"
        r"|/\* super_define\((?:[^\*/]*)\)[^\*/]*\*/"
    )

    def render(matched: Match[str]) -> str:
        lines = matched.group().split("\n")
        header_match = re.match(r".*super_define\((.*)\).*", lines[0])
        if header_match is None:
            return matched.group()
        args_group = header_match.group(1)

        body_match = re.match(r"([^\*/]*)\*/", "\n".join(lines[1:]))
        if body_match is None:
            return matched.group()
        tpl_text = body_match.group(1)

        t = Template(tpl_text)
        generated_code = t.render()

        if args_group:
            inc_file = sv_file.parent / args_group
            inc_file.write_text(generated_code)
            generated_code = f'`include "{args_group}"\n'
            print(f"super_define generated in '{inc_file}'.")

        return (
            f"{lines[0]}\n{tpl_text}*/\n"
            f"// super_define generate begin\n"
            f"{generated_code}"
            f"// super_define generate end"
        )

    sv_file.write_text(re.sub(pattern, render, content, flags=re.DOTALL))
    print(f"super_define generated in '{sv_file}'.")


def main() -> None:
    """CLI entry point for ``sudef``."""
    fire.Fire(super_define)


if __name__ == "__main__":
    main()
