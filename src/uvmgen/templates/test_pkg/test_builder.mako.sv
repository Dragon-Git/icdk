`ifndef TEST_BUILDER__SV
`define TEST_BUILDER__SV
class run_seq_test #(type T = uvm_test) extends T;

  local const uvm_object_wrapper seq_wrapper;

  function new(string name, uvm_component parent, uvm_object_wrapper seq_wrapper);
    super.new(name, parent);
    this.seq_wrapper = seq_wrapper;
  endfunction

  virtual function string get_type_name();
    // `get_type_name()` gets called through the base class' constructor, before `seq_wrapper`
    // has been set. In some simulators, the overloaded version of `get_type_name()` (i.e. this
    // function) gets called, not the version present in the class where it's called from.
    if (seq_wrapper == null)
      return super.get_type_name();

    return $sformatf("%s__%s", super.get_type_name(), seq_wrapper.get_type_name());
  endfunction

  virtual task run_phase(uvm_phase phase);
    uvm_sequence seq = create_seq();
    phase.raise_objection(this);
    seq.start(null);
    phase.drop_objection(this);
  endtask

  local function uvm_sequence create_seq();
    uvm_sequence result;
    if (!$cast(result, seq_wrapper.create_object("seq")))
      `uvm_fatal("TEST", "Cannot construct sequence from supplied wrapper")
    return result;
  endfunction

endclass

class test_wrapper #(type T = uvm_test) extends uvm_object_wrapper;

  local const uvm_object_wrapper seq_wrapper;

  function new(uvm_object_wrapper seq_wrapper);
    this.seq_wrapper = seq_wrapper;
  endfunction

  virtual function string get_type_name();
    string test_name;
    string test_full_name = $typename(T);
    int start_idx;
    int end_idx;

    // serach "."
    for(int i=0; i<test_full_name.len(); i++) begin
      if (test_full_name.substr(i, i) == ".") begin
        start_idx = i + 1;
        break;
      end
    end
    // serach " "                                                                                                              
    for(int i=start_idx; i<test_full_name.len(); i++) begin                                                                                       
      if (test_full_name.substr(i, i) == " ") begin                                                                                                              
        end_idx = i - 1;                                                                                                     
        break;                                                                                                                 
      end                                                                                                                      
    end
    if (end_idx < start_idx) end_idx = test_full_name.len() - 1;
    if (end_idx > start_idx) begin
      test_name = test_full_name.substr(start_idx, end_idx);
    end else begin
      test_name = "<error>";
      `uvm_fatal("TEST_WRAPPER", "Cannot get test type name")
    end                                                                                                                    

    return $sformatf("%s__%s", test_name, seq_wrapper.get_type_name());
  endfunction

  virtual function uvm_component create_component(string name, uvm_component parent);
    run_seq_test #(T) result = new(name, parent, seq_wrapper);
    return result;
  endfunction

endclass

class test_builder #(type T = uvm_test);

  local static test_wrapper #(T) m_test_wrapper;

  local function new(uvm_object_wrapper seq_wrapper);
    m_test_wrapper = new(seq_wrapper);
  endfunction

  static function test_builder #(T) get(uvm_object_wrapper seq_wrapper);
    test_builder #(T) result = new(seq_wrapper);
    return result;
  endfunction

  function bit register();
    uvm_coreservice_t cs = uvm_coreservice_t::get();
  	uvm_factory factory = cs.get_factory();
    factory.register(m_test_wrapper);
    return 1;
  endfunction

endclass

/* usage: If you want to run a sequence in run_phase of a test extends from my_test, you can do this:
`CREATE_TEST_BEGIN(my_test)
  `ADD_SEQ(my_sequence)
  `ADD_SEQ(another_sequence)
`CREATE_TEST_END(my_test)
The plusargs is +UVM_TESTNAME=seq_name_test, eg: my_sequence_test and another_sequence_test in this example.
*/
`define CREATE_TEST_BEGIN(TEST=uvm_test) \
class run_each_seq_on_``TEST; \
  typedef TEST test_type;\
  local static bit tests_registered = register_tests(); \
  local static function bit register_tests(); \
    uvm_object_wrapper seqs[] = '{
`define ADD_SEQ(SEQ) SEQ::get_type(),
`define CREATE_TEST_END \
        uvm_sequence #(uvm_sequence_item)::get_type()}; \
    foreach (seqs[i]) \
      void'(test_builder #(test_type)::get(seqs[i]).register()); \
  endfunction \
endclass

`endif //TEST_BUILDER__SV
