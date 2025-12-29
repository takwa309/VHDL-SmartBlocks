

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity loop_filter_P is
    generic (
        Kp : integer := 2   -- Gain proportionnel
    );
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        phase_diff : in  integer range -50 to 50;
        ctrl_out   : out integer range -500 to 500
    );
end loop_filter_P;

architecture Behavioral of loop_filter_P is
begin

    process(clk, reset)
    begin
        if reset = '1' then
            ctrl_out <= 0;
        elsif rising_edge(clk) then
            ctrl_out <= Kp * phase_diff;
        end if;
    end process;

end Behavioral;

--test

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity loop_filter_P_TB is
end loop_filter_P_TB;

architecture Behavioral of loop_filter_P_TB is

    component loop_filter_P
        generic (
            Kp : integer := 2
        );
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            phase_diff : in  integer range -50 to 50;
            ctrl_out   : out integer range -500 to 500
        );
    end component;

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal phase_diff : integer range -50 to 50 := 0;
    signal ctrl_out   : integer range -500 to 500;

    constant CLK_PERIOD : time := 10 ns;
    signal stop_sim : boolean := false;

begin

   
    UUT : loop_filter_P
        generic map (
            Kp => 3
        )
        port map (
            clk        => clk,
            reset      => reset,
            phase_diff => phase_diff,
            ctrl_out   => ctrl_out
        );

    -- Horloge
    clk_process : process
    begin
        while not stop_sim loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    
    stim_process : process
    begin
        -- Reset
        reset <= '1';
        wait for 30 ns;
        reset <= '0';

        -- Erreur de phase positive
        phase_diff <= 10;
        wait for 100 ns;

        -- Erreur de phase faible
        phase_diff <= 3;
        wait for 100 ns;

        -- Phase alignée
        phase_diff <= 0;
        wait for 100 ns;

        -- Erreur négative
        phase_diff <= -8;
        wait for 100 ns;

        -- Variation rapide (bruit simulé)
        phase_diff <= 5;
        wait for 20 ns;
        phase_diff <= -5;
        wait for 20 ns;
        phase_diff <= 4;
        wait for 20 ns;
        phase_diff <= -4;
        wait for 100 ns;

        stop_sim <= true;
        wait;
    end process;

end Behavioral;

