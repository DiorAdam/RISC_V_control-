# TAG = sll
    .text
    addi x1, x0, 0x29
    addi x2, x0, 0x4
    sll x31, x1, x2

    addi x2, x0, 0x2
    sll x31, x1, x2

    addi x1, x0, 0x20
    addi x2, x1, 0x3
    sll x31, x1, x2
   
    # max_cycle 50
    # pout_start
    # 00000290
    # 000000a4
    # 00000100
    # pout_end
