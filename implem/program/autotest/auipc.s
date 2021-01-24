# TAG = auipc
    .text

    auipc x31, 0
    add x30, x1, x2
    auipc x31, 0
    add x30, x3, x4

    # max_cycle 50
    # pout_start 
    # 00208f33
    # 00418f33
    # pout_end