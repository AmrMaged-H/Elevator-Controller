-----------------------------------------------------------------------------------------------------
-- Module Name : GenCNT_En

-- Functionality :

-----------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY TwoSec_CNT IS
    GENERIC (
        n : NATURAL := 1;
        k : NATURAL := 1);
    PORT (
        clock : IN STD_LOGIC;
        rst_n : IN STD_LOGIC;
        Syn_RST : IN STD_LOGIC;
        En : IN STD_LOGIC;
        rollover : OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE RTL OF TwoSec_CNT IS
    SIGNAL Count_Int : STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
BEGIN

    PROCESS (clock, rst_n)
    BEGIN
        IF (rst_n = '0') THEN
            Count_Int <= (OTHERS => '0');
        ELSIF ((clock'EVENT) AND (clock = '1')) THEN

            IF (Syn_RST = '1') THEN
                Count_Int <= (OTHERS => '0');
            ELSIF (En = '1') THEN
                Count_Int <= Count_Int + '1';
            END IF;

        END IF;
    END PROCESS;

    PROCESS (Count_Int)
    BEGIN
        IF (unsigned(Count_Int) = to_unsigned(k, n)) THEN
            rollover <= '1';
        ELSE
            rollover <= '0';
        END IF;
    END PROCESS;

END RTL;