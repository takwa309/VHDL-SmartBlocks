library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_generator_4bit is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        duty_cycle : in  STD_LOGIC_VECTOR(3 downto 0); 
        pwm_out    : out STD_LOGIC
    );
end pwm_generator_4bit;

architecture Behavioral of pwm_generator_4bit is
    signal counter    : unsigned(3 downto 0) := (others => '0');
    signal duty_value : unsigned(3 downto 0);
begin

    duty_value <= unsigned(duty_cycle);

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            pwm_out <= '0';

        elsif rising_edge(clk) then
           
            counter <= counter + 1;

            
            if counter < duty_value then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;

