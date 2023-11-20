<%block name="main">\
`ifndef ${agent_name.upper()}_COV__SV
`define ${agent_name.upper()}_COV__SV

class ${agent_name}_cov extends uvm_component;
   event cov_event;
   ${agent_name}_item tr;
% if (mon2cov_con_approach == "analysis_port") :
   uvm_analysis_imp #(${agent_name}_item, ${agent_name}_cov) cov_export;
% endif
   `uvm_component_utils(${agent_name}_cov)
 
   covergroup cg_trans @(cov_event);
      // ToDo: coverpoint tr.kind;
      // ToDo: Add required ${agent_name}_coverpoints, ${agent_name}_coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
% if (mon2cov_con_approach == "analysis_port") :
      cov_export = new("${agent_name}_coverage_Analysis",this);
% endif
   endfunction: new
% if (mon2cov_con_approach == "analysis_port") :
   virtual function write(${agent_name}_item tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write
% endif

endclass: ${agent_name}_cov

`endif // ${agent_name.upper()}_COV__SV
</%block>