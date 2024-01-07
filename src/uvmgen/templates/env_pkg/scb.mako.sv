`ifndef ${scb_name.upper()}__SV
`define ${scb_name.upper()}__SV

% if diff_act:
   `uvm_analysis_imp_decl(_ingress)
   `uvm_analysis_imp_decl(_egress) 
% endif

class ${scb_name} extends uvm_scoreboard;

   ${env_name}_cfg  cfg;
   % if diff_act: 
   uvm_analysis_imp_ingress #(${mst_action},${scb_name}) before_export;
   uvm_analysis_imp_egress #(${slv_action},${scb_name}) after_export;
   // Built in UVM comparator will not be used. User has to define the compare logic
   % else:
   uvm_analysis_export #(${scb_item}) before_export, after_export;
   uvm_in_order_class_comparator #(${scb_item}) comparator;
   % endif

   `uvm_component_utils(${scb_name})
	extern function new(string name = "${scb_name}",
                    uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
 % if diff_act:
 	extern function void write_ingress(${mst_action} tr);
	extern function void write_egress(${slv_action} tr);
 % endif

endclass: ${scb_name}


function ${scb_name}::new(string name = "${scb_name}", uvm_component parent);
   super.new(name,parent);
endfunction: new

function void ${scb_name}::build_phase(uvm_phase phase);
    super.build_phase(phase);
    before_export = new("before_export", this);
    after_export  = new("after_export", this);
	% if not diff_act:
    comparator    = new("comparator", this);
	% endif
endfunction:build_phase

function void ${scb_name}::connect_phase(uvm_phase phase);
    % if not diff_act:
    before_export.connect(comparator.before_export);
    after_export.connect(comparator.after_export);
	% endif
endfunction:connect_phase

function void ${scb_name}::report_phase(uvm_phase phase);
    super.report_phase(phase);
	% if not diff_act:
    `uvm_info("${scb_name}_RPT", $psprintf("Matches = %0d, Mismatches = %0d",
               comparator.m_matches, comparator.m_mismatches),
               UVM_MEDIUM);
	% endif
endfunction:report_phase

% if diff_act:
function void ${scb_name}::write_ingress(${mst_action} tr);
// User needs to add functionality here 
endfunction

function  void ${scb_name}::write_egress(${slv_action} tr);
endfunction
% endif
`endif // ${scb_name.upper()}__SV