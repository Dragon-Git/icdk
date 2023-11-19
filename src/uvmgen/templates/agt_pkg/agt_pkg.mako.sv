package ${pkg_name};
    import uvm_pkg::*;
    `include "uvm_macros.svh"
% for pkg in import_pkgs:
    import ${pkg}:*;
% endfor

    typedef class spi_item;
    typedef class spi_cfg;
    typedef class spi_drv;
    typedef class spi_mon;
    typedef class spi_sqr;

% for file in files:
    % if "pkg" not in file.name:
    `include "${file.name}"
    % endif
% endfor

endpackage: ${pkg_name}