module gpioemu_tb;

reg n_reset = 1;
reg srd = 0;
reg swr = 0;
reg clk = 0;

reg [15:0] saddress = 0;
reg [31:0] gpio_in = 0;
reg [31:0] sdata_in = 'h0;

wire [31:0] gpio_in_s_insp;
wire [31:0] gpio_out;
wire [31:0] sdata_out;


initial begin
	$dumpfile("gpioemu.vcd");
	$dumpvars(0, gpioemu_tb);
end

initial begin 
   forever begin
   #1 clk = ~clk;
end
end

initial begin
//reset
	# 1 n_reset = 1;
	# 5 n_reset = 0;
	# 5 n_reset = 1;

//reakcja modulu na podanie "zlych adresow"
	# 5 sdata_in = 32'd100;
	# 5 saddress = 16'hff;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd100;
	# 5 saddress = 16'hee;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd100;
	# 5 saddress = 16'hdd;
	# 5 srd = 1;
	# 5 srd = 0;

//Liczenie GCD dla A1 = 100, A2 = 25
	# 5 sdata_in = 32'd100;
	# 5 saddress = 16'hd8;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd25;
	# 5 saddress = 16'hdc;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 1 saddress = 16'he4;
	# 1 srd = 1;
	# 5 srd = 0;

	# 5 saddress = 16'he0;
	# 5 srd = 1;
	# 5 srd = 0;

//Liczenie GCD dla A1 = 56, A2 = 42
	# 5 sdata_in = 32'd56;
	# 5 saddress = 16'hd8;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd42;
	# 5 saddress = 16'hdc;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 1 saddress = 16'he4;
	# 1 srd = 1;
	# 5 srd = 0;

	# 5 saddress = 16'he0;
	# 5 srd = 1;
	# 5 srd = 0;

//Liczenie GCD dla A1 = 314080416, A2 = 7966496
	# 5 sdata_in = 32'd314080416;
	# 5 saddress = 16'hd8;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd7966496;
	# 5 saddress = 16'hdc;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 1 saddress = 16'he4;
	# 1 srd = 1;
	# 5 srd = 0;

	# 55 saddress = 16'he0;
	# 5 srd = 1;
	# 5 srd = 0;

//Liczenie GCD dla A1 =45296490 , A2 = 24826148
	# 50 sdata_in = 32'd45296490;
	# 5 saddress = 16'hd8;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd24826148;
	# 5 saddress = 16'hdc;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 1 saddress = 16'he4;
	# 1 srd = 1;
	# 5 srd = 0;

	# 25 saddress = 16'he0;
	# 5 srd = 1;
	# 5 srd = 0;

//Liczenie GCD dla A1 =4294967295 , A2 = 4294967295
	# 50 sdata_in = 32'd4294967295;
	# 5 saddress = 16'hd8;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 5 sdata_in = 32'd4294967295;
	# 5 saddress = 16'hdc;
	# 5 swr = 1;
	# 5 swr = 0;
	
	# 1 saddress = 16'he4;
	# 1 srd = 1;
	# 5 srd = 0;

	# 5 saddress = 16'he0;
	# 5 srd = 1;
	# 5 srd = 0;


	# 1000 $finish;
end

gpioemu e1(n_reset, saddress, srd, swr, sdata_in, sdata_out,
	gpio_in, gpio_latch, gpio_out, clk, gpio_in_s_insp);

initial begin
	$monitor("Time: %t, saddress = %h (%0d), gpio_out = %h (%0d), sdata_in = %h (%0d), sdata_out = %h (%0d)", $time, saddress, saddress, gpio_out, gpio_out,
		sdata_in, sdata_in, sdata_out, sdata_out);
end

endmodule
