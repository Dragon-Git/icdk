`ifndef ENV__SV
`define ENV__SV
//ToDo: Include required files here
`include "VNAME.sv"
RAL_START
class reg_seq extends uvm_reg_sequence;
   ral_block_VNAME regmodel;

   `uvm_object_utils(reg_seq)

   function new(string name = "");
      super.new(name);
   endfunction:new

   task pre_body();
      $cast(regmodel,model);
   endtask

   task body;
      uvm_status_e status;
      uvm_reg_data_t data;
   //ToDo :Define the user sequence here
   endtask
endclass
RAL_END
//Including all the required component files here
class ENV extends uvm_env;
   SCBD_EN_START 
   ${scb_name} scb;
   SCBD_EN_END
   RAL_START  
   ral_block_VNAME regmodel;
   reg_seq ral_sequence; 
   REGTR regv 2host;
   RAL_END
   // Declear agent
% for child_type, child_name in env_childs.items():
   ${child_type} ${child_name};
% endfor
% if (mon2cov_con_approach == "callback") :
   MON_2cov_connect mon2cov;
% endif

   `uvm_component_utils(ENV)

   extern function new(string name= "ENV", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: ENV

function ENV::new(string name= "ENV",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void ENV::build_phase(uvm_phase phase);
   super.build();
% for child_type, child_name in env_childs.items():
   ${child_name} = ${child_type}::type_id::create("${child_name}",this); 
% endfor

   //ToDo: Instantiate other components,callbacks and TLM ports if added by user  

   cov = COV::type_id::create("cov",this); //Instantiating the coverage class
% if (mon2cov_con_approach == "callback") :
   mon2cov  = new(cov);
   uvm_callbacks # (MON,MON_callbacks)::add(monitor,mon2cov);
% else: ## mon2cov_con_approach == "analysis_port"
   mon2cov  = MON_2cov_connect::type_id::create("mon2cov", this);
   mon2cov.cov  = cov;
   i_monitor.mon_analysis_port.connect(cov.cov_export);
% endif
   SCBD_EN_START
   scb = ${scb_name}::type_id::create("scb",this);
   SCBD_EN_END

   RAL_START
   regmodel = ral_block_VNAME::type_id::create("regmodel",this);
   regmodel.build();
   ral_sequence = reg_seq::type_id::create("ral_sequence");
   ral_sequence.model = regmodel; 
   reg2host = new("reg2host");
   RAL_END 
endfunction: build_phase

function void ENV::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

% if mon2cov_con_approach == "analysis_port":
   //Connecting the monitor's analysis port with ${scb_name}'s expected analysis export.
   i_monitor.mon_analysis_port.connect(scb.before_export);
   o_monitor.mon_analysis_port.connect(scb.after_export);
   //Other monitor element will be connected to the after export of the scoreboard
% endif
   RAL_START
   regmodel.default_map.set_sequencer(mast_seqr,reg2host);
   MULT_DRV_START
   regmodel.default_map.set_sequencer(mast_seqr_0,reg2host);
   MULT_DRV_END
   RAL_END 
   // ToDo: Register any required callbacks

endfunction: connect_phase

function void ENV::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo : Implement this phase here
endfunction: start_of_simulation_phase


task ENV::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   phase.raise_objection(this,"Resetting the DUT...");
   //ToDo: Reset DUT
   phase.drop_objection(this);
endtask:reset_phase

task ENV::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Configure components here
   phase.drop_objection(this);
endtask:configure_phase

task ENV::run_phase(uvm_phase phase);
   super.run_phase(phase);
   phase.raise_objection(this,"");
   //ToDo: Run your simulation here
   phase.drop_objection(this);
endtask:run_phase

function void ENV::report_phase(uvm_phase phase);
   super.report_phase(phase);
   //ToDo: Implement this phase here
endfunction:report_phase

task ENV::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
   //ToDo: Implement this phase here
endtask:shutdown_phase
`endif // ENV__SV