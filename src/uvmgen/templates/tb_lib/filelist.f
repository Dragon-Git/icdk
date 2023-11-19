% for pkg in filelist_pkgs:
    % if "agt" in pkg:
$TB_DIR/${pkg}/${pkg.replace("agt_pkg", "if")}.gen.sv
    % endif
+incdir+$TB_DIR/${pkg}
    % if "tb" not in pkg:
$TB_DIR/${pkg}/${pkg}.gen.sv
    % else:
$TB_DIR/${pkg}/tb.gen.sv
    % endif
% endfor
