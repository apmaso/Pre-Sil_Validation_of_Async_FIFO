class burst_test extends uvm_test;
    // Register the class with the factory 
    `uvm_component_utils(burst_test);

    // Declare handles to the components
    fifo_environment environment_h;
    fifo_burst_wr_seq write_sequence_h;
    fifo_burst_rd_seq read_sequence_h;

    // Define the constructor
    function new(string name = "burst_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
    endfunction : new
  
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);

        environment_h = fifo_environment::type_id::create("environment_h", this);
    endfunction : build_phase
  
    // End of elab phase for topology setup
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_type_name(), $sformatf("End of Elaboration %s", get_full_name()), UVM_HIGH);

        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase


    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);
        write_sequence_h = fifo_burst_wr_seq::type_id::create("write_sequence_h");
        read_sequence_h = fifo_burst_rd_seq::type_id::create("read_sequence_h");

        phase.raise_objection(this);
        // Run the sequences in parallel
        fork
            write_sequence_h.start(environment_h.agent_h.sequencer_wr_h);
            read_sequence_h.start(environment_h.agent_h.sequencer_rd_h);
        join
        phase.drop_objection(this); 
    endtask
endclass
class flag_test extends burst_test;
    // Register the class with the factory 
    `uvm_component_utils(flag_test);

    // Declare handles to the new components
    fifo_flag_wr_seq flag_wr_seq_h;
    fifo_flag_rd_seq flag_rd_seq_h;

    // Define the constructor
    function new(string name = "flag_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
    endfunction : new
 
    // Overwrite the run phase with new sequences
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);
        flag_wr_seq_h = fifo_flag_wr_seq::type_id::create("flag_wr_seq_h");
        flag_rd_seq_h = fifo_flag_rd_seq::type_id::create("flag_rd_seq_h");

        phase.raise_objection(this);
        // Run the sequences in parallel
        fork
            flag_wr_seq_h.start(environment_h.agent_h.sequencer_wr_h);
            flag_rd_seq_h.start(environment_h.agent_h.sequencer_rd_h);
        join
        phase.drop_objection(this); 
    endtask
endclass
class random_test extends flag_test;
    // Register the class with the factory 
    `uvm_component_utils(random_test);

    // Declare handles to the new components
    fifo_random_wr_seq random_wr_seq_h;
    fifo_random_rd_seq random_rd_seq_h;

    // Define the constructor
    function new(string name = "random_test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
    endfunction : new
 
    // Overwrite the run phase with new sequences
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);
        random_wr_seq_h = fifo_random_wr_seq::type_id::create("random_wr_seq_h");
        random_rd_seq_h = fifo_random_rd_seq::type_id::create("random_rd_seq_h");

        phase.raise_objection(this);
        // Run the sequences in parallel
        fork
            random_wr_seq_h.start(environment_h.agent_h.sequencer_wr_h);
            random_rd_seq_h.start(environment_h.agent_h.sequencer_rd_h);
        join
        phase.drop_objection(this); 
    endtask
endclass