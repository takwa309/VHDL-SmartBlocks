library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_rgb_to_gray_matrix is
end tb_rgb_to_gray_matrix;

architecture Behavioral of tb_rgb_to_gray_matrix is
    
    -- Signaux du testbench
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';
    signal R_in      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal G_in      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B_in      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal addr_in   : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal write_en  : STD_LOGIC := '0';
    signal Y_out     : STD_LOGIC_VECTOR(7 downto 0);
    signal addr_out  : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal done      : STD_LOGIC;
    
    -- Période d'horloge
    constant clk_period : time := 10 ns;
    
    -- Matrices de test (10x10)
    type matrix_rgb is array (0 to 99) of integer range 0 to 255;
    
    -- Matrice R (exemple: dégradé horizontal)
    signal test_R : matrix_rgb := (
        -- Ligne 0
        255, 230, 205, 180, 155, 130, 105, 80, 55, 30,
        -- Ligne 1
        255, 230, 205, 180, 155, 130, 105, 80, 55, 30,
        -- Ligne 2
        255, 230, 205, 180, 155, 130, 105, 80, 55, 30,
        -- Ligne 3
        200, 180, 160, 140, 120, 100, 80, 60, 40, 20,
        -- Ligne 4
        200, 180, 160, 140, 120, 100, 80, 60, 40, 20,
        -- Ligne 5
        150, 135, 120, 105, 90, 75, 60, 45, 30, 15,
        -- Ligne 6
        150, 135, 120, 105, 90, 75, 60, 45, 30, 15,
        -- Ligne 7
        100, 90, 80, 70, 60, 50, 40, 30, 20, 10,
        -- Ligne 8
        50, 45, 40, 35, 30, 25, 20, 15, 10, 5,
        -- Ligne 9
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    );
    
    -- Matrice G (exemple: dégradé vertical)
    signal test_G : matrix_rgb := (
        -- Ligne 0
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        -- Ligne 1
        230, 230, 230, 230, 230, 230, 230, 230, 230, 230,
        -- Ligne 2
        205, 205, 205, 205, 205, 205, 205, 205, 205, 205,
        -- Ligne 3
        180, 180, 180, 180, 180, 180, 180, 180, 180, 180,
        -- Ligne 4
        155, 155, 155, 155, 155, 155, 155, 155, 155, 155,
        -- Ligne 5
        130, 130, 130, 130, 130, 130, 130, 130, 130, 130,
        -- Ligne 6
        105, 105, 105, 105, 105, 105, 105, 105, 105, 105,
        -- Ligne 7
        80, 80, 80, 80, 80, 80, 80, 80, 80, 80,
        -- Ligne 8
        55, 55, 55, 55, 55, 55, 55, 55, 55, 55,
        -- Ligne 9
        30, 30, 30, 30, 30, 30, 30, 30, 30, 30
    );
    
    -- Matrice B (exemple: valeurs constantes par région)
    signal test_B : matrix_rgb := (
        -- Ligne 0
        200, 200, 200, 200, 200, 100, 100, 100, 100, 100,
        -- Ligne 1
        200, 200, 200, 200, 200, 100, 100, 100, 100, 100,
        -- Ligne 2
        200, 200, 200, 200, 200, 100, 100, 100, 100, 100,
        -- Ligne 3
        200, 200, 200, 200, 200, 100, 100, 100, 100, 100,
        -- Ligne 4
        200, 200, 200, 200, 200, 100, 100, 100, 100, 100,
        -- Ligne 5
        150, 150, 150, 150, 150, 50, 50, 50, 50, 50,
        -- Ligne 6
        150, 150, 150, 150, 150, 50, 50, 50, 50, 50,
        -- Ligne 7
        150, 150, 150, 150, 150, 50, 50, 50, 50, 50,
        -- Ligne 8
        150, 150, 150, 150, 150, 50, 50, 50, 50, 50,
        -- Ligne 9
        150, 150, 150, 150, 150, 50, 50, 50, 50, 50
    );
    
    -- Matrice de sortie Y
    type matrix_y_type is array (0 to 99) of integer range 0 to 255;
    signal result_Y : matrix_y_type := (others => 0);
    
    -- Component declaration
    component rgb_to_gray_matrix
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
    end component;
    
begin
    
    -- Instanciation du module
    UUT: rgb_to_gray_matrix
        port map (
            clk      => clk,
            reset    => reset,
            start    => start,
            R_in     => R_in,
            G_in     => G_in,
            B_in     => B_in,
            addr_in  => addr_in,
            write_en => write_en,
            Y_out    => Y_out,
            addr_out => addr_out,
            done     => done
        );
    
    -- Génération de l'horloge
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Processus de stimulation
    stim_proc: process
    begin
        -- Test de base
        report "TEST START" severity note;
        
        -- Reset initial
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;
        
        -- ===== PHASE 1: ECRITURE DE LA MATRICE RGB =====
        write_en <= '1';
        
        for i in 0 to 99 loop
            addr_in <= std_logic_vector(to_unsigned(i, 7));
            R_in <= std_logic_vector(to_unsigned(test_R(i), 8));
            G_in <= std_logic_vector(to_unsigned(test_G(i), 8));
            B_in <= std_logic_vector(to_unsigned(test_B(i), 8));
            wait for 10 ns;
        end loop;
        
        write_en <= '0';
        wait for 10 ns;
        
        -- ===== PHASE 2: CONVERSION RGB -> GRAYSCALE =====
        start <= '1';
        wait for 10 ns;
        start <= '0';
        
        -- Attendre que la conversion soit terminée
        wait until done = '1';
        wait for 20 ns;
        
        -- ===== PHASE 3: LECTURE DE LA MATRICE Y =====
        for i in 0 to 99 loop
            addr_out <= std_logic_vector(to_unsigned(i, 7));
            wait for 10 ns;
            result_Y(i) <= to_integer(unsigned(Y_out));
        end loop;
        
        wait for 20 ns;
        
        -- ===== PHASE 4: AFFICHAGE DES RESULTATS =====
        report "========================================" severity note;
        report "TEST TERMINE" severity note;
        report "Pixel[0] Y=" & integer'image(result_Y(0)) severity note;
        report "Pixel[50] Y=" & integer'image(result_Y(50)) severity note;
        report "Pixel[99] Y=" & integer'image(result_Y(99)) severity note;
        report "========================================" severity note;
        
        wait;
    end process;
    
end Behavioral;
