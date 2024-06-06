% for pkg in filelist_pkgs:
    % if "agt" in pkg:
$TB_PATH/${pkg}/${pkg.replace("agt_pkg", "if")}.gen.sv
    % endif
    % if "pk_syoscb" in pkg:
+incdir+$SYOSCB_HOME/uvm_syoscb/src
$SYOSCB_HOME/lib/pk_utils_uvm.sv
$SYOSCB_HOME/src/${pkg}.sv
    % elif "tb" not in pkg:
+incdir+$TB_PATH/${pkg}
$TB_PATH/${pkg}/${pkg}.gen.sv
    % else:
+incdir+$TB_PATH/${pkg}
$TB_PATH/${pkg}/tb.gen.sv
    % endif
% endfor
