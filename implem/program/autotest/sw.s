# TAG = sw
    .text
    
    addi x5, x0, 0x1
    slli x5, x5, 0xc            #x5 = 0x1000
    addi x5, x0, 0x50

    addi x1, x0, 0x78
    addi x2, x0, 0x2f

    sw x1, 0x0(x5)
    lw x31, 0x0(x5)

    sw x2, 0x4(x5)
    lw x31, 0x4(x5)


    # max_cycle 50
    # pout_start
    # 00000078
    # 0000002f
    # pout_end

    
