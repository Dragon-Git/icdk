`ifndef ${agent_name.upper()}_CFG__SV
`define ${agent_name.upper()}_CFG__SV

class ${agent_name}_cfg extends uvm_object; 

   // agent cfg knobs
   bit         is_active = 1'b1;   // active driver/sequencer or passive monitor
   bit         en_cov    = 1'b1;   // enable coverage
   // if_mode_e   if_mode;            // interface mode - Host or Device
   // Define test configuration parameters (e.g. how long to run)
   rand int num_trans;
   rand int num_scen;
   // ToDo: Add other environment configuration varaibles

   constraint cst_num_trans_default {
      num_trans inside {[1:7]};
   }
   constraint cst_num_scen_default {
      num_scen inside {[1:2]};
   }
   // ToDo: Add constraint blocks to prevent error injection


   `uvm_object_utils_begin(${agent_name}_cfg)
      `uvm_field_int(num_trans,UVM_ALL_ON) 
      `uvm_field_int(num_scen,UVM_ALL_ON)
      `uvm_field_int(is_active,UVM_ALL_ON)
      `uvm_field_int(en_cov,UVM_ALL_ON)
      // `uvm_field_int(if_mode,UVM_ALL_ON)
      // ToDo: add properties using macros here

   `uvm_object_utils_end

   function new(string name = "");
      super.new(name);
   endfunction: new

endclass: ${agent_name}_cfg

`endif // ${agent_name.upper()}_CFG__SV
