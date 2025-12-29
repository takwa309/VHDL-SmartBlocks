library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rgb_to_gray_matrix is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        start   : in  STD_LOGIC;
        R_in    : in  STD_LOGIC_VECTOR(7 downto 0);
        G_in    : in  STD_LOGIC_VECTOR(7 downto 0);
        B_in    : in  STD_LOGIC_VECTOR(7 downto 0);
        addr_in : in  STD_LOGIC_VECTOR(6 downto 0);
        write_en: in  STD_LOGIC;
        Y_out   : out STD_LOGIC_VECTOR(7 downto 0);
        addr_out: in  STD_LOGIC_VECTOR(6 downto 0);
        done    : out STD_LOGIC
    );
end rgb_to_gray_matrix;

architecture Behavioral of rgb_to_gray_matrix is
    
    type rgb_array is array (0 to 99) of STD_LOGIC_VECTOR(7 downto 0);
    
    signal mem_R : rgb_array := (others => (others => '0'));
    signal mem_G : rgb_array := (others => (others => '0'));
    signal mem_B : rgb_array := (others => (others => '0'));
    signal mem_Y : rgb_array := (others => (others => '0'));
    
    signal processing : STD_LOGIC := '0';
    signal pixel_counter : integer range 0 to 100 := 0;
    
begin
    
    write_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                mem_R <= (others => (others => '0'));
                mem_G <= (others => (others => '0'));
                mem_B <= (others => (others => '0'));
            elsif write_en = '1' then
                mem_R(to_integer(unsigned(addr_in))) <= R_in;
                mem_G(to_integer(unsigned(addr_in))) <= G_in;
                mem_B(to_integer(unsigned(addr_in))) <= B_in;
            end if;
        end if;
    end process;
    
    compute_process : process(clk)
        variable R_val, G_val, B_val : unsigned(7 downto 0);
        variable mult_G : unsigned(15 downto 0);
        variable mult_R : unsigned(15 downto 0);
        variable mult_B : unsigned(15 downto 0);
        variable sum_temp : unsigned(17 downto 0);
        variable Y_temp : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                processing <= '0';
                pixel_counter <= 0;
                done <= '0';
                mem_Y <= (others => (others => '0'));
                
            elsif start = '1' and processing = '0' then
                processing <= '1';
                pixel_counter <= 0;
                done <= '0';
                
            elsif processing = '1' then
                if pixel_counter <= 99 then
                    R_val := unsigned(mem_R(pixel_counter));
                    G_val := unsigned(mem_G(pixel_counter));
                    B_val := unsigned(mem_B(pixel_counter));
                    --R*77 + G*151 + B*38
                    mult_G := G_val * to_unsigned(151, 8);
                    mult_R := R_val * to_unsigned(77, 8);
                    mult_B := B_val * to_unsigned(38, 8);
                    --decalage pour diviser sur 256
                    sum_temp := resize(mult_G, 18) + resize(mult_R, 18) + resize(mult_B, 18);
                    Y_temp := sum_temp(15 downto 8);
                    
                    mem_Y(pixel_counter) <= std_logic_vector(Y_temp);
                    
                    if pixel_counter = 99 then
                        processing <= '0';
                        done <= '1';
                    else
                        pixel_counter <= pixel_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    read_process : process(clk)
    begin
        if rising_edge(clk) then
            Y_out <= mem_Y(to_integer(unsigned(addr_out)));
        end if;
    end process;
    
end Behavioral;
