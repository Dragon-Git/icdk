`ifndef ${env_name.upper()}_CFG__SV
`define ${env_name.upper()}_CFG__SV

class ${env_name}_cfg extends uvm_object; 

  bit is_active         = 1;
  bit en_scb            = 1; // can be changed at run-time
  bit en_cov            = 0; // Enable via plusarg, only if coverage collection is turned on.
  bit under_reset       = 0;
  bit is_initialized;        // Indicates that the initialize() method has been called.
  // The scope and runtime of a existing test can be reduced by setting this variable. This is
  // useful to keep the runtime down especially in time-sensitive runs such as CI, which is meant
  // to check the code health and not find design bugs. It is set via plusarg and retrieved in
  // `dv_base_test`.
  bit smoke_test = 0;

  // bit to configure all uvcs with zero delays to create high bw test
  rand bit zero_delays;
% for child_name, child_type in env_childs.items():
  ${child_type[:-3]}cfg ${child_name[:-3]}cfg;
% endfor

  // set zero_delays 40% of the time
  constraint zero_delays_c {
    zero_delays dist {1'b0 := 6, 1'b1 := 4};
  }
  // reg model & q of valid csr addresses
  ${ral_block_name}         ral;
  ${ral_block_name} ral_models[string];

  // A queue of the names of RAL models that should be created in the `initialize` function
  // Related agents, adapters will be created in env as well as connecting them with scb
  // For example, if the IP has an additional RAL model named `ral1`, add it into the list as below
  //   virtual function void initialize(bit [TL_AW-1:0] csr_base_addr = '1);
  //     ral_model_names.push_back("ral1");
  //     super.initialize(csr_base_addr);
  string ral_model_names[$] = {${ral_block_name}::type_name};

  `uvm_object_param_utils_begin(${env_name}_cfg)
    `uvm_field_int   (is_active,   UVM_DEFAULT)
    `uvm_field_int   (en_scb,      UVM_DEFAULT)
    `uvm_field_int   (en_cov,      UVM_DEFAULT)
    `uvm_field_int   (zero_delays, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction: new

  virtual function void initialize(bit [31:0] csr_base_addr = '1);
    is_initialized = 1'b1;

% for child_name, child_type in env_childs.items():
    ${child_name[:-3]}cfg = ${child_type[:-3]}cfg::type_id::create("${child_name[:-3]}cfg");
% endfor
    // build the ral model
    create_ral_models(csr_base_addr);

  endfunction

  // Set pre-build RAL knobs.
  //
  // This method enables setting pre-build config knobs that can be used to control how the RAL
  // sub-structures are created.
  protected virtual function void pre_build_ral_settings(${ral_block_name} ral);
  endfunction

  // Perform post-build, pre-lock modifications to the RAL.
  //
  // For some registers / fields, the correct access policies or reset values may not be set. Fixes
  // like those can be made with this method.
  protected virtual function void post_build_ral_settings(${ral_block_name} ral);
  endfunction

  // Creates RAL models and sets their base address based on the supplied arg.
  //
  // csr_base_addr is the base address to set to the RAL models. If it is all 1s, then we treat that
  // as an indication to randomize the base address internally instead.
  virtual function void create_ral_models(bit [31:0] csr_base_addr = '1);

    foreach (ral_model_names[i]) begin
      string ral_name = ral_model_names[i];
      bit randomize_base_addr = &csr_base_addr;
      ${ral_block_name} reg_blk = create_ral_by_name(ral_name);

      if (reg_blk.get_name() == ${ral_block_name}::type_name) $cast(ral, reg_blk);

      // Build the register block with an arbitrary base address (we choose 0). We'll change it
      // later.
      pre_build_ral_settings(reg_blk);
      reg_blk.build();
      // reg_blk.addr_width = bus_params_pkg::BUS_AW;
      // reg_blk.data_width = bus_params_pkg::BUS_DW;
      // reg_blk.be_width = bus_params_pkg::BUS_DBW;
      post_build_ral_settings(reg_blk);
      reg_blk.lock_model();

      // Now the model is locked, we know its layout. Set the base address for the register block.
      // reg_blk.set_base_addr(.base_addr(`UVM_REG_ADDR_WIDTH'(csr_base_addr)),
      //                       .randomize_base_addr(randomize_base_addr));

      // // Get list of valid csr addresses (useful in seq to randomize addr as well as in scb checks)
      // reg_blk.compute_mapped_addr_ranges();
      // reg_blk.compute_unmapped_addr_ranges();
      ral_models[ral_name] = reg_blk;
    end

    if (ral_model_names.size > 0) begin
      if (!ral_models.exists(${ral_block_name}::type_name))
      `uvm_fatal(get_full_name(), "RAL ERROR")
    end
  endfunction

  virtual function ${ral_block_name} create_ral_by_name(string name);
    uvm_object        obj;
    uvm_factory       factory;
    ${ral_block_name} ral;

    factory = uvm_factory::get();
    obj = factory.create_object_by_name(.requested_type_name(name), .name(name));
    if (obj == null) begin
      // print factory overrides to help debug
      factory.print();
      `uvm_fatal(get_type_name(), $sformatf("could not create %0s as a RAL model, see above for a list of \
                                    type/instance overrides", name))
    end
    if (!$cast(ral, obj)) begin
      `uvm_fatal(get_type_name(), $sformatf("cast failed - %0s is not a ${ral_block_name}", name))
    end
    return ral;
  endfunction:create_ral_by_name

endclass: ${env_name}_cfg

`endif // ${env_name.upper()}_CFG__SV
