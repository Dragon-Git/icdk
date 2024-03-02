import filecmp
from pathlib import Path
from uvmgen.super_define import super_define

base_json_paths = Path(__file__).parent.joinpath("json/base_pkg").iterdir()


def test_super_define_inline():
    test_file = Path(__file__).parent.joinpath("super_define_data/sudef_inline.sv")
    exp_file = Path(__file__).parent.joinpath("super_define_data/sudef_inline_exp.sv")
    super_define(test_file)
    assert filecmp.cmp(test_file, exp_file)


def test_super_define_inc():
    test_file = Path(__file__).parent.joinpath("super_define_data/sudef_inc.sv")
    exp_file = Path(__file__).parent.joinpath("super_define_data/sudef_inc_exp.sv")
    inc_file = Path(__file__).parent.joinpath("super_define_data/cfg_inc.svh")
    inc_exp_file = Path(__file__).parent.joinpath("super_define_data/cfg_inc_exp.svh")
    super_define(test_file)
    assert filecmp.cmp(test_file, exp_file)
    assert filecmp.cmp(inc_file, inc_exp_file)
