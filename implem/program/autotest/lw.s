# TAG = lw
    .text

    auipc x29, 0
    lw x31, 0x14(x29)
    lw x31, 0x24(x29)

    add x30, x1, x2
    add x30, x1, x2
    add x30, x1, x2

    add x30, x3, x4
    add x30, x3, x4
    add x30, x3, x4
    add x30, x3, x4
    add x30, x3, x4

    # max_cycle 50
    # pout_start
    # 00208f33
    # 00418F33
    # pout_end