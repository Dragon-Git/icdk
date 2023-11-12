from uvmgen.uvmgen import uvm_gen

def test_seq_lib():
    uvm_gen().gen("seq_lib_pkg", "test/json/seq_lib.json")

def test_agt():
    uvm_gen().gen("agt_pkg", "test/json/agt.json")

def test_env():
    uvm_gen().gen("env_pkg", "test/json/env.json")

def test_test():
    uvm_gen().gen("test_pkg", "test/json/test.json")

def test_tb():
    uvm_gen().gen("tb_lib", "test/json/tb.json")