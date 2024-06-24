/*********************************************
*   Scoreboard Class for our UVM Based 
*   Testbench for an Asynchronous FIFO Module
*  
*   The scoreboard is responsible for comparing
*   the data written to the FIFO with the data
*   read from the FIFO. If the data does not match
*   then an error is reported. The scoreboard also
*   keeps track of the number of read and write 
*   transactions and the number of times the FIFO
*   was written to or read from when full, half-full,
*   or empty.

*   The scoreboard uses the new() contructor to create
*   the analysis ports.  It uses a UVM macro to declare 
*   the two, separate analysis ports for read and write
*   transactions.
*
*
*********************************************/

`uvm_analysis_imp_decl(_port_a)
`uvm_analysis_imp_decl(_port_b)

class fifo_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(fifo_scoreboard); // Register the component with the factory

    // Declare analysis port
    uvm_analysis_imp_port_a #(fifo_transaction, fifo_scoreboard) scoreboard_port_wr;
    uvm_analysis_imp_port_b #(fifo_transaction, fifo_scoreboard) scoreboard_port_rd;
    fifo_transaction tx_stack_wr[$];
    fifo_transaction tx_stack_rd[$];

    // Declare counters
    int half_count_wr  = 0;
    int half_count_rd  = 0;
    int full_count_wr  = 0;
    int empty_count_rd = 0;
    int read_count  = 0;
    int write_count = 0;

    // Constructor
	function new(string name = "fifo_scoreboard", uvm_component parent);
		super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("Constructing %s", get_full_name()), UVM_HIGH);
	endfunction: new
	
    // Build phase
	function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Building %s", get_full_name()), UVM_HIGH);

        // Use new constructor to create the analysis ports
        scoreboard_port_wr = new("scoreboard_port_wr", this);
        scoreboard_port_rd = new("scoreboard_port_rd", this);
    endfunction: build_phase

    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), $sformatf("Connecting %s", get_full_name()), UVM_HIGH);
    
    endfunction: connect_phase
    
    // Run Phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);  
        `uvm_info(get_type_name(), $sformatf("Running %s", get_full_name()), UVM_HIGH);
 
        forever begin
            logic [DATA_WIDTH-1:0] expected;
            logic [DATA_WIDTH-1:0] received;
            fifo_transaction current_tx_rd;
            fifo_transaction current_tx_wr;

            // Wait until we have a read transaction on the stack and then
            // pop the oldest read and write transactions off the stack
            // and compare the data
            wait(tx_stack_rd.size() > 0);
            current_tx_wr = tx_stack_wr.pop_front();
            current_tx_rd = tx_stack_rd.pop_front();
            expected = current_tx_wr.data_in;
            received = current_tx_rd.data_out;

            if (received !== expected) begin
                `uvm_error("SCOREBOARD", $sformatf("Data mismatch!: expected %h, got %h", expected, received));  
            end
            else begin
                `uvm_info("SCOREBOARD", $sformatf("Data match!: expected %h, got %h", expected, received), UVM_MEDIUM);
            end
        end
    endtask: run_phase

    function void write_port_a(fifo_transaction mon_tx_wr);
        // If tx pkt arrives here, then wr_en is asserted
        // If full flag is asserted then this is a write to a full FIFO
        if (mon_tx_wr.full) begin
            full_count_wr++;
            `uvm_info("SCOREBOARD", $sformatf("Write to full FIFO count: %0d", full_count_wr), UVM_MEDIUM);
        end
        else begin // If full flag is not asserted, then data is written to the FIFO
            write_count++;
            `uvm_info("SCOREBOARD", $sformatf("Write count: %0d", write_count), UVM_MEDIUM);
            // If full not asserted but half is then this is a write to a half-full fifo
            if (mon_tx_wr.half) begin
                half_count_wr++;
                `uvm_info("SCOREBOARD", $sformatf("Write to half-full FIFO count: %0d", half_count_wr), UVM_MEDIUM);
            end
            // Push the write transaction onto the stack
            tx_stack_wr.push_back(mon_tx_wr);
            `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  wr_en: %b  |  data_in: %h  |", mon_tx_wr.wr_en, mon_tx_wr.data_in), UVM_HIGH);
        end
    endfunction : write_port_a

    function void write_port_b(fifo_transaction mon_tx_rd);
        // If tx pkt arrives here, then rd_en is asserted
        // If empty flag is asserted then this is an attempt to read from an empty FIFO
        if (mon_tx_rd.empty) begin
            empty_count_rd++;
            `uvm_info("SCOREBOARD", $sformatf("Read from empty FIFO count: %0d", empty_count_rd), UVM_MEDIUM);
        end
        else begin // If empty flag is not asserted, then data is read from the FIFO
            read_count++;
            `uvm_info("SCOREBOARD", $sformatf("Read count: %0d", read_count), UVM_MEDIUM);
            // If empty is not asserted but half is then this is a read from a half-full FIFO 
            if (mon_tx_rd.half) begin
                half_count_rd++;
                `uvm_info("SCOREBOARD", $sformatf("Read from half-full FIFO count: %0d", half_count_rd), UVM_MEDIUM);
            end
            // Push the read transaction onto the stack
            tx_stack_rd.push_back(mon_tx_rd);
            `uvm_info(get_type_name(), $sformatf("Scoreboard tx \t|  rd_en: %b  |  data_out: %h  |", mon_tx_rd.rd_en, mon_tx_rd.data_out), UVM_HIGH);
        end
   endfunction : write_port_b 

endclass 
