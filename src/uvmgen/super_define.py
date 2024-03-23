from pathlib import Path
import re
import fire
from mako.template import Template


def super_define(input: str):
    """
    Processes a given SystemVerilog file or directory by parsing and replacing specific comment templates to generate code.

    Args:
        input (str): The path of the file or directory.

    """
    input = Path(input)
    if input.is_dir():  # If the input is a directory
        for sv_file in input.glob("**/*.sv*"):  # Recursively searches all .sv files within the directory tree
            if sv_file.is_file():
                process_file(sv_file)  # Process each individual file
    else:
        process_file(input)  # If the input is a file, directly process it


def process_file(sv_file: Path):
    """
    Processes a single SystemVerilog file by finding and replacing templates within specific comments to generate new code.

    Args:
        sv_file: The path to the SystemVerilog file being processed.

    """
    with open(sv_file, "r") as file:
        content = file.read()
    # Define the pattern to match the specific comment block
    pattern = r"/\* super_define\((?:[^\*/]*)\)((?!super_define generate end).)*super_define generate end|/\* super_define\((?:[^\*/]*)\)[^\*/]*\*/"

    def render(matched):
        lines = matched.group().split("\n")
        args = re.match(r".*super_define\((.*)\).*", lines[0])
        tpl = re.match(r"([^\*/]*)\*/", "\n".join(lines[1:])).group(1)
        t = Template(tpl)
        generated_code = t.render()

        if args.group(1):
            inc_file = sv_file.parent.joinpath(args.group(1))
            inc_file.write_text(generated_code)
            generated_code = f'`include "{args.group(1)}"\n'
            print(f"super_define generated in '{inc_file}'.")

        return f"{lines[0]}\n{tpl}*/\n// super_define generate begin\n{generated_code}// super_define generate end"

    content = re.sub(pattern, render, content, flags=re.DOTALL)
    sv_file.write_text(content)
    print(f"super_define generated in '{sv_file}'.")


def main():
    """
    Entry point for command-line execution.
    """
    fire.Fire(super_define)


if __name__ == "__main__":
    main()
