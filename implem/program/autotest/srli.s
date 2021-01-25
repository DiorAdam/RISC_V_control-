# TAG = srli
    .text
    addi x1, x0, 0x290
    srli x31, x1, 0x4

    addi x1, x0, 0x100
    srli x31, x1, 0x3

    # max_cycle 50
    # pout_start
    # 00000029
    # 00000020
    # pout_end
