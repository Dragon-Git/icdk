package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macros.svh"
% for pkg in import_pkgs:
    import ${pkg}:*;
% endfor

    typedef class ${agent_name}_item;
    typedef class ${agent_name}_cfg;
    typedef class ${agent_name}_drv;
    typedef class ${agent_name}_mon;
    typedef class ${agent_name}_sqr;
    typedef class ${agent_name}_cov;
    typedef class ${agent_name}_mon2cov_connect;

% for file in files:
    % if "pkg" not in file.name:
    `include "${file.name}"
    % endif
% endfor

endpackage: ${pkg_name}