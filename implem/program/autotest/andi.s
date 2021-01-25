# TAG = andi
	.text

	andi x31, x0, 0xff  
	andi x31, x0, 0x145

       	addi x1, x0, 0x27
	andi x31, x1, 0x27

	addi x1, x0, 0x145
	andi x31, x1, 0x27


	# max_cycle 50
	# pout_start
	# 00000000
	# 00000000
	# 00000027
	# 00000005
	# pout_end