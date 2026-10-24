package FIFO_test_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"

import FIFO_env_pkg::*;
import FIFO_config_pkg::*;
import FIFO_main_write_only_seq_pkg::*;
import FIFO_main_read_only_seq_pkg::*;
import FIFO_main_write_read_seq_pkg::*;
import FIFO_main_rand_seq_pkg::*;
import FIFO_reset_seq_pkg::*;


class FIFO_test extends uvm_test;
  `uvm_component_utils(FIFO_test)
  FIFO_env env;
  FIFO_config FIFO_cfg;
  virtual FIFO_if FIFO_vif;
  FIFO_main_write_only_seq main_write_only_seq;
  FIFO_main_read_only_seq main_read_only_seq;
  FIFO_main_write_read_seq main_write_read_seq;
  FIFO_main_rand_seq main_rand_seq;
  FIFO_reset_seq reset_seq;

  function new(string name = "FIFO_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = FIFO_env::type_id::create("env",this);
    FIFO_cfg = FIFO_config::type_id::create("FIFO_cfg");
    main_write_only_seq = FIFO_main_write_only_seq::type_id::create("main_write_only_seq");
    main_read_only_seq = FIFO_main_read_only_seq::type_id::create("main_read_only_seq");
    main_write_read_seq = FIFO_main_write_read_seq::type_id::create("main_write_read_seq");
    main_rand_seq = FIFO_main_rand_seq::type_id::create("main_rand_seq");
    reset_seq = FIFO_reset_seq::type_id::create("reset_seq");

    if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", FIFO_cfg.FIFO_vif))
      `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the FIFO from the uvm_config_db");

    uvm_config_db #(FIFO_config)::set(this, "*", "CFG", FIFO_cfg);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    //reset sequence
    `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

    //main write only sequence
    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_write_only_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    //main read only sequence
    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_read_only_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    //main write read sequence
    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_write_read_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    //main rand sequence
    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_rand_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass: FIFO_test
endpackage
