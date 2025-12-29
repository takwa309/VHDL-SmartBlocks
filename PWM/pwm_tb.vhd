library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_tb_4bit is
end pwm_tb_4bit;

architecture test of pwm_tb_4bit is

    -- Déclaration du composant PWM 4 bits
    component pwm_generator_4bit is
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            duty_cycle : in  STD_LOGIC_VECTOR(3 downto 0); -- 4 bits
            pwm_out    : out STD_LOGIC
        );
    end component;

    -- Signaux de test
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '0';
    signal duty_cycle : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal pwm_out    : STD_LOGIC;

    -- Période de l'horloge
    constant clk_period : time := 10 ns;

    -- Signal pour arrêter la simulation
    signal sim_end : boolean := false;

begin

    -- Instanciation du module PWM 4 bits
    uut: pwm_generator_4bit
        Port map (
            clk        => clk,
            reset      => reset,
            duty_cycle => duty_cycle,
            pwm_out    => pwm_out
        );

    -- ========================================
    -- GÉNÉRATION DE L'HORLOGE
    -- ========================================
    clk_process: process
    begin
        while not sim_end loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- ========================================
    -- PROCESSUS DE STIMULUS
    -- ========================================
    stim_process: process
    begin
        report "=== DEBUT DE LA SIMULATION PWM 4 BITS ===" severity note;

        -- Reset initial
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        report "Reset terminé - Début des tests" severity note;

        -- Test 1: 25% duty cycle (4/16)
        report "Test 1: duty_cycle = 4 (25%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(4, 4));
        wait for 3000 ns;

        -- Test 2: 50% duty cycle (8/16)
        report "Test 2: duty_cycle = 8 (50%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(8, 4));
        wait for 3000 ns;

        -- Test 3: 75% duty cycle (12/16)
        report "Test 3: duty_cycle = 12 (75%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(12, 4));
        wait for 3000 ns;

        -- Test 4: 100% duty cycle (15/16)
        report "Test 4: duty_cycle = 15 (100%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(15, 4));
        wait for 3000 ns;

        -- Test 5: 0% duty cycle (0/16)
        report "Test 5: duty_cycle = 0 (0%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(0, 4));
        wait for 3000 ns;

        -- Test 6: 12.5% duty cycle (2/16)
        report "Test 6: duty_cycle = 2 (12.5%)" severity note;
        duty_cycle <= std_logic_vector(to_unsigned(2, 4));
        wait for 3000 ns;

        -- Fin de simulation
        report "=== FIN DE LA SIMULATION PWM 4 BITS ===" severity note;
        sim_end <= true;
        wait;
    end process;

end test;

