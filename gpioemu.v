//Autor: 			Jakub Pasierb
//na podstawie materiałów dostarczonych przez 
//prowadzącego: 	Aleksander Pruszkowski

/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */

module gpioemu(n_reset,                   //magistrala z CPU
    saddress[15:0], srd, swr, 
    sdata_in[31:0], sdata_out[31:0], 
    gpio_in[31:0], gpio_latch,          //styk z GPIO - in
    gpio_out[31:0],                     //styk z GPIO = out
    clk,                                //sygnaly opcjonalne - zegar 1KHz
    gpio_in_s_insp[31:0]);              //sygnaly testowe

    input           clk;
    input           n_reset;
    input           gpio_latch;     //zapis danych na gpio_in
    input           srd;            //odczyt przez CPU z mag. danych
    input           swr;            //zapis przez CPU do mag. danych 
    
    input [15:0]    saddress;       //magistrala - adres
    input [31:0]    sdata_in;       //magistrala wejsciowa CPU
	input [31:0]    gpio_in;        //dane z peryferii wejscie do modulu 
	
    output[31:0]    sdata_out;      //magistrala wyjsciowa z CPU
	output[31:0]    gpio_out;       //dane wyjsciowe do peryferii (laczone np.: z LED'ami)
    output[31:0]    gpio_in_s_insp; //debuging
	
    reg [31:0]      sdata_out_s;      //stan magistrali danych - wyjscie
    reg [31:0]      gpio_in_s;      //stan peryferii wyjsciowych (do polaczenia z np.: klawiszami)
    reg [31:0]      gpio_out_s;     //stan peryferii wejsciowych (stan wyjsc - ale nie laczony z np.: LED'ami)
	

//Sygnały dodane na potrzeby zadania
	reg [31:0] S;
	reg [31:0] A1;
	reg [31:0] A2;
	reg [31:0] W;

//stworzenie 3 stanow automatu
	reg [3:0] state;
	localparam [3:0]	idle 	= 	'h0,
						check 	= 	'h2,
						dec 	=   'h3,
						res		=	'h4;
	
//wystawianie wartosci na wyjscia
	assign sdata_out = sdata_out_s;
	assign gpio_out = {24'h0,gpio_out_s[7:0]};
	assign gpio_in_s_insp = gpio_in_s;

//Zerowanie wszystkich sygnałów na reset
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
	
//sprawdzanie adresów, modyfikacja wartosci oraz rozpoczecie pracy algorytmu
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
	
// Implementacja algorytmu Euklidesa oraz logiki stanów
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