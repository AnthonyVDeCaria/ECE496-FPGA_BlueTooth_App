/*
	Anthony De Caria - October 15, 2016

	This module creates a UART receiver.
	
	Algorithm:
		#Idle
			If the rx_line goes low
				Start the timer #Double_Check
					If after cpd/2 time rx_line is still low
						#Reset_Timer
						#Wait_for_Timer
							If i == 8
								Done
							Else
								If the timer goes off (cpd)
									rx_data[i] = rx_line - #Update_rx_data
									i++
									#Go back to #Reset_Timer
								Else
									Wait for it - #Wait_for_Timer
					Else
						Go back to #Idle
			Else
				Say in #Idle
*/

module UART_rx(clk, resetn, cycles_per_databit, rx_line, rx_data, collecting_data, rx_data_valid);
	/*
		I/Os
	*/
	input clk, resetn;	
	input [9:0] cycles_per_databit; //Allows for 1024 cycles between each databit
	input rx_line;

	output collecting_data, rx_data_valid;
	output reg [7:0] rx_data;
	
	/*
		FSM
	*/
	reg [2:0] urx_curr, urx_next;
	parameter Idle = 3'b000, Double_Check = 3'b001, Reset_Timer = 3'b010, Wait_for_Timer = 3'b011, Update_rx_data = 3'b100, Done = 3'b101;
	
	/*
		Timer 
	*/
	wire [9:0] timer, n_timer;
	wire l_r_timer, r_r_timer;
	wire at_halftime, at_cpd;
	
	assign l_r_timer = ((urx_curr == Double_Check) & (~at_halftime)) | ((urx_curr == Wait_for_Timer) & (~at_cpd));
	assign r_r_timer = ~(~resetn | (urx_curr == Idle) | (urx_curr == Reset_Timer) ) ;
	
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
	
	assign l_r_i = (urx_curr == Update_rx_data);
	assign r_r_i = ~(~resetn | (urx_curr == Idle));
	
	adder_subtractor_4bit a_i(.a(i), .b(4'b0001), .want_subtract(1'b0), .c_out(), .s(n_i) );
	register_4bit_enable_async r_i(.clk(clk), .resetn(r_r_i), .enable(l_r_i), .select(l_r_i), .d(n_i), .q(i) );
	
	/*
		Adding Data
	*/
	always@(*)
	begin
		if(urx_curr == Update_rx_data)
			rx_data[i] = rx_line;
	end
	
	/*
		FSM
	*/
	always@(*)
	begin
		case(urx_curr)
			Idle: 
			begin
				if(!rx_line)
				begin
					urx_next = Double_Check;
				end
				else
				begin
					urx_next = Idle;
				end
			end
			
			Double_Check:
			begin
				if(at_halftime)
				begin
					if(!rx_line)
					begin
						urx_next = Reset_Timer;
					end
					else
					begin
						urx_next = Idle;
					end
				end
				else
				begin
					urx_next = Double_Check;
				end
			end
			
			Reset_Timer:
			begin
				urx_next = Wait_for_Timer;
			end
			
			Wait_for_Timer:
			begin
				if(i[3] == 1'b1)
					begin
						urx_next = Done;
					end
					else
					begin
						if(at_cpd)
							urx_next = Update_rx_data;
						else
							urx_next = Wait_for_Timer;
					end
			end
			
			Update_rx_data:
			begin
				urx_next = Reset_Timer;
			end
			
			Done:
			begin
				urx_next = Idle;
			end
			
			default:
			begin
				urx_next = Idle;
			end
		endcase
	end
	
	always@(posedge clk or negedge resetn)
	begin
		if(!resetn) 
			urx_curr <= Idle; 
		else 
			urx_curr <= urx_next;
	end
	
	assign collecting_data = ~((urx_curr == Idle) | (urx_curr == Done) | (urx_curr == Double_Check));
	assign rx_data_valid = (urx_curr == Done);
	
endmodule

