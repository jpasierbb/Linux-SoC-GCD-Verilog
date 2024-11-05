/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */

module gpioemu(n_reset,                   // bus from CPU
    saddress[15:0], srd, swr, 
    sdata_in[31:0], sdata_out[31:0], 
    gpio_in[31:0], gpio_latch,          // GPIO contact - in
    gpio_out[31:0],                     // GPIO contact - out
    clk,                                // optional signals - 1KHz clock
    gpio_in_s_insp[31:0]);              // test signals

    input           clk;
    input           n_reset;
    input           gpio_latch;     // writing data to gpio_in
    input           srd;            // reading by CPU from data bus
    input           swr;            // writing by CPU to data bus 
    
    input [15:0]    saddress;       // bus - address
    input [31:0]    sdata_in;       // CPU input bus
	input [31:0]    gpio_in;        // data from the peripherals input to the module 
	
    output[31:0]    sdata_out;      // CPU output bus
	output[31:0]    gpio_out;       // output data to peripherals (connected e.g. to LEDs)
    output[31:0]    gpio_in_s_insp; // debugging
	
    reg [31:0]      sdata_out_s;    // data bus status - output
    reg [31:0]      gpio_in_s;      // output peripherals status (for connection with e.g. keys)
    reg [31:0]      gpio_out_s;     // input peripherals status (output status - but not connected with e.g. LEDs)
	

// Signals added for the task
	reg [31:0] S;
	reg [31:0] A1;
	reg [31:0] A2;
	reg [31:0] W;

// Creation of 3 machine states
	reg [3:0] state;
	localparam [3:0]	idle 	= 	'h0,
						check 	= 	'h2,
						dec 	=   'h3,
						res		=	'h4;
	
// Outputting values
	assign sdata_out = sdata_out_s;
	assign gpio_out = {24'h0,gpio_out_s[7:0]};
	assign gpio_in_s_insp = gpio_in_s;

// Zeroing all signals to reset
	always @(negedge n_reset)
			begin           
				state			<= idle;
				S				<= 32'h0;
				sdata_out_s		<= 32'h0;
				gpio_in_s		<= 32'h0;
				gpio_out_s		<= 32'h0;
				A1				<= 32'h0;
				A2				<= 32'h0;
				W				<= 32'h0;			
			end 
	
// Checking addresses, modifying values ​​and starting the algorithm
	always@(posedge srd) begin
		if(saddress == 16'hd8) sdata_out_s <= A1;
		if(saddress == 16'hdc) sdata_out_s <= A2;
		if(saddress == 16'he0) sdata_out_s <= W;
		if(saddress == 16'he4) sdata_out_s <= S;
	end
	
	always@(posedge swr) begin
		if(saddress == 16'hd8) A1 <= sdata_in;
		if(saddress == 16'hdc) begin
			A2 <= sdata_in;
			gpio_out_s <= gpio_out_s + 1'b1;
			state <= check;
			S[3] <= 1'b1;
		end
	end
	
// Implementation of the Euclidean algorithm and state logic
	always@(posedge clk) begin
		case(state)
			idle : 	;
			check : begin
						if(A2 == 0) state <= res;
						else state <= dec;
					end
			dec : 	begin
						A2 <= A1 % A2;
						A1 <= A2;
						state <= check;
					end
			res :	begin
					W <= A1;
					S[3] <= 1'b0;
					state <= idle;
					end
		default: state <= idle;
		endcase
	end

endmodule
