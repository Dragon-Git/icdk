`ifndef ${agent_name.upper()}_SQR__SV
`define ${agent_name.upper()}_SQR__SV

typedef class ${agent_name}_tr;
% if (drv_type == "pull") :
class ${agent_name}_sqr extends uvm_sequencer # (${agent_name}_tr);
% else: ## (drv_type == "push")
class ${agent_name}_sqr extends uvm_push_sequencer # (${agent_name}_tr);
% endif

   `uvm_component_utils(${agent_name}_sqr)
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction:new

endclass:${agent_name}_sqr

`endif // ${agent_name.upper()}_SQR__SV
