# TAG = lw
    .text

    auipc x29, 0
    add x30, x1, x2
    lw x31, 0x4(x29)

    auipc x29, 0
    add x30, x3, x4
    lw x31, 0x4(x29)

    auipc x29, 0
    lw x31, 0x10(x29)

    add x30, x5, x6
    add x30, x5, x6
    add x30, x5, x6
    add x30, x5, x6
    

    # max_cycle 50
    # pout_start
    # 00208f33
    # 00418F33
    # 00628f33
    # pout_end