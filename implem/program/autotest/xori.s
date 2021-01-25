# TAG = xori
	.text

	xori x31, x0, 0xff         
	xori x31, x0, 0            
	xori x31, x0, 0x145        
	xori x31, x31, 0x27

	# max_cycle 50
	# pout_start
	# 000000ff
	# 00000000
	# 00000145
	# 00000162
	# pout_end
