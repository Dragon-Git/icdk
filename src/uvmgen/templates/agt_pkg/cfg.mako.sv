`ifndef ${agent_name.upper()}_CFG__SV
`define ${agent_name.upper()}_CFG__SV

class ${agent_name}_cfg extends uvm_object; 

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
      // ToDo: add properties using macros here

   `uvm_object_utils_end
   `uvm_object_utils(${agent_name}_cfg)

   extern function new(string name = "");
   extern virtual function void do_print(uvm_printer printer);
   extern virtual function void do_copy(uvm_object rhs = null);
  
endclass: ${agent_name}_cfg

function ${agent_name}_cfg::new(string name = "");
   super.new(name);
endfunction: new

function void ${agent_name}_cfg::do_print(uvm_printer printer);
   super.do_print(printer);
   printer.print_string ("PRINT",{ $psprintf("\t************** CFG ***************\n"),
                 $psprintf("\tnum_trans  : %0d\n", num_trans),
                 $psprintf("\t**********************************\n")
               },".");
   //ToDo: Add another class properties to do_print if added later.

endfunction: do_print

function void ${agent_name}_cfg::do_copy(uvm_object rhs = null);
   TR to;
    super.do_copy(rhs);
    $cast(to,rhs);

   // ToDo: Copy additional class properties

endfunction: do_copy

`endif // ${agent_name.upper()}_CFG__SV
