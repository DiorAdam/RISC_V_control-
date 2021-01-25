# TAG = sub
	.text

        sub x31, x0, x0

	addi x1, x0, 0x107
	sub x31, x1, x0

	addi x2, x0, 0x89
	sub x31, x1, x2

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000107
	# 0000007e
	# pout_end    
