`ifndef ${agent_name.upper()}_DRV__SV
`define ${agent_name.upper()}_DRV__SV

typedef class ${agent_name}_item;
typedef class ${agent_name}_drv;

class ${agent_name}_drv_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( ${agent_name}_drv xactor,
                        ${agent_name}_item tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( ${agent_name}_drv xactor,
                         ${agent_name}_item tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: ${agent_name}_drv_callbacks


% if (drv_type == "pull") :
class ${agent_name}_drv extends uvm_driver # (${agent_name}_item);
% else: ## (drv_type == "push")
class ${agent_name}_drv extends uvm_push_driver # (${agent_name}_item);
% endif

% if (drv_export_type == "block"):
   uvm_tlm_b_transport_export #(${agent_name}_item) drv_b_export;    //Uni directional blocking
% endif
% if (drv_export_type == "nonblock"):
   uvm_tlm_nb_transport_fw_export #(${agent_name}_item) drv_nb_export;  //Uni directional non-blocking
% endif
   typedef virtual ${agent_name}_if v_if; 
   v_if drv_if;
   // factory
   `uvm_component_utils(${agent_name}_drv)
   // callbacks
   `uvm_register_cb(${agent_name}_drv,${agent_name}_drv_callbacks); 
   
   extern function new(string name = "${agent_name}_drv",
                       uvm_component parent = null); 

   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(${agent_name}_item tr); 
% if (drv_type == "push") :
   extern virtual task put(${agent_name}_item item); 
% endif
   extern protected virtual task tx_driver();

endclass: ${agent_name}_drv


function ${agent_name}_drv::new(string name = "${agent_name}_drv",
                   uvm_component parent = null);
   super.new(name, parent);

% if (drv_export_type == "block"):
   // drv_b_export = new("Driver blocking export",this);
   // ToDo: Create this port whenever it is needed
% endif
% if (drv_export_type == "nonblock"):
   //drv_nb_export = new("Driver non-blocking export",this);
   // ToDo: Create this port whenever it is needed
% endif
   
endfunction: new

function void ${agent_name}_drv::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void ${agent_name}_drv::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //INCL_IFTR_START
   uvm_config_db#(v_if)::get(this, "", "drv_if", drv_if);
   //INCL_IFTR_END
   //MST_CODE_EN_START
   uvm_config_db#(v_if)::get(this, "", "mst_if", drv_if);
   //MST_CODE_EN_END
   //SLV_CODE_EN_START
   uvm_config_db#(v_if)::get(this, "", "slv_if", drv_if);
   //SLV_CODE_EN_END
endfunction: connect_phase

function void ${agent_name}_drv::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void ${agent_name}_drv::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

 
task ${agent_name}_drv::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   phase.raise_objection(this,"");
   // ToDo: Reset output signals
   phase.drop_objection(this);
endtask: reset_phase

task ${agent_name}_drv::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Configure your component here
   phase.drop_objection(this);
endtask:configure_phase


task ${agent_name}_drv::run_phase(uvm_phase phase);
   super.run_phase(phase);
   fork 
      tx_driver();
   join
endtask: run_phase


task ${agent_name}_drv::tx_driver();
% if (drv_type == "pull") :
 forever begin
      ${agent_name}_item tr;
      // ToDo: Set output signals to their idle state
      this.drv_if.master.async_en      <= 0;
      `uvm_info("TX_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
      case (tr.kind) 
         ${agent_name}_item::READ: begin
            // ToDo: Implement READ transaction

         end
         ${agent_name}_item::WRITE: begin
            // ToDo: Implement READ transaction

         end
      endcase
	  `uvm_do_callbacks(${agent_name}_drv,${agent_name}_drv_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      seq_item_port.item_done();
      `uvm_info("TX_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("TX_DRIVER", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(${agent_name}_drv,${agent_name}_drv_callbacks,
                    post_tx(this, tr))

   end
% endif
endtask : tx_driver

task ${agent_name}_drv::send(${agent_name}_item tr);
   // ToDo: Drive signal on interface
  
endtask: send

% if (drv_type == "push") :
task ${agent_name}_drv::put(${agent_name}_item item);
   case (item.kind)
   ${agent_name}_item::READ: begin
     // ToDo: Implement READ transaction
     end
   ${agent_name}_item::WRITE: begin
     // ToDo: Implement READ transaction
     end
   endcase
   send(item);
endtask : put
% endif

`endif // ${agent_name.upper()}_drv__SV
