<%block name="main">\
`ifndef ${agent_name.upper()}_AGT__SV
`define ${agent_name.upper()}_AGT__SV

class ${agent_name}_agt extends uvm_agent;
    // ToDo: add sub environmnet properties here
    protected uvm_active_passive_enum is_active = UVM_ACTIVE;
    ${agent_name}_cfg cfg;
    ${agent_name}_cov cov;
    ${agent_name}_drv drv;
    ${agent_name}_sqr sqr;
    ${agent_name}_mon mon;
    ${agent_name}_mon2cov_connect mon2cov;

    typedef virtual ${agent_name}_if vif;
    vif agt_if;
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
        // get CFG_T object from uvm_config_db
        if (!uvm_config_db#(${agent_name}_cfg)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal(get_full_name(), $sformatf("failed to get %s from uvm_config_db", cfg.get_type_name()))
        end
        `uvm_info(get_full_name(), $sformatf("\n%0s", cfg.sprint()), UVM_HIGH)

        // create components
        if (cfg.en_cov) begin
            cov = ${agent_name}_cov ::type_id::create("cov", this);
% if (mon2cov_con_method == "callback") :
            mon2cov  = new(cov);
            uvm_callbacks # (${agent_name}_mon,${agent_name}_mon_callbacks)::add(mon, mon2cov);
% else: ## mon2cov_con_method == "analysis_port"
            mon2cov  = ${agent_name}_mon2cov_connect::type_id::create("mon2cov", this);
            mon2cov.cov  = cov;
% endif
        end
        mon = ${agent_name}_mon::type_id::create("mon", this);
        if (is_active == UVM_ACTIVE) begin
           sqr = ${agent_name}_sqr::type_id::create("sqr", this);
           drv = ${agent_name}_drv::type_id::create("drv", this);
        end
        if (!uvm_config_db#(vif)::get(this, "", "if", agt_if)) begin
           `uvm_fatal("AGT/NOVIF", "No virtual interface specified for this agent instance")
        end
        uvm_config_db# (vif)::set(this,"drv","drv_if", agt_if);
        uvm_config_db# (vif)::set(this,"mon","mon_if", agt_if);
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
% if (mon2cov_con_method == "analysis_port"):
        mon.mon_analysis_port.connect(cov.cov_export);
% endif

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