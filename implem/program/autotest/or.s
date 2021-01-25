# TAG = or
	.text

	addi x1, x0, 0xff
	or x31, x1, x0

	addi x1, x0, 0x0
	or x31, x1, x0

	addi x1, x0, 0x145
	or x31, x1, x0

	addi x1, x0, 0x27
	or x31, x1, x31

	# max_cycle 50
	# pout_start
	# 000000ff
	# 00000000
	# 00000145
	# 00000167
	# pout_end