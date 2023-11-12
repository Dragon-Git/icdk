#!/usr/bin/env python3
import fire
import json
from pathlib import Path

from mako.lookup import TemplateLookup

class uvm_gen():
    """ """
    def __init__(self, template_file = "templates"):
        template_file = Path(__file__).parent / "templates"
        self.template_paths = [template_file, ]

    def get_output_name(self, tpl):
        # output_name = self.data["vars"][tpl.stem.replace(".mako", "_name")] + ".gen.sv"
        output_name = tpl.name.replace("mako", "gen")
        return output_name

    def serve_template(self, template_name, output_name, data):
        lookup = TemplateLookup(directories=self.template_paths, module_directory='/tmp/mako_modules')
        tpl = lookup.get_template(template_name)
        self.output_path.mkdir(parents=True, exist_ok=True)
        self.data["vars"]["files"] = list(self.output_path.iterdir())
        print(self.data)
        Path(self.output_path / output_name).write_text(tpl.render(**data["vars"]))
        print("*** Generate Target File < " + output_name + " > is Done!")

    def gen(self, pkg, input, output = "tb"):
        self.data = json.load(open(input))
        pkg_tpl_path = Path(self.template_paths[0]) / pkg
        self.template_paths.append(pkg_tpl_path)
        self.output_path = Path(output) / self.data["vars"]["pkg_name"]
        for tpl in pkg_tpl_path.iterdir():
            output_name = self.get_output_name(tpl)
            self.serve_template(tpl.name, output_name, self.data)

def main():
    fire.Fire(uvm_gen())
    
if __name__ == "__main__":
    main()