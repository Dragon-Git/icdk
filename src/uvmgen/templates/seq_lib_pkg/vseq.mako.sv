`ifndef ${vseq_name.upper()}__SV
`define ${vseq_name.upper()}__SV

typedef class ${seq_lib_name};
class ${vseq_name} extends ${seq_lib_name}_base_seq;
  `uvm_object_utils(${vseq_name})
  `uvm_declare_p_sequencer(${vsqr_name})

  function new(string name = "${vseq_name}");
    super.new(name);
  endfunction: new

  virtual task body();
    ${seq_lib_name} m_${seq_lib_name} = ${seq_lib_name}::type_id::create("m_${seq_lib_name}");
    m_${seq_lib_name}.start(p_sequencer.m_${seq_lib_name.replace("seq_lib", "sqr")});
  endtask: body

endclass
`endif // ${seq_name.upper()}__SV
