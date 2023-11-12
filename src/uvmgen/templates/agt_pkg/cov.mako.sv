<%block name="main">\
<%
# Which approach would you like to use for monitor's connection with observers(scoreboard,coverage etc.)?
#     1) Callbacks approach ;
#     2) Analysis port usage in monitor
self.mon2cov_con_approach = "callback"
%>\

`ifndef ${agent_name.upper()}_COV__SV
`define ${agent_name.upper()}_COV__SV

class ${agent_name}_cov extends uvm_component;
   event ${agent_name}_cov_event;
   ${agent_name}_tr tr;
% if (self.mon2cov_con_approach == "analysis_port") :
   uvm_analysis_imp #(${agent_name}_tr, ${agent_name}_cov) ${agent_name}_cov_export;
% endif
   `uvm_component_utils(${agent_name}_cov)
 
   ${agent_name}_covergroup cg_trans @(${agent_name}_cov_event);
      ${agent_name}_coverpoint tr.kind;
      // ToDo: Add required ${agent_name}_coverpoints, ${agent_name}_coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
% if (self.mon2cov_con_approach == "analysis_port") :
      ${agent_name}_cov_export = new("${agent_name}_coverage_Analysis",this);
% endif
   endfunction: new
% if (self.mon2cov_con_approach == "analysis_port") :
   virtual function write(TR tr);
      this.tr = tr;
      -> ${agent_name}_cov_event;
   endfunction: write
% endif

endclass: ${agent_name}_cov

`endif // ${agent_name.upper()}_COV__SV
</%block>