#!/usr/bin/env python3
import fire
import json
from pathlib import Path

from mako.lookup import TemplateLookup

class uvm_gen():
    """ """
    def __init__(self, template_path = ""):
        template_path = template_path or Path(__file__).parent / "templates"
        self.template_paths = [template_path] + list(template_path.iterdir())

    def get_output_name(self, tpl, pkg_name, pkg_type):
        if tpl.parent.name != "tb_lib":
            prefix = pkg_name.replace(pkg_type, "")
        else:
            prefix = ""
        output_name = prefix + tpl.name.replace("mako", "gen")
        return output_name

    def serve_template(self, template_name, output_name, data):
        lookup = TemplateLookup(
            directories=self.template_paths, 
            module_directory='/tmp/mako_modules', 
            preprocessor=[lambda x: x.replace('\r\n', '\n')]
            )
        tpl = lookup.get_template(template_name)
        self.output_path.mkdir(parents=True, exist_ok=True)
        data["vars"]["files"] = self.output_path.iterdir()
        Path(self.output_path / output_name).write_text(tpl.render(**data["vars"]))
        print("*** Generate Target File < " + output_name + " > is Done!")

    def gen(self, input, output = "tb"):
        self.data = json.load(open(input))
        for k,v in self.data.items():
            pkg_tpl_path = Path(self.template_paths[0]) / v["type"]
            self.output_path = Path(output) / k
            pkg_tpls = list(pkg_tpl_path.iterdir())
            pkg_tpls.sort(key=lambda x: "pkg" in x.name)
            for tpl in pkg_tpls:
                output_name = self.get_output_name(tpl, k ,v["type"])
                self.serve_template(tpl.name, output_name, v)

def main():
    fire.Fire(uvm_gen().gen)
    
if __name__ == "__main__":
    main()