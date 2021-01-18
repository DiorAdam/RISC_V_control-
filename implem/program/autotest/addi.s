# TAG = addi

.text

addi x31, x0, 0;
addi x31, x31, 0x1;
addi x31, x31, 0x2;
addi x31, x31, 0x41;

# max_cycle 50
	# pout_start
	# 00000000
	# 00000001
	# 00000003
    # 00000044
	# pout_end