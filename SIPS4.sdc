# inform quartus that the clk port brings a 50MHz clock into our design so
    # that timing closure on our design can be analyzed
 
create_clock -name clk -period "50MHz" [get_ports clk]
 

# inform quartus that the LED output port has no critical timing requirements
	# its a single output port driving an LED, there are no timing relationships
	# that are critical for this

set_false_path -from * -to [get_ports LED[0]]
set_false_path -from * -to [get_ports LED[1]]
set_false_path -from * -to [get_ports LED[2]]
set_false_path -from * -to [get_ports LED[3]]
set_false_path -from * -to [get_ports LED[4]]
set_false_path -from * -to [get_ports LED[5]]
set_false_path -from * -to [get_ports LED[6]]
set_false_path -from * -to [get_ports LED[7]]
set_false_path -from [get_ports slide[0]] -to *
set_false_path -from [get_ports slide[1]] -to *
set_false_path -from [get_ports slide[2]] -to *
set_false_path -from [get_ports slide[3]] -to *
set_false_path -from [get_ports button[0]] -to *
set_false_path -from [get_ports button[1]] -to *
