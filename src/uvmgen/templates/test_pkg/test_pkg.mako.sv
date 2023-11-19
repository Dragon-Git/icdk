package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macros.svh"

% for pkg in import_pkgs:
    import ${pkg}::*;
% endfor

% for file in files:
    % if "pkg" not in file.name:
    `include "${file.name}"
    % endif
% endfor   

endpackage: ${pkg_name}