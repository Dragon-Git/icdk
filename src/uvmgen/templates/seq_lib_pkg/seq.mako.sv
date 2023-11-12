`ifndef ${seq_name.upper()}__SV
`define ${seq_name.upper()}__SV

class ${seq_name} extends ${seq_lib_name}_base_seq;
  `uvm_object_utils(${seq_name})
  `uvm_add_to_seq_lib(${seq_name}, ${seq_lib_name})

  function new(string name = ${seq_name});
    super.new(name);
  endfunction: new

  virtual task body();
    repeat(10) begin
      `uvm_do(req);
    end
  endtask: body

endclass
// ${seq_name.upper()}__SV
