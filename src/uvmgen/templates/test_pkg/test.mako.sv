`ifndef ${test_name.upper()}__SV
`define ${test_name.upper()}__SV

typedef class ${env_name};

class ${test_name} extends uvm_test;

  `uvm_component_utils(${test_name})

  ${env_name} env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ${env_name}::type_id::create("env", this);
	INCL_IFTR_START
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.mast_seqr.main_phase",
                    "default_sequence", ${seq_lib_name}::get_type());
	INCL_IFTR_END
	MAST_START 
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.master_agent.mast_sqr.main_phase",
                    "default_sequence", ${seq_lib_name}::get_type()); 
	MAST_END
  endfunction

endclass : ${test_name}

`endif //${test_name.upper()}__SV