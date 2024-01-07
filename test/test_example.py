import pytest
from pathlib import Path
from uvmgen.uvmgen import UVMGen

base_json_paths = Path(__file__).parent.joinpath("json/example").iterdir()


@pytest.mark.parametrize("jsonpath", base_json_paths)
def test_single_pkg(jsonpath):
    UVMGen().gen(jsonpath, "tb/example_tb")
