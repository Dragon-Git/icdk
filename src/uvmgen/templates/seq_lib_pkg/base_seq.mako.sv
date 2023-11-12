`ifndef BASE_SEQ__SV
`define BASE_SEQ__SV
typedef class TR;
class ${seq_lib_name}_base_seq extends uvm_sequence #(TR);

    `uvm_object_utils(${seq_lib_name}_base_seq)
    function new (string name);
      super.new(name);
    endfunction : new

    virtual task pre_body();
        `define UVM_POST_VERSION_1_1
        var uvm_phase starting_phase = get_starting_phase();
        `endif
        if(starting_phase != null) starting_phase.raise_objection(this, {get_type_name(), "not finished"});
    endtask: pre_body

    virtual task post_body();
        if(starting_phase != null) starting_phase.drop_objection(this, {get_type_name(), "seq finished"});
    endtask: post_body

endclass: ${seq_lib_name}_base_seq
`endif // BASE_SEQ__SV
