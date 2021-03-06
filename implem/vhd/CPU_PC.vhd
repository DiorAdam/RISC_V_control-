library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_AND,
        S_OR,
        S_ANDI,
        S_XOR,
        S_XORI,
        S_SUB,
        S_ORI,
        S_SRL,
        S_SLL,
        S_SRA,
	    S_SRLI,
        S_SLLI,
        S_SRAI,
        S_AUIPC,
        S_AUIPC_exit,
        S_LW,
        S_LW_rm,
        S_LW_wm,
        S_SW,
        S_SW_wm,
        S_SW_exit
    );

    signal state_d, state_q : State_type;
    signal cmd_cs : PO_cs_cmd;


    function arith_sel (IR : unsigned( 31 downto 0 ))
        return ALU_op_type is
        variable res : ALU_op_type;
    begin
        if IR(30) = '0' or IR(5) = '0' then
            res := ALU_plus;
        else
            res := ALU_minus;
        end if;
        return res;
    end arith_sel;

    function logical_sel (IR : unsigned( 31 downto 0 ))
        return LOGICAL_op_type is
        variable res : LOGICAL_op_type;
    begin
        if IR(12) = '1' then
            res := LOGICAL_and;
        else
            if IR(13) = '1' then
                res := LOGICAL_or;
            else
                res := LOGICAL_xor;
            end if;
        end if;
        return res;
    end logical_sel;

    function shifter_sel (IR : unsigned( 31 downto 0 ))
        return SHIFTER_op_type is
        variable res : SHIFTER_op_type;
    begin
        res := SHIFT_ll;
        if IR(14) = '1' then
            if IR(30) = '1' then
                res := SHIFT_ra;
            else
                res := SHIFT_rl;
            end if;
        end if;
        return res;
    end shifter_sel;

begin

    cmd.cs <= cmd_cs;

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.rst               <= 'U';
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_or;
        cmd.ALU_Y_sel         <= ALU_Y_rf_rs2;

        cmd.SHIFTER_op        <= SHIFT_rl;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= DATA_from_pc;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_pc;

        cmd.PC_X_sel          <= PC_X_cst_x00;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_cst_x04;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= 'U';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd_cs.CSR_we            <= UNDEFINED;

        cmd_cs.TO_CSR_sel        <= UNDEFINED;
        cmd_cs.CSR_sel           <= UNDEFINED;
        cmd_cs.MEPC_sel          <= UNDEFINED;

        cmd_cs.MSTATUS_mie_set   <= 'U';
        cmd_cs.MSTATUS_mie_reset <= 'U';

        cmd_cs.CSR_WRITE_mode    <= UNDEFINED;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                state_d <= S_Error;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_ce <= '1';
                state_d <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>

                if status.IR(6 downto 0) = "0110111" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                
                elsif status.IR(6 downto 0) = "0110011"
                and status.IR(14 downto 12) = "000" 
                and status.IR(31 downto 25) = "0000000" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADD;

                elsif status.IR(6 downto 0) = "0010011" 
                and status.IR(14 downto 12) = "000" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ADDI;
                
                elsif status.IR(6 downto 0) = "0110011" 
                and status.IR(14 downto 12) = "101" 
                and status.IR(31 downto 25) = "0000000" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRL;

                elsif status.IR(6 downto 0) = "0010011" 
                and status.IR(14 downto 12) = "110" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ORI;
	
                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "001" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLL;

                elsif status.IR(6 downto 0) = "0000011" and status.IR(14 downto 12) = "010" then
                    -- PC <- PC + 4
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LW;
                
                elsif status.IR(6 downto 0) = "0010111" then
                    state_d <= S_AUIPC;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRA;


                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRLI;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "001" and status.IR(31 downto 25) = "0000000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SLLI;


                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "101" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SRAI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_AND;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "110" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_OR;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ANDI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "100" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XOR;

                elsif status.IR(6 downto 0) = "0010011" and status.IR(14 downto 12) = "100" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_XORI;

                elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "000" and status.IR(31 downto 25) = "0100000" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SUB;
                
                elsif status.IR(6 downto 0) = "0100011" and status.IR(14 downto 12) = "010" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SW;
                else
                    state_d <= S_Error; -- Pour d´etecter les rat´es du d´ecodage
                end if;

                    

                -- Décodage effectif des instructions,
                -- à compléter par vos soins

---------- Instructions avec immediat de type U ----------

            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                -- rd <- PC + ImmU
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- PC <- PC + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                --next state
                state_d <= S_AUIPC_exit;

            when S_AUIPC_exit =>
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
                

---------- Instructions arithmétiques et logiques ----------
            
            when S_ADDI => 
                --alu operation
                cmd.ALU_op <= ALU_plus;
                --rd = rs1 + immI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ADD =>
                --alu operation
                cmd.ALU_op <= ALU_plus;
                --rd = rs1 + immI
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;


            when S_ORI =>
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.ALU_Y_sel <= ALU_Y_immI;		
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                 -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;


            when S_AND =>
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;  

            when S_OR =>
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch; 

            when S_ANDI =>
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_XOR =>
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;


            when S_XORI =>
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.ALU_Y_sel <= ALU_Y_immI;		
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

        
            when S_SUB =>
                -- rd <- rs1 - rs2
                cmd.ALU_op <= ALU_minus;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                        cmd.ADDR_sel <= ADDR_from_pc;
                        cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;


            when S_SRL =>
                -- rd <- décalage a droite rs1 par rs2
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <=SHIFT_rl;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_SLL =>
                -- rd <- décalage a gauche rs1 par rs2
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <=SHIFT_ll;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_SRA =>
                -- rd <- décalage a droite rs1 par rs2 avec signe
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <=SHIFT_ra;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_SRLI =>
                -- rd <- décalage a gauche rs1 par i avec signe
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <=SHIFT_rl;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]	
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_SLLI =>
                -- rd <- décalage a gauche rs1 par i avec signe
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <=SHIFT_ll;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

            when S_SRAI =>
                -- rd <- décalage a droite rs1 par i avec signe
                cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <=SHIFT_ra;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                        cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

        

---------- Instructions de saut ----------


---------- Instructions de chargement à partir de la mémoire ----------
            
            when S_LW =>
                --calculating memory address
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LW_rm;
            
            when S_LW_rm =>
                --reading memory data
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_LW_wm;

            when S_LW_wm =>
                --writing memory data on destination register
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

                

            
---------- Instructions de sauvegarde en mémoire ----------
            when S_SW =>
                --calculating memory address
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';

                --next state
                state_d <= S_SW_wm;      
                
            when S_SW_wm =>
                --writing memory data
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                --next state
                state_d <= S_SW_exit;    
                
            when S_SW_exit =>
                --lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                --next state
                state_d <= S_Fetch;

---------- Instructions d'accès aux CSR ----------

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
