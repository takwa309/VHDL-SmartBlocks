library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity neuron_relu is
    generic(
        WIDTH : integer := 16;
        SATURATE : integer := 0
    );
    port(
        x1, x2 : in  signed(WIDTH-1 downto 0);
        w1, w2 : in  signed(WIDTH-1 downto 0);
        bias   : in  signed(WIDTH-1 downto 0);
        y      : out signed(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of neuron_relu is
    signal mult1 : signed(2*WIDTH-1 downto 0);
    signal mult2 : signed(2*WIDTH-1 downto 0);
    signal sum   : signed(WIDTH-1 downto 0);
    signal sat_limit : signed(WIDTH-1 downto 0);
begin
    mult1 <= x1 * w1;
    mult2 <= x2 * w2;
    --decalage de 8 bits division par 256 pour revenir sum sur 16 bits en fin
    sum <= resize(shift_right(mult1, 8), WIDTH) +
           resize(shift_right(mult2, 8), WIDTH) +
           bias;
    --EVITER LA SATURATION
    sat_limit <= to_signed(SATURATE, WIDTH) when SATURATE > 0 else to_signed(32767, WIDTH);

    y <= (others => '0') when sum < 0 else
         sat_limit when (SATURATE > 0 and sum > sat_limit) else
         sum;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity neural_net_and is
    generic(
        WIDTH : integer := 16
    );
    port(
        x1, x2 : in  signed(WIDTH-1 downto 0);
        y_out  : out signed(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of neural_net_and is

    -- Hidden neurons outputs
    signal h1, h2 : signed(WIDTH-1 downto 0);

    
    
    -- Neurone caché 1: détecte x1 >= 0.75, sature à 1.0
    constant w11 : signed(WIDTH-1 downto 0) := to_signed(1024, WIDTH); -- 4.0 en 
    constant w12 : signed(WIDTH-1 downto 0) := to_signed(0, WIDTH);    
    constant b1  : signed(WIDTH-1 downto 0) := to_signed(-768, WIDTH); -- -3.0
    -- Quand x1=1: 4*1 - 3 = 1 ? sature à 1.0 ?
    -- Quand x1=0: 4*0 - 3 = -3 ? ReLU = 0 ?

    -- Neurone caché 2: détecte x2 >= 0.75, sature à 1.0
    constant w21 : signed(WIDTH-1 downto 0) := to_signed(0, WIDTH);    
    constant w22 : signed(WIDTH-1 downto 0) := to_signed(1024, WIDTH); -- 4.0
    constant b2  : signed(WIDTH-1 downto 0) := to_signed(-768, WIDTH); -- -3.0
    -- Quand x2=1: 4*1 - 3 = 1 ? sature à 1.0 ?
    -- Quand x2=0: 4*0 - 3 = -3 ? ReLU = 0 ?
    -- Formule: y = ReLU(w1*h1 + w2*h2 + bias)
    
    
    constant wo1 : signed(WIDTH-1 downto 0) := to_signed(512, WIDTH);  -- 2.0 
    constant wo2 : signed(WIDTH-1 downto 0) := to_signed(512, WIDTH);  -- 2.0 
    constant bo  : signed(WIDTH-1 downto 0) := to_signed(-768, WIDTH); -- -3.0 
    
 

    signal mult_o1, mult_o2 : signed(2*WIDTH-1 downto 0);
    signal out_sum : signed(WIDTH-1 downto 0);

    component neuron_relu
        generic(
            WIDTH : integer := 16;
            SATURATE : integer := 0
        );
        port(
            x1, x2 : in  signed(WIDTH-1 downto 0);
            w1, w2 : in  signed(WIDTH-1 downto 0);
            bias   : in  signed(WIDTH-1 downto 0);
            y      : out signed(WIDTH-1 downto 0)
        );
    end component;

begin

    
    H1_NEURON: neuron_relu
        generic map(WIDTH => WIDTH, SATURATE => 256)
        port map(x1 => x1, x2 => x2, w1 => w11, w2 => w12, bias => b1, y => h1);

    H2_NEURON: neuron_relu
        generic map(WIDTH => WIDTH, SATURATE => 256)
        port map(x1 => x1, x2 => x2, w1 => w21, w2 => w22, bias => b2, y => h2);

    
    mult_o1 <= h1 * wo1;
    mult_o2 <= h2 * wo2;
    
    out_sum <= resize(shift_right(mult_o1, 8), WIDTH) +
               resize(shift_right(mult_o2, 8), WIDTH) +
               bo;
    
    -- ReLU sur la sortie 
    y_out <= (others => '0') when out_sum < 0 else out_sum;

end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_neural_net_and is
end entity;

architecture sim of tb_neural_net_and is
    constant WIDTH : integer := 16;
    signal x1, x2 : signed(WIDTH-1 downto 0);
    signal y_out  : signed(WIDTH-1 downto 0);
begin
    uut: entity work.neural_net_and
        generic map(WIDTH => WIDTH)
        port map(x1 => x1, x2 => x2, y_out => y_out);

    process
    begin
        report "========================================================";
        report "Test de la fonction AND avec réseau de neurones (CORRIGÉ)";
        report "Architecture: 2 neurones cachés + couche de sortie";
        report "Format Q8.8: 256 = 1.0, 0 = 0.0";
        report "========================================================";
        
        report "--- Tests de base (0 et 1) ---";
        
        -- Test 1: 0 AND 0 = 0
        x1 <= to_signed(0, WIDTH);
        x2 <= to_signed(0, WIDTH);
        wait for 10 ns;
        report "Test 1 (0 AND 0): x1=0, x2=0, y_out=" & integer'image(to_integer(y_out)) & " (attendu: ~0)";

        -- Test 2: 0 AND 1 = 0
        x1 <= to_signed(0, WIDTH);
        x2 <= to_signed(256, WIDTH);
        wait for 10 ns;
        report "Test 2 (0 AND 1): x1=0, x2=256, y_out=" & integer'image(to_integer(y_out)) & " (attendu: ~0)";

        -- Test 3: 1 AND 0 = 0
        x1 <= to_signed(256, WIDTH);
        x2 <= to_signed(0, WIDTH);
        wait for 10 ns;
        report "Test 3 (1 AND 0): x1=256, x2=0, y_out=" & integer'image(to_integer(y_out)) & " (attendu: ~0)";

        -- Test 4: 1 AND 1 = 1
        x1 <= to_signed(256, WIDTH);
        x2 <= to_signed(256, WIDTH);
        wait for 10 ns;
        report "Test 4 (1 AND 1): x1=256, x2=256, y_out=" & integer'image(to_integer(y_out)) & " (attendu: ~256)";

        report "";
        report "--- Tests avec valeurs intermédiaires ---";
        
        -- Test 5: 0.5 AND 0.5
        x1 <= to_signed(128, WIDTH);
        x2 <= to_signed(128, WIDTH);
        wait for 10 ns;
        report "Test 5 (0.5 AND 0.5): x1=128, x2=128, y_out=" & integer'image(to_integer(y_out));

        -- Test 6: 0.25 AND 0.75
        x1 <= to_signed(64, WIDTH);
        x2 <= to_signed(192, WIDTH);
        wait for 10 ns;
        report "Test 6 (0.25 AND 0.75): x1=64, x2=192, y_out=" & integer'image(to_integer(y_out));

        -- Test 7: 1.0 AND 0.5
        x1 <= to_signed(256, WIDTH);
        x2 <= to_signed(128, WIDTH);
        wait for 10 ns;
        report "Test 7 (1.0 AND 0.5): x1=256, x2=128, y_out=" & integer'image(to_integer(y_out));

        -- Test 8: 0.5 AND 1.0
        x1 <= to_signed(128, WIDTH);
        x2 <= to_signed(256, WIDTH);
        wait for 10 ns;
        report "Test 8 (0.5 AND 1.0): x1=128, x2=256, y_out=" & integer'image(to_integer(y_out));

        report "";
        report "--- Tests avec valeurs négatives ---";
        
        -- Test 9: -1 AND 1
        x1 <= to_signed(-256, WIDTH);
        x2 <= to_signed(256, WIDTH);
        wait for 10 ns;
        report "Test 9 (-1 AND 1): x1=-256, x2=256, y_out=" & integer'image(to_integer(y_out)) & " (attendu: 0 car ReLU)";

        -- Test 10: 1 AND -1
        x1 <= to_signed(256, WIDTH);
        x2 <= to_signed(-256, WIDTH);
        wait for 10 ns;
        report "Test 10 (1 AND -1): x1=256, x2=-256, y_out=" & integer'image(to_integer(y_out)) & " (attendu: 0 car ReLU)";

        report "";
        report "--- Tests de limites ---";
        
        -- Test 11: Valeurs très petites
        x1 <= to_signed(10, WIDTH);
        x2 <= to_signed(10, WIDTH);
        wait for 10 ns;
        report "Test 11 (petites valeurs): x1=10, x2=10, y_out=" & integer'image(to_integer(y_out));

        -- Test 12: Valeurs proches de 1
        x1 <= to_signed(250, WIDTH);
        x2 <= to_signed(250, WIDTH);
        wait for 10 ns;
        report "Test 12 (proches de 1): x1=250, x2=250, y_out=" & integer'image(to_integer(y_out));

        -- Test 13: Valeurs au-dessus de 1
        x1 <= to_signed(512, WIDTH);
        x2 <= to_signed(512, WIDTH);
        wait for 10 ns;
        report "Test 13 (au-dessus de 1): x1=512, x2=512, y_out=" & integer'image(to_integer(y_out));

        report "";
        report "========================================================";
        report "Tests terminés! Architecture à 2 neurones cachés";
        report "h1 détecte x1, h2 détecte x2, sortie fait le AND";
        report "========================================================";
        wait;
    end process;
end architecture;
