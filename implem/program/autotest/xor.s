# TAG = xor
	.text
	
	addi x1, x0, 0xff
	xor x31, x0, x1
	
	addi x1, x0, 0x0         
	xor x31, x0, x1

	addi x1, x0, 0x145           
	xor x31, x0, x1

	addi x1, x0, 0x27       
	xor x31, x31, x1

	# max_cycle 50
	# pout_start
	# 000000ff
	# 00000000
	# 00000145
	# 00000162
	# pout_end

