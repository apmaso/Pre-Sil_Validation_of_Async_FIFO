/***************************************************************
*  Coverage class for a UVM Based FIFO Verification
* 
*
*  Author: Alexander Maso
***************************************************************/

class fifo_coverage extends uvm_subscriber #(fifo_transaction);
    `uvm_component_utils(fifo_coverage) // Register the component with the factory

    // Declare the handle for our transactions
    fifo_transaction tx;

    // TODO: What is this data type?
    real cov; // For coverage numbers/printing

    // Define covergroups
    covergroup cg;
        option.per_instance = 2;
        EMPTY   : coverpoint tx.empty
        FULL    : coverpoint tx.full
        HALF    : coverpoint tx.half
    endgroup : cg

    // Constructor
    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_DEBUG);
    
        tx = fifo_transaction::type_id::create("tx");
        cg = new();        
    endfunction : new

    virtual function void write(fifo_transaction t);
        `uvm_info(get_type_name(), $sformatf("Writing to %s", get_full_name()), UVM_DEBUG);
        tx = t;
        t.print();

        cg.sample();
        cov = cg.get_coverage();
        `uvm_info(get_type_name(), $sformatf("Coverage: %f", cov), UVM_NONE);
    endfunction : write

endclass

