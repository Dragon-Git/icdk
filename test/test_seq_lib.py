from uvmgen.uvmgen import uvm_gen

def test_seq_lib():
    uvm_gen().gen("test/json/seq_lib.json")

def test_agt():
    uvm_gen().gen("test/json/agt.json")

def test_env():
    uvm_gen().gen("test/json/env.json")

def test_test():
    uvm_gen().gen("test/json/test.json")

def test_tb():
    uvm_gen().gen("test/json/tb.json")