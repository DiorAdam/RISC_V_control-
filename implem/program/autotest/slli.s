# TAG = slli
    .text
    addi x1, x0, 0x29
    slli x31, x1, 0x4

    addi x1, x0, 0x20
    slli x31, x1, 0x3

    # max_cycle 50
    # pout_start
    # 00000290
    # 00000100
    # pout_end
    
    