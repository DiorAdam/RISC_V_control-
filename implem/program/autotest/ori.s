# TAG = ori
	.text

	ori x31, x0, 0xff         # Test yolo
	ori x31, x0, 0            # Test yolo
	ori x31, x0, 0x145        # Test yolo
	ori x31, x31, 0x27

	# max_cycle 50
	# pout_start
	# 000000ff
	# 00000000
	# 00000145
	# 00000167
	# pout_end
    