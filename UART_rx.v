/*
	Anthony De Caria - October 15, 2016

	This module creates a UART receiver.
*/

module UART_rx(clk, resetn, cycles_per_databit, rx_line, rx_data, rx_data_valid);
	/*
		I/Os
	*/
	input clk, resetn;	
	input [9:0] cycles_per_databit; //Allows for 1024 cycles between each databit
	input rx_line;

	output rx_data_valid;
	output reg [7:0] rx_data;
	
	/*
		FSM
	*/
	reg [2:0] prev, curr, next;
	parameter Idle = 3'b000, Double_Check = 3'b001, Collect_Data = 3'b010, Add_i = 3'b011, Done = 3'b100;
	
	/*
		Timer 
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer;
	wire at_halftime, at_cpd;
	
	assign l_r_timer = ((curr == Double_Check) & (~at_halftime)) | ((curr == Collect_Data) & (~at_cpd));
	assign r_r_timer = ~(~resetn | (curr == Idle) | ( (prev == Double_Check) & (curr == Collect_Data)) | (curr == Add_i) ) ;
	
	adder_subtractor_10bit a_timer(.a(timer), .b(10'b0000000001), .want_subtract(1'b0), .c_out(), .s(n_timer) );
	register_10bit_enable_async r_timer(.clk(clk), .resetn(r_r_timer), .enable(l_r_timer), .select(l_r_timer), .d(n_timer), .q(timer) );
	
	wire [8:0]half_time;
	assign half_time = cycles_per_databit >> 1; //cycles_per_databit / 2
	
	assign at_halftime = (timer == half_time) ? 1'b1: 1'b0;
	assign at_cpd = (timer == cycles_per_databit) ? 1'b1: 1'b0;	
	
	/*
		i
	*/
	wire [3:0] i, n_i;
	wire l_r_i, r_r_i;
	
	assign l_r_i = (curr == Add_i);
	assign r_r_i = ~(~resetn | (curr == Idle));
	
	adder_subtractor_4bit a_i(.a(i), .b(4'b0001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_4bit_enable_async r_i(.clk(clk), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		Adding Data
	*/
	wire update_rxdata;
	assign update_rxdata = (curr == Collect_Data) & at_cpd & (i[3] == 1'b0);
	
	always@(*)
	begin
		if(curr == Idle)
			rx_data = 8'h00;
		if(update_rxdata);
			rx_data[i] = rx_line;
	end
	
	/*
		FSM
	*/
	
	always@(*)
	begin
		case(curr)
			Idle: 
			begin
				if(!rx_line)
				begin
					prev = Idle;
					next = Double_Check;
				end
				else
				begin
					prev = Idle;
					next = Idle;
				end
			end
			end
			
			Double_Check:
			begin
				if(at_halftime)
				begin
					if(!rx_line)
					begin
						prev = Double_Check;
						next = Collect_Data;
					end
					else
					begin
						prev = Double_Check;
						next = Idle;
					end
				end
				else
				begin
					prev = Double_Check;
					next = Double_Check;
				end
			end
			
			Collect_Data:
			begin
				if(!at_cpd)
				begin
					prev = Collect_Data;
					next = Collect_Data;
				end
				else
				begin
					if(i[3] == 0)
					begin
						prev = Collect_Data;
						next = Add_i;
					end
					else
					begin
						prev = Collect_Data;
						next = Done;
					end
				end
			end
			
			Add_i:
			begin
				prev = Add_i;
				next = Collect_Data;
			end
			
			Done:
			begin
				if(start)
				begin
					prev = Done;
					next = Done;
				end
				else
				begin
					prev = Done;
					next = Idle;
				end
			end
		endcase
	end
	
	always@(posedge clk or negedge resetn)
	begin
		if(!resetn) 
			curr <= Idle; 
		else 
			curr <= next;
	end
	
	assign rx_data_valid = (curr == Done);
	
endmodule

