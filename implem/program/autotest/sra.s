# TAG = sra
    .text
    addi x1, x0, 0x290
    addi x2, x0, 0x4
    sra x31, x1, x2

    addi x1, x0, 0xf
    addi x2, x0, 0x2
    sra x31, x1, x2


    # max_cycle 50
    # pout_start
    # 00000029
    # 00000003
    # pout_end
