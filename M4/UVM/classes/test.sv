class my_first_test extends uvm_test;

    // Register the class with the factory 
    `uvm_component_utils(my_first_test);

    // Declare handles to the components
    fifo_environment environment_h;
    fifo_sequence sequence_h;

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

        phase.raise_objection(this);
        sequence_h = fifo_sequence::type_id::create("sequence_h");

        if (!sequence_h.randomize())
            `uvm_error("RANDOMIZE", "Failed to randomize sequence")

        sequence_h.starting_phase = phase;

        sequence_h.start(environment_h.agent_h.sequencer_h);
        #10; // Example -> Consume some arbitrary time

        // UVM Macro to report a message
        // 1st argument: The type name of the component
        // 2nd argument: The message to report
        // 3rd argument: The verbosity level
        `uvm_info(get_type_name(), "Hello, World!", UVM_MEDIUM);

        phase.drop_objection(this); 
    endtask
  
endclass
