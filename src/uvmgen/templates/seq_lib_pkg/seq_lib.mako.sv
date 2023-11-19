`ifndef ${seq_lib_name.upper()}__SV
`define ${seq_lib_name.upper()}__SV

class ${seq_lib_name} extends uvm_sequence_library #(uvm_sequence_item);
  
  `uvm_object_utils(${seq_lib_name})
  `uvm_sequence_library_utils(${seq_lib_name})

  function new(string name = "${seq_lib_name}");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

`endif // ${seq_lib_name.upper()}__SV
