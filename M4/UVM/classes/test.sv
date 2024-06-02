class my_first_test extends uvm_test;

    // Register the class with the factory 
    `uvm_component_utils(my_first_test);

    // Declare handles to the components
    fifo_environment environment_h;
    fifo_write_sequence write_sequence_h;
    fifo_read_sequence read_sequence_h;

    // Define the constructor
    function new(string name = "my_first_test", uvm_component parent);
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
        write_sequence_h = fifo_write_sequence::type_id::create("write_sequence_h");
        read_sequence_h = fifo_read_sequence::type_id::create("read_sequence_h");

        phase.raise_objection(this);

/*        if (!write_sequence_h.randomize())
            `uvm_error("RANDOMIZE", "Failed to randomize write sequence")
        if (!read_sequence_h.randomize())
            `uvm_error("RANDOMIZE", "Failed to randomize read sequence")
*/
        fork
            write_sequence_h.start(environment_h.agent_h.sequencer_h);
            read_sequence_h.start(environment_h.agent_h.sequencer_h);
        join

        phase.drop_objection(this); 
    endtask
  
endclass
