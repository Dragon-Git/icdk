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
   SB sb;
   SCBD_EN_END
   RAL_START  
   ral_block_VNAME regmodel;
   reg_seq ral_sequence; 
   RAL_END
   SING_DRV_START
   XACT mast_drv;
   XACT slave_drv;
   SING_DRV_END
   MULT_DRV_START
   //Multiple driver instantiation
   XACT mast_drv_RPTNO;     //UVMGEN_RPT_ON_XACT
   XACT slave_drv_RPTNO;    //UVMGEN_RPT_ON_XACT
   //ToDo: Instantiate other drivers here. 
   MULT_DRV_END
   MON i_monitor;
   MON o_monitor;   
   COV cov;
   SING_DRV_START
   SEQR mast_seqr;
   SEQR slave_seqr;
   SING_DRV_END
   MULT_DRV_START
   //Multiple driver instantiation
   SEQR mast_seqr_RPTNO;     //UVMGEN_RPT_ON_SEQR
   SEQR slave_seqr_RPTNO;    //UVMGEN_RPT_ON_SEQR 
   //ToDo: Instantiate other sequencers for corresponding drivers here. 

   MULT_DRV_END
   
   RAL_START
   REGTR reg2host;
   RAL_END
   
   MNTR_OBS_MTHD_ONE_START 
   MON_2cov_connect mon2cov;
   MNTR_OBS_MTHD_ONE_END
   MNTR_OBS_MTHD_TWO_START 
   MNTR_OBS_MTHD_TWO_Q_START
   MON_2cov_connect mon2cov;
   MNTR_OBS_MTHD_TWO_Q_END
   MNTR_OBS_MTHD_TWO_END


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
   FD_DRIV_START
   SING_DRV_START
   mast_drv = XACT::type_id::create("mast_drv",this); 
   SING_DRV_END
   MULT_DRV_START
   mast_drv_RPTNO = XACT::type_id::create("mast_drv_RPTNO",this);  //UVMGEN_RPT_ON_XACT 
   MULT_DRV_END
   FD_DRIV_END
   GNRC_DRIV_START
   SING_DRV_START 
   mast_drv = XACT::type_id::create("mast_drv",this); 
   SING_DRV_END
   MULT_DRV_START
   mast_drv_RPTNO = XACT::type_id::create("mast_drv_RPTNO",this); //UVMGEN_RPT_ON_XACT 
   MULT_DRV_END
   GNRC_DRIV_END

   SING_DRV_START
   slave_drv = XACT::type_id::create("slave_drv",this);
   SING_DRV_END
   MULT_DRV_START
   slave_drv_RPTNO = XACT::type_id::create("slave_drv_RPTNO",this);  //UVMGEN_RPT_ON_XACT
   MULT_DRV_END
   i_monitor = MON::type_id::create("i_monitor",this); 
   o_monitor = MON::type_id::create("o_monitor",this);
   SING_DRV_START
   mast_seqr = SEQR::type_id::create("mast_seqr",this);
   SING_DRV_END
   MULT_DRV_START
   mast_seqr_RPTNO = SEQR::type_id::create("mast_seqr_RPTNO",this); //UVMGEN_RPT_ON_SEQR
   MULT_DRV_END
   SING_DRV_START
   slave_seqr = SEQR::type_id::create("slave_seqr",this);
   SING_DRV_END
   MULT_DRV_START
   slave_seqr_RPTNO = SEQR::type_id::create("slave_seqr_RPTNO",this); //UVMGEN_RPT_ON_SEQR
   MULT_DRV_END

   //ToDo: Instantiate other components,callbacks and TLM ports if added by user  

   cov = COV::type_id::create("cov",this); //Instantiating the coverage class
   MNTR_OBS_MTHD_ONE_START
   mon2cov  = new(cov);
   uvm_callbacks # (MON,MON_callbacks)::add(monitor,mon2cov);
   MNTR_OBS_MTHD_ONE_END
   MNTR_OBS_MTHD_TWO_START
   mon2cov  = MON_2cov_connect::type_id::create("mon2cov", this);
   mon2cov.cov  = cov;
   i_monitor.mon_analysis_port.connect(cov.cov_export);
   MNTR_OBS_MTHD_TWO_END
   SCBD_EN_START
   sb = SB::type_id::create("sb",this);
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
   SING_DRV_START
   //Connecting the driver to the sequencer via ports
   UVM_PULL_DRV_START
   mast_drv.seq_item_port.connect(mast_seqr.seq_item_export);
   slave_drv.seq_item_port.connect(slave_seqr.seq_item_export);
   UVM_PULL_DRV_END
   UVM_PUSH_DRV_START
   mast_seqr.req_port.connect(mast_drv.req_export);
   slave_seqr.req_port.connect(slave_drv.req_export);
   UVM_PUSH_DRV_END
   SING_DRV_END

   MULT_DRV_START
   CHANGE_FROM_UVMGEN_mast_drv_RPTNO.seq_item_port.connect(mast_seqr_RPTNO.seq_item_export); //UVMGEN_RPT_ON_SEQR 
   CHANGE_FROM_UVMGEN_slave_drv_RPTNO.seq_item_port.connect(slave_seqr_RPTNO.seq_item_export); //UVMGEN_RPT_ON_SEQR
   MULT_DRV_END

   MNTR_OBS_MTHD_TWO_START
   MNTR_OBS_MTHD_TWO_NQ_START
   SCBD_EN_START
   //Connecting the monitor's analysis port with SB's expected analysis export.
   i_monitor.mon_analysis_port.connect(sb.before_export);
   o_monitor.mon_analysis_port.connect(sb.after_export);
   //Other monitor element will be connected to the after export of the scoreboard
   SCBD_EN_END
   MNTR_OBS_MTHD_TWO_NQ_END
   MNTR_OBS_MTHD_TWO_END 
   RAL_START
   SING_DRV_START
   regmodel.default_map.set_sequencer(mast_seqr,reg2host);
   SING_DRV_END

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