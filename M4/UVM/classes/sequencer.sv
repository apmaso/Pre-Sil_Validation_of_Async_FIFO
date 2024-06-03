/**************************************************
*   Sequencer class for UVM Based FIFO Verification
* 
*   Essentially a dummy implementation
*
*   Author: Alexander Maso
*
**************************************************/

class fifo_sequencer extends uvm_sequencer #(fifo_transaction);
    `uvm_component_utils(fifo_sequencer)

    // Constructor
    function new(string name = "fifo_sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
    endfunction : new

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_DEBUG);
    endfunction : build_phase

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_DEBUG);
    endfunction : connect_phase    
    
endclass