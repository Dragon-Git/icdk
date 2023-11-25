import pytest
from pathlib import Path
from uvmgen.uvmgen import uvm_gen

base_json_paths = Path(__file__).parent.joinpath('json/example').iterdir()
@pytest.mark.parametrize("jsonpath", base_json_paths) 
def test_agt(jsonpath):
    uvm_gen().gen(jsonpath, "tb/example_tb")
