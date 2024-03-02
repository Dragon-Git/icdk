from pathlib import Path
import re
import fire
from mako.template import Template


def super_define(sv_file):
    with open(sv_file, "r") as file:
        content = file.read()
    pattern = r"""\/\* super_define\((?:.*)\).*\*\/"""
    matches = re.findall(pattern, content, re.DOTALL)

    if matches:
        for match in matches:
            lines = match.split("\n")
            result = re.match(r".*\((.*)\).*", lines[0])
            lines = lines[1:-1]
            t = Template("\n".join(lines))
            generated_code = t.render() if not result.group(1) else f'`include "{result.group(1)}"\n'
            new_string = f"{match}\n// super_define generate begin\n{generated_code}// super_define generate end"
            pattern = r"""\/\* super_define\(.*\).*super_define generate end|\/\* super_define\(.*\).*\*\/"""
            content = re.sub(pattern, new_string, content, 1, re.DOTALL)

            if result.group(1):
                inc_file = Path(sv_file).parent.joinpath(result.group(1))
                with open(inc_file, "w") as f_inc, open(sv_file, "w") as f_src:
                    f_inc.write(t.render())
                    f_src.write(content)
                print(f"super_define generate in '{inc_file}'.")
            else:
                with open(sv_file, "w") as file:
                    file.write(content)
                print(f"super_define generate in '{sv_file}'.")
    else:
        print(f"Pattern '{pattern}' not found in file '{sv_file}'.")


def main():
    fire.Fire(super_define)


if __name__ == "__main__":
    main()
