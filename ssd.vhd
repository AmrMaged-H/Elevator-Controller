LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ssd IS
    PORT (
        SW0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        OUT_SEG0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ssd;

ARCHITECTURE Behavior OF ssd IS

BEGIN
    PROCESS (SW0)
    BEGIN
        CASE(SW0) IS

            WHEN "0000" =>
            OUT_SEG0 <= "1000000";
            WHEN "0001" =>
            OUT_SEG0 <= "1111001";
            WHEN "0010" =>
            OUT_SEG0 <= "0100100";
            WHEN "0011" =>
            OUT_SEG0 <= "0110000";
            WHEN "0100" =>
            OUT_SEG0 <= "0011001";
            WHEN "0101" =>
            OUT_SEG0 <= "0010010";
            WHEN "0110" =>
            OUT_SEG0 <= "0000010";
            WHEN "0111" =>
            OUT_SEG0 <= "1111000";
            WHEN "1000" =>
            OUT_SEG0 <= "0000000";
            WHEN "1001" =>
            OUT_SEG0 <= "0010000";

            WHEN OTHERS =>
            OUT_SEG0 <= "0000000";

        END CASE;
    END PROCESS;
END Behavior;