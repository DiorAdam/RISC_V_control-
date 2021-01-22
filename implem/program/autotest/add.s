# TAG = add
        .text
        
        addi x31, x0, 0x89 
        addi x30, x0, 0x107
        add x31, x30, x31       
        add x31, x30, x0         
        add x31, x0, x0

        # max_cycle 50
        # pout_start
        # 00000089
        # 00000190
        # 00000107
        # 00000000
        # pout_end