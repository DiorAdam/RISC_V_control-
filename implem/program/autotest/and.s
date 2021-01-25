 # TAG = and
	.text

	addi x1, x0, 0xff
	and x31, x0, x1
	
	addi x1, x0, 0x145
	and x31, x0, x1

       	addi x1, x0, 0x27
	addi x2, x0, 0x27
	and x31, x1, x2

	addi x1, x0, 0x145
	addi x2, x0, 0x27
	and x31, x1, x2


	# max_cycle 50
	# pout_start
	# 00000000
	# 00000000
	# 00000027
	# 00000005
	# pout_end