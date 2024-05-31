class fifo_agent extends uvm_agent;
    // Register the class with the factory
    `uvm_component_utils(fifo_agent)

    // Declare handles to the components
    fifo_sequencer sequencer_h;
    fifo_monitor monitor_h;
    fifo_driver driver_h;

    // Constructor
    function new(string name = "fifo_agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
    endfunction : new

    // Build phase   TODO: Check if this can be virtual
    // virtual function void build_phase(uvm_phase phase);
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);

        // Create and configure the components
        sequencer_h = fifo_sequencer::type_id::create("sequencer_h", this);
        monitor_h = fifo_monitor::type_id::create("monitor_h", this);
        driver_h = fifo_driver::type_id::create("driver_h", this);

    endfunction : build_phase

    // Connect phase   TODO: Check if this can be virtual
    //virtual function void connect_phase(uvm_phase phase);
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_HIGH);
        
        // Connect the driver to the sequencer
        driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
        
        // Connect the monitor to the analysis port
    
    endfunction : connect_phase

endclass