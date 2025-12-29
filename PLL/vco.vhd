-- ======================================================


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity nco_vco is
    generic (
        PHASE_WIDTH : integer := 16  -- largeur de l'accumulateur de phase
    );
    port (
        clk      : in  std_logic;               -- horloge système
        reset    : in  std_logic;
        command  : in  signed(15 downto 0);     -- commande du filtre
        clk_out  : out std_logic                -- horloge générée
    );
end nco_vco;

architecture Behavioral of nco_vco is

    signal phase_acc : unsigned(PHASE_WIDTH-1 downto 0) := (others => '0');

begin

    process(clk, reset)
    begin
        if reset = '1' then
            phase_acc <= (others => '0');
        elsif rising_edge(clk) then
            -- Accumulateur de phase
            phase_acc <= phase_acc + unsigned(command);
        end if;
    end process;

    -- Sortie : bit de poids fort de la phase
    clk_out <= phase_acc(PHASE_WIDTH-1);

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nco_vco_tb is
end nco_vco_tb;

architecture Behavioral of nco_vco_tb is

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal command : signed(15 downto 0) := to_signed(1000,16);
    signal clk_out : std_logic;

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin

    -- DUT
    UUT : entity work.nco_vco
        port map (
            clk     => clk,
            reset   => reset,
            command => command,
            clk_out => clk_out
        );

    -- Horloge système
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus
    stim_process : process
    begin
        -- Reset
        wait for 50 ns;
        reset <= '0';

        -- Fréquence moyenne
        command <= to_signed(800,16);
        wait for 2 us;

        -- Accélération
        command <= to_signed(2000,16);
        wait for 2 us;

        -- Ralentissement
        command <= to_signed(400,16);
        wait for 2 us;

        wait;
    end process;

end Behavioral;