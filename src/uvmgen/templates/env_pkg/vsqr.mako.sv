`ifndef ${vsqr_name.upper()}__SV
`define ${vsqr_name.upper()}__SV

class ${vsqr_name} extends uvm_sequencer;
% for child_name, child_type in env_childs.items():
    ${child_type[:-3]}sqr ${child_name[:-3]}sqr;
% endfor
    `uvm_component_utils_begin(${vsqr_name})
% for child_name, child_type in env_childs.items():
        `uvm_field_object(${child_name[:-3]}sqr,UVM_ALL_ON)
% endfor
    //ToDo: add field utils macros here if required
    `uvm_component_utils_end

    `uvm_new_func

endclass
`endif // ${vsqr_name.upper()}__SV