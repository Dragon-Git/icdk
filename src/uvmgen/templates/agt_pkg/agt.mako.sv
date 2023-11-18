<%block name="main">\
`ifndef ${agent_name.upper()}_AGT__SV
`define ${agent_name.upper()}_AGT__SV

class ${agent_name}_agt extends uvm_agent;
   // ToDo: add sub environmnet properties here
   protected uvm_active_passive_enum is_active = UVM_ACTIVE;
   ${agent_name}_sqr sqr;
   ${agent_name}_drv drv;
   ${agent_name}_mon mon;
   ${agent_name}_if agt_if;
   typedef virtual ${agent_name}_if vif;
% if registry_fields:
   `uvm_component_utils_begin(${agent_name}_agt)
   //ToDo: add field utils macros here if required
   `uvm_component_utils_end

      // ToDo: Add required short hand override method
% else:
   `uvm_component_utils(${agent_name}_agt)
% endif

   function new(string name = "${agent_name}_agt", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = ${agent_name}_mon::type_id::create("mon", this);
      if (is_active == UVM_ACTIVE) begin
         sqr = ${agent_name}_sqr::type_id::create("sqr", this);
         drv = ${agent_name}_drv::type_id::create("drv", this);
      end
      if (!uvm_config_db#(vif)::get(this, "", "if", agt_if)) begin
         `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
      end
      uvm_config_db# (vif)::set(this,"drv","vif",drv.drv_if);
      uvm_config_db# (vif)::set(this,"mon","vif",mon.mon_if);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (is_active == UVM_ACTIVE) begin
% if (drv_type == "pull") :
         drv.seq_item_port.connect(sqr.seq_item_export);
% else: ## (drv_type == "push")
         sqr.req_port.connect(drv.req_export);
% endif
      end
   endfunction: connect_phase


   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this,"slv_agt_run");

      //ToDo :: Implement here

      phase.drop_objection(this);
   endtask: run_phase

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      //ToDo :: Implement here

   endfunction: report_phase

endclass:${agent_name}_agt

`endif // ${agent_name.upper()}_AGT__SV
</%block>