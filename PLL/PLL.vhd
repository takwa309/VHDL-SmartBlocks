library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity phase_comparator is
    Port (
        clk_fast   : in  std_logic;
        clk_ref    : in  std_logic;
        clk_fb     : in  std_logic;
        reset      : in  std_logic;
        phase_diff : out integer range -50 to 50
    );
end phase_comparator;

architecture Behavioral of phase_comparator is
    signal time_counter : integer range 0 to 99 := 0;
    signal ref_latch    : integer range 0 to 99 := 0;
    signal fb_latch     : integer range 0 to 99 := 0;
    signal clk_ref_d    : std_logic := '0';
    signal clk_fb_d     : std_logic := '0';
begin
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

    process(clk_fast, reset)
    begin
        if reset = '1' then
            clk_ref_d <= '0';
            ref_latch <= 0;
        elsif rising_edge(clk_fast) then
            clk_ref_d <= clk_ref;
            if clk_ref = '1' and clk_ref_d = '0' then
                ref_latch <= time_counter;
            end if;
        end if;
    end process;

    process(clk_fast, reset)
    begin
        if reset = '1' then
            clk_fb_d <= '0';
            fb_latch <= 0;
        elsif rising_edge(clk_fast) then
            clk_fb_d <= clk_fb;
            if clk_fb = '1' and clk_fb_d = '0' then
                fb_latch <= time_counter;
            end if;
        end if;
    end process;

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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity loop_filter_P is
    generic (Kp : integer := 3);
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nco_vco is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        command : in  signed(15 downto 0);
        clk_out : out std_logic
    );
end nco_vco;

architecture Behavioral of nco_vco is
    signal phase_acc : unsigned(15 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            phase_acc <= (others => '0');
        elsif rising_edge(clk) then
            phase_acc <= phase_acc + unsigned(command);
        end if;
    end process;
    clk_out <= phase_acc(15);
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pll_top is
    port (
        clk_fast : in  std_logic;
        clk_ref  : in  std_logic;
        reset    : in  std_logic;
        clk_vco  : out std_logic
    );
end pll_top;

architecture Behavioral of pll_top is
    signal phase_diff : integer range -50 to 50 := 0;
    signal ctrl       : integer range -500 to 500 := 0;
    signal command    : signed(15 downto 0);
    signal clk_fb     : std_logic;
begin
    pc : entity work.phase_comparator
        port map (
            clk_fast   => clk_fast,
            clk_ref    => clk_ref,
            clk_fb     => clk_fb,
            reset      => reset,
            phase_diff => phase_diff
        );

    lf : entity work.loop_filter_P
        port map (
            clk        => clk_fast,
            reset      => reset,
            phase_diff => phase_diff,
            ctrl_out   => ctrl
        );

    command <= to_signed(ctrl, 16);

    vco : entity work.nco_vco
        port map (
            clk     => clk_fast,
            reset   => reset,
            command => command,
            clk_out => clk_fb
        );

    clk_vco <= clk_fb;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_top_tb is
end pll_top_tb;

architecture Behavioral of pll_top_tb is
    signal clk_fast : std_logic := '0';
    signal clk_ref  : std_logic := '0';
    signal reset    : std_logic := '1';
    signal clk_vco  : std_logic;
    constant FAST_PERIOD : time := 2 ns;
    constant REF_PERIOD  : time := 20 ns;
begin
    UUT : entity work.pll_top
        port map (
            clk_fast => clk_fast,
            clk_ref  => clk_ref,
            reset    => reset,
            clk_vco  => clk_vco
        );

    clk_fast <= not clk_fast after FAST_PERIOD/2;
    clk_ref  <= not clk_ref  after REF_PERIOD/2;

    process
    begin
        wait for 50 ns;
        reset <= '0';
        wait for 10 us;
        wait;
    end process;
end Behavioral;
