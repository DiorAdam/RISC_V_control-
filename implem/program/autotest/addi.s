# TAG = addi
    .text

    addi x31, x0, 0        # Test yolo
    addi x31, x31, 0x1     # Test yolo
    addi x31, x31, 0x2     # Test yolo
    addi x31, x31, 0x41    # Test yolo

    # max_cycle 50
    # pout_start
    # 00000000
    # 00000001
    # 00000003
    # 00000044
    # pout_end