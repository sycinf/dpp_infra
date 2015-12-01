`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:57:59 03/05/2015 
// Design Name: 
// Module Name:    occupancy_counter_shift_out 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module occupancy_counter#
(
	// counter width = x, the fifo depth = 2^x-1
	parameter COUNTER_WIDTH = 6,
	// how many bits used to address the histogram slot
	// 2 bits -- 4 slots
	// 3 bits -- 8 slots
	parameter HISTOGRAM_STEP_BITS = 2,
	parameter integer C_S_AXI_DATA_WIDTH	= 32
)
(
    input wire [COUNTER_WIDTH-1:0]data_count,
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [(C_S_AXI_DATA_WIDTH/32)+3-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [(C_S_AXI_DATA_WIDTH/32)+3-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire  S_AXI_RREADY	
);

	localparam integer C_S_AXI_ADDR_WIDTH	= (C_S_AXI_DATA_WIDTH/32)+3;
// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer NUM_HIS_COUNT = 2**HISTOGRAM_STEP_BITS;
	//raw count of each slot
	reg [C_S_AXI_DATA_WIDTH-1:0] his_counter [NUM_HIS_COUNT-1:0];
	reg [C_S_AXI_DATA_WIDTH-1:0] remain_0_cycles; // -- this counts the # of cycles the input remain as 0,
	                                               // it gets reset every time input not equal to 0
	// for 32 bit data                                               
	// write to 4'b0000, reset everything 
	// write to 4'b0100, capture the current value of all the counters
	//                   the lowest bin would subtract remain_0_cycles
	// write to 4'b1000, the address of the next read
	// read from 4'b0100, the actual value
	// read from 4'b0000, the actual value 
	reg [C_S_AXI_DATA_WIDTH-1:0] read_out_counters [NUM_HIS_COUNT-1:0];
	
	
	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	wire reset_everything;
	reg counter_non_zero;
	wire some_his_counter_saturate;
	always@(posedge S_AXI_ACLK)
		begin
			if(S_AXI_ARESETN==0)
				counter_non_zero <= 0;
			else
				begin 
					if(reset_everything |some_his_counter_saturate)
						counter_non_zero <= 0;
					else 
						if(data_count!=0)
							counter_non_zero <= 1;							
				end
		end
	// it is totally possible that 
	// non of the his counters are saturated
	// in which case, the lowest bin will
	// just keep increasing after done, we
	// want to make sure this increase is accounted for
	// 
    wire start_incre_his;
	wire stop_incre_his;
	assign start_incre_his = counter_non_zero;
	assign stop_incre_his = some_his_counter_saturate;
		
	always@(posedge S_AXI_ACLK)
		begin
			if(S_AXI_ARESETN==0)
				remain_0_cycles <= 0;
			else
				begin
					if(data_count!=0)
						remain_0_cycles <= 0;
					else if(~(&remain_0_cycles)& ~(&his_counter[0]) & (start_incre_his & !stop_incre_his))// we increase until it saturate
						remain_0_cycles <= remain_0_cycles+1;
				end
		end
	
	wire slv_reg_wren;
	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
	wire capture_all_counter;
	// the number of bits of the read address is HISTOGRAM_STEP_BITS+1
	wire write_read_address;
	reg [HISTOGRAM_STEP_BITS-1:0] address_for_read;
	assign reset_everything = slv_reg_wren &(axi_awaddr == 0);
	// write to 100
	assign capture_all_counter = slv_reg_wren &(axi_awaddr[C_S_AXI_ADDR_WIDTH-2] == 1'b1);
	// write to 1000
	assign write_read_address = slv_reg_wren &(axi_awaddr[C_S_AXI_ADDR_WIDTH-1] == 1'b1);
	
	always@(posedge S_AXI_ACLK)
		begin
			if(S_AXI_ARESETN==0)
				address_for_read <=0;
			else if(write_read_address)
				address_for_read <= S_AXI_WDATA[HISTOGRAM_STEP_BITS-1:0];
		end
	
	wire [NUM_HIS_COUNT-1:0] current_count_bin;
	wire [NUM_HIS_COUNT-1:0] current_count_sat;
	assign some_his_counter_saturate = |current_count_sat;
	
	wire [HISTOGRAM_STEP_BITS-1:0]counter_top_bits;
	
	assign counter_top_bits = data_count[COUNTER_WIDTH-1:COUNTER_WIDTH-HISTOGRAM_STEP_BITS];
	
	genvar counter_ind;
	generate
		for(counter_ind=0; counter_ind<NUM_HIS_COUNT; counter_ind=counter_ind+1)
			begin: couterGen
				assign current_count_bin[counter_ind] = (counter_top_bits == counter_ind);
				assign current_count_sat[counter_ind] = &(his_counter[counter_ind]);
			
				always@(posedge S_AXI_ACLK)
					begin
						if(S_AXI_ARESETN==0)
							his_counter[counter_ind] <=0;
						else
							// write from axilite
							if(reset_everything)
								his_counter[counter_ind] <=0;
							else if(start_incre_his & !stop_incre_his)
								if(current_count_bin[counter_ind])
									his_counter[counter_ind] <= his_counter[counter_ind]+1;						
					end
			end
	endgenerate
	generate 
	    for (counter_ind=1; counter_ind<NUM_HIS_COUNT; counter_ind=counter_ind+1)
        // get things into the read_out_counters
	 	     begin: counterReadout				
				always@(posedge S_AXI_ACLK)
					begin
						if(S_AXI_ARESETN==0)
							read_out_counters[counter_ind] <=0;
						else
							begin
								if(reset_everything)
									read_out_counters[counter_ind] <=0;
								else if(capture_all_counter)
									read_out_counters[counter_ind] <=his_counter[counter_ind];						
							end
					end	
			end
	endgenerate
	// the zeroth bin is special
	always@(posedge S_AXI_ACLK)
	   begin
            if(S_AXI_ARESETN==0)
                read_out_counters[0] <=0;
            else
                begin
                   if(reset_everything)
                       read_out_counters[0] <=0;
                   else if(capture_all_counter)
                       read_out_counters[0] <=his_counter[0]-remain_0_cycles;                        
                end
        end

	
	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   
		// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    


	// now read from the his_counters
	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	wire slv_reg_rden;
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	
	wire [HISTOGRAM_STEP_BITS-1:0] selectCounter;
	assign selectCounter = address_for_read[HISTOGRAM_STEP_BITS-1:0];
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	always @(*)
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      reg_data_out <= 0;
	    end 
	  else
	    begin
			//if(axi_araddr[3:0] == 4'b1100 & address_for_read[HISTOGRAM_STEP_BITS])
			//	reg_data_out <= read_out_counters[NUM_HIS_COUNT];
			//else
			// we can read the actual counter or read the address we have just written
			// if we read from address 0 
			if(axi_araddr == 0)
				reg_data_out <= read_out_counters[selectCounter];
			else if(axi_araddr[C_S_AXI_ADDR_WIDTH-2] == 1'b1)
				reg_data_out <= address_for_read;
			else
				reg_data_out <= 32'bx;
	    end   
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end  

	
endmodule

