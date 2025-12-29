

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity phase_comparator is
    Port (
        clk_fast   : in  std_logic;      -- horloge de mesure
        clk_ref    : in  std_logic;      -- référence
        clk_fb     : in  std_logic;      -- vco
        reset      : in  std_logic;
        phase_diff : out integer range -99 to 99
    );
end phase_comparator;

architecture Behavioral of phase_comparator is

    signal time_counter : integer range 0 to 99 := 0;

    signal ref_latch : integer range 0 to 99 := 0;
    signal fb_latch  : integer range 0 to 99 := 0;

    signal clk_ref_d : std_logic := '0';
    signal clk_fb_d  : std_logic := '0';

begin

    -- Compteur de temps (base commune)
    process(clk_fast, reset)
    begin
        if reset = '1' then
            time_counter <= 0;
        elsif rising_edge(clk_fast) then
            if time_counter = 99 then
                time_counter <= 0;
            else
                time_counter <= time_counter + 1;
            end if;
        end if;
    end process;

    -- front montant clk_ref
    process(clk_fast, reset)
    begin
        if reset = '1' then
            clk_ref_d <= '0';
            ref_latch <= 0;
        elsif rising_edge(clk_fast) then
            clk_ref_d <= clk_ref;
            if (clk_ref = '1') and (clk_ref_d = '0') then
                ref_latch <= time_counter;
            end if;
        end if;
    end process;

    -- front montant clk_fb
    process(clk_fast, reset)
    begin
        if reset = '1' then
            clk_fb_d <= '0';
            fb_latch <= 0;
        elsif rising_edge(clk_fast) then
            clk_fb_d <= clk_fb;
            if (clk_fb = '1') and (clk_fb_d = '0') then
                fb_latch <= time_counter;
            end if;
        end if;
    end process;

-- calcule modulo 100
process(ref_latch, fb_latch)
    variable diff : integer;
begin
    diff := fb_latch - ref_latch;

    
    if diff > 50 then
        diff := diff - 100;
    elsif diff < -50 then
        diff := diff + 100;
    end if;

    phase_diff <= diff;
end process;


end Behavioral;

--testbanch

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity phase_comparator_TB is
end phase_comparator_TB;

architecture Behavioral of phase_comparator_TB is

    component phase_comparator
        Port (
            clk_fast   : in  std_logic;
            clk_ref    : in  std_logic;
            clk_fb     : in  std_logic;
            reset      : in  std_logic;
            phase_diff : out integer range -99 to 99
        );
    end component;

    signal clk_fast   : std_logic := '0';
    signal clk_ref    : std_logic := '0';
    signal clk_fb     : std_logic := '0';
    signal reset      : std_logic := '1';
    signal phase_diff : integer range -99 to 99;

    constant FAST_PERIOD : time := 2 ns;   -- horloge rapide Résolution de phase = T_fast / T_ref × 360°
    constant REF_PERIOD  : time := 20 ns;  -- 50 MHz
    signal   FB_PERIOD   : time := 20 ns;

    signal stop_sim : boolean := false;

begin

    
    UUT : phase_comparator
        port map (
            clk_fast   => clk_fast,
            clk_ref    => clk_ref,
            clk_fb     => clk_fb,
            reset      => reset,
            phase_diff => phase_diff
        );

    
    clk_fast_process : process
    begin
        while not stop_sim loop
            clk_fast <= '0';
            wait for FAST_PERIOD/2;
            clk_fast <= '1';
            wait for FAST_PERIOD/2;
        end loop;
        wait;
    end process;

 
    clk_ref_process : process
    begin
        while not stop_sim loop
            clk_ref <= '0';
            wait for REF_PERIOD/2;
            clk_ref <= '1';
            wait for REF_PERIOD/2;
        end loop;
        wait;
    end process;

    
    clk_fb_process : process
    begin
        wait for 6 ns; -- déphasage initial
        while not stop_sim loop
            clk_fb <= '0';
            wait for FB_PERIOD/2;
            clk_fb <= '1';
            wait for FB_PERIOD/2;
        end loop;
        wait;
    end process;

    
    stim_process : process
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        
        wait for 1 us;

        
        FB_PERIOD <= 25 ns;
        wait for 2 us;

        
        FB_PERIOD <= 15 ns;
        wait for 2 us;

        stop_sim <= true;
        wait;
    end process;

end Behavioral;

