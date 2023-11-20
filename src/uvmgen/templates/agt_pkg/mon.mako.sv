<%block name="main">\
<%
# Which approach would you like to use for monitor's connection with observers(scoreboard,coverage etc.)?
#     1) Callbacks approach ;
#     2) Analysis port usage in monitor
%>\
`ifndef ${agent_name.upper()}_MON__SV
`define ${agent_name.upper()}_MON__SV

typedef class ${agent_name}_item;
typedef class ${agent_name}_mon;

class ${agent_name}_mon_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use a task if callbacks can be blocking


   // Called at start of observed transaction
   virtual function void pre_trans(${agent_name}_mon xactor,
                                   ${agent_name}_item tr);
   endfunction: pre_trans


   // Called before acknowledging a transaction
   virtual function pre_ack(${agent_name}_mon xactor,
                            ${agent_name}_item tr);
   endfunction: pre_ack
   

   // Called at end of observed transaction
   virtual function void post_trans(${agent_name}_mon xactor,
                                    ${agent_name}_item tr);
   endfunction: post_trans

   
   // Callback method post_cb_trans can be used for coverage
   virtual task post_cb_trans(${agent_name}_mon xactor,
                              ${agent_name}_item tr);
   endtask: post_cb_trans

endclass: ${agent_name}_mon_callbacks

   

class ${agent_name}_mon extends uvm_monitor;

% if (mon2cov_con_approach == "analysis_port") :
   uvm_analysis_port #(${agent_name}_item) mon_analysis_port;  //TLM analysis port
% endif
   typedef virtual ${agent_name}_if v_if;
   v_if mon_if;
   // ToDo: Add another class property if required
   extern function new(string name = "${agent_name}_mon",uvm_component parent);
   // factory
   `uvm_component_utils(${agent_name}_mon)
   // callbacks                  
   `uvm_register_cb(${agent_name}_mon,${agent_name}_mon_callbacks);

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task tx_monitor();

endclass: ${agent_name}_mon


function ${agent_name}_mon::new(string name = "${agent_name}_mon",uvm_component parent);
   super.new(name, parent);
% if (mon2cov_con_approach == "analysis_port") :
   mon_analysis_port = new ("mon_analysis_port",this);
% endif
endfunction: new

function void ${agent_name}_mon::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void ${agent_name}_mon::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "mon_if", mon_if);
endfunction: connect_phase

function void ${agent_name}_mon::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase); 
   //ToDo: Implement this phase here

endfunction: end_of_elaboration_phase


function void ${agent_name}_mon::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here

endfunction: start_of_simulation_phase


task ${agent_name}_mon::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   phase.raise_objection(this,"");
   // ToDo: Implement reset here
   phase.drop_objection(this);

endtask: reset_phase


task ${agent_name}_mon::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Configure your component here
   phase.drop_objection(this);

endtask:configure_phase


task ${agent_name}_mon::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork
      tx_monitor();
   join

endtask: run_phase


task ${agent_name}_mon::tx_monitor();
   forever begin
      ${agent_name}_item tr;
      // ToDo: Wait for start of transaction

      `uvm_do_callbacks(${agent_name}_mon,${agent_name}_mon_callbacks, pre_trans(this, tr))
      `uvm_info("TX_MONITOR", "Starting transaction...",UVM_LOW)
      // ToDo: Observe first half of transaction

      // ToDo: User need to add monitoring logic and remove #10
      `uvm_info("TX_MONITOR"," User need to add monitoring logic ",UVM_LOW)
	   #10; // For test to avoid zero-delay-loop
      `uvm_do_callbacks(${agent_name}_mon,${agent_name}_mon_callbacks, pre_ack(this, tr))
      // ToDo: React to observed transaction with ACK/NAK
      `uvm_info("TX_MONITOR", "Completed transaction...",UVM_HIGH)
      `uvm_info("TX_MONITOR", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(${agent_name}_mon,${agent_name}_mon_callbacks, post_trans(this, tr))
% if (mon2cov_con_approach == "analysis_port") :
      mon_analysis_port.write(tr);
% endif
   end
endtask: tx_monitor

`endif // ${agent_name}_MON__SV
</%block>