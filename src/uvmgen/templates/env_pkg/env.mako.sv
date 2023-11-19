`ifndef ${env_name.upper()}_SV
`define ${env_name.upper()}_SV
typedef class ${scb_name};
typedef class ${vsqr_name};
// typedef class {reg_name};
class ${env_name} extends uvm_env;
   ${scb_name} scb;
% if has_regmodle:  
   ral_block_VNAME regmodel;
   reg_seq ral_sequence; 
   REGTR regv 2host;
% endif
   ${vsqr_name} vsqr;
   // Declear agent
% for child_type, child_name in env_childs.items():
   ${child_type} ${child_name};
% endfor

   `uvm_component_utils(${env_name})

   extern function new(string name= "${env_name}", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: ${env_name}

function ${env_name}::new(string name= "${env_name}",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void ${env_name}::build_phase(uvm_phase phase);
   super.build();
% for child_type, child_name in env_childs.items():
   ${child_name} = ${child_type}::type_id::create("${child_name}",this); 
% endfor

   //ToDo: Instantiate other components,callbacks and TLM ports if added by user  

% if has_regmodle:  
   scb = ${scb_name}::type_id::create("scb",this);
% endif
% if has_regmodle:  
   regmodel = ral_block_VNAME::type_id::create("regmodel",this);
   regmodel.build();
   ral_sequence = reg_seq::type_id::create("ral_sequence");
   ral_sequence.model = regmodel; 
   reg2host = new("reg2host");
% endif
endfunction: build_phase

function void ${env_name}::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

% if has_regmodle:  
   regmodel.default_map.set_sequencer(mast_seqr,reg2host);
   MULT_DRV_START
   regmodel.default_map.set_sequencer(mast_seqr_0,reg2host);
   MULT_DRV_END
% endif  
   // ToDo: Register any required callbacks

endfunction: connect_phase

function void ${env_name}::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo : Implement this phase here
endfunction: start_of_simulation_phase


task ${env_name}::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   phase.raise_objection(this,"Resetting the DUT...");
   //ToDo: Reset DUT
   phase.drop_objection(this);
endtask:reset_phase

task ${env_name}::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Configure components here
   phase.drop_objection(this);
endtask:configure_phase

task ${env_name}::run_phase(uvm_phase phase);
   super.run_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Run your simulation here
   phase.drop_objection(this);
endtask:run_phase

function void ${env_name}::report_phase(uvm_phase phase);
   super.report_phase(phase);
   //ToDo: Implement this phase here
endfunction:report_phase

task ${env_name}::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
   //ToDo: Implement this phase here
endtask:shutdown_phase
`endif // ${env_name.upper()}_SV