# TAG = srl
    .text
    addi x1, x0, 0x290000
    addi x2, x0, 0x4
    srl x31, x1, x2

    addi x2, x0, 0x2
    srl x31, x1, x2

    addi x1, x0, 0x100
    addi x2, x0, 0x3
    srl x31, x1, x2

    # max_cycle 50
    # pout_start 
    # 00029000
    # 000a4000
    # 0000001f
    # pout_end



