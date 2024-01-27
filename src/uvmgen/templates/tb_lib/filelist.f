% for pkg in filelist_pkgs:
    % if "agt" in pkg:
$TB_DIR/${pkg}/${pkg.replace("agt_pkg", "if")}.gen.sv
    % endif
    % if "pk_syoscb" in pkg:
+incdir+$SYOSCB_HOME/uvm_syoscb/src
$SYOSCB_HOME/uvm_syoscb/lib/pk_utils_uvm.sv
$SYOSCB_HOME/uvm_syoscb/src/${pkg}.sv
    % elif "tb" not in pkg:
+incdir+$TB_DIR/${pkg}
$TB_DIR/${pkg}/${pkg}.gen.sv
    % else:
+incdir+$TB_DIR/${pkg}
$TB_DIR/${pkg}/tb.gen.sv
    % endif
% endfor
