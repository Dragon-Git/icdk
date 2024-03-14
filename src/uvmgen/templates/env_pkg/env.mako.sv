`ifndef ${env_name.upper()}_SV
`define ${env_name.upper()}_SV
typedef class ${scb_name};
typedef class ${vsqr_name};
typedef class ${env_name}_cfg;
// typedef class {reg_name};
class ${env_name} extends uvm_env;
    ${env_name}_cfg  cfg;
% if "pk_syoscb" in import_pkgs:
    % if use_syoscb_array:
    cl_syoscbs#(${scb_item}) scbs;
    % else:
    cl_syoscb scb;
    pk_utils_uvm::filter_trfm #(${scb_item}, uvm_sequence_item) ft;
    % endif
% else:
    ${scb_name} scb;
% endif
% if has_regmodel:  
    ${ral_block_name} regmodel;
    ${env_childs[reg_agt_name].replace("_agt", "")}_reg_adapter ${reg_agt_name}_reg_adapter;
% endif
    ${vsqr_name} vsqr;
    // Declear agent
% for child_name, child_type in env_childs.items():
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
    super.build_phase(phase);
    // get dv_base_env_cfg object from uvm_config_db
    if (!uvm_config_db#(${env_name}_cfg)::get(this, "", "cfg", cfg)) begin
        `uvm_fatal(get_full_name(), $sformatf("failed to get %s from uvm_config_db", cfg.get_type_name()))
    end

% for child_name, child_type in env_childs.items():
    ${child_name} = ${child_type}::type_id::create("${child_name}",this);
    uvm_config_db#(${child_type[:-3]}cfg)::set(this, "${child_name}", "cfg", cfg.${child_name[:-3]}cfg);

% endfor
    vsqr = ${vsqr_name}::type_id::create("vsqr",this);
    //ToDo: Instantiate other components,callbacks and TLM ports if added by user  

    // create components

% if "pk_syoscb" in import_pkgs:
    // Pass the scoreboard configuration object to the config_db
    % if use_syoscb_array:
    uvm_config_db #(cl_syoscbs_cfg)::set(this, "scbs", "cfg", cfg.syoscbs_cfg);
    scbs = cl_syoscbs#(${scb_item})::type_id::create("scbs",this);
    % else:
    uvm_config_db #(cl_syoscb_cfg)::set(this, "scb", "cfg", cfg.syoscb_cfg);
    // Create the scoreboard
    scb = cl_syoscb::type_id::create("scb", this);
    ft = pk_utils_uvm::filter_trfm #(${scb_item}, uvm_sequence_item)::type_id::create("ft", this);
    % endif
% else:
    scb = ${scb_name}::type_id::create("scb",this);
    scb.cfg = cfg;
% endif

% if has_regmodel:  
    regmodel = ${ral_block_name}::type_id::create("regmodel",this);
    regmodel.build();
    // ral_sequence = reg_seq::type_id::create("ral_sequence");
    // ral_sequence.model = regmodel; 
    ${reg_agt_name}_reg_adapter = new("${reg_agt_name}_reg_adapter");
% endif
endfunction: build_phase

function void ${env_name}::connect_phase(uvm_phase phase);
% if "pk_syoscb" in import_pkgs:
    cl_syoscb_subscriber subscriber;
% endif

    super.connect_phase(phase);
% if "pk_syoscb" in import_pkgs:
    % if use_syoscb_array:
        % for child_name in env_childs:
    begin
      pk_utils_uvm::filter_trfm #(${scb_item}, uvm_sequence_item) ft;
      ft = this.scbs.get_filter_trfm("DUT", "P1", ${loop.index});
      //Connect agents to filter transforms
      ${child_name}.mon.mon_analysis_port.connect(ft.analysis_export);
      ft = this.scbs.get_filter_trfm("REF", "P1", ${loop.index});
      ${child_name}.mon.mon_analysis_port.connect(ft.analysis_export);
    end
        % endfor
    % else:
    // Get the subscriber for Producer: P1 for queue: Q1 and connect it
    // to the UVM monitor producing transactions for this queue
    this.${list(env_childs.keys())[0]}.mon.mon_analysis_port.connect(ft.analysis_export);
    subscriber = this.scb.get_subscriber("DUT", "P1");
    ft.ap.connect(subscriber.analysis_export);
    // Get the subscriber for Producer: P1 for queue: Q2 and connect it
    // to the UVM monitor producing transactions for this queue
    this.${list(env_childs.keys())[0]}.mon.mon_analysis_port.connect(ft.analysis_export);
    subscriber = this.scb.get_subscriber("REF", "P1");
    ft.ap.connect(subscriber.analysis_export);
    % endif
% endif

% if has_regmodel:  
    regmodel.default_map.set_sequencer(${reg_agt_name}.sqr,${reg_agt_name}_reg_adapter);
    // MULT_DRV_START
    // regmodel.default_map.set_sequencer(mast_seqr_0,m_${reg_agt_name}_reg_adapter);
    // MULT_DRV_END
% endif  
% for child_name, child_type in env_childs.items():
    $cast(vsqr.${child_name[:-3]}sqr, ${child_name}.sqr);
% endfor
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