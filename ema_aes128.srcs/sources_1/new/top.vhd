-------------------------------------------------------------------------------
-- Top Module
-- AES + UART Component
-------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity top is
    generic (
        baud            : positive:= 9600;
        clock_frequency : positive:= 100000000
    );
    port (  
        clock           : in std_logic;
        reset           : in std_logic;
		tx_tick         : out std_logic;          -- I/O for functional simulation, not for implementation
        rx_tick         : out std_logic;          -- I/O for functional simulation, not for implementation
        rx_bit_tick     : out std_logic;          -- I/O for functional simulation, not for implementation
        rx              : in std_logic;
        tx              : out std_logic
    );
end top;

architecture rtl of top is
    ---------------------------------------------------------------------------
    -- Component declarations
    ---------------------------------------------------------------------------
    component uart is
        generic (
            baud                : positive;
            clock_frequency     : positive
        );
        port (
            clock               :   in      std_logic;
            reset               :   in      std_logic;    
            data_stream_in      :   in      std_logic_vector(7 downto 0);
            data_stream_in_stb  :   in      std_logic;
            data_stream_in_ack  :   out     std_logic;
            data_stream_out     :   out     std_logic_vector(7 downto 0);
            data_stream_out_stb :   out     std_logic;
            tx_tick             :   out     std_logic;          -- I/O for evaluation
            rx_tick             :   out     std_logic;          -- I/O for evaluation
            rx_bit_tick         :   out std_logic;              -- I/O for evaluation
            tx                  :   out     std_logic;
            rx                  :   in      std_logic
        );
    end component uart;

    component aes128key is
        Port(
        reset : in  STD_LOGIC;
        clock : in  STD_LOGIC;
        --input side signals
        empty : out STD_LOGIC;
        load : in  STD_LOGIC;
        key : in  STD_LOGIC_VECTOR (127 downto 0);
        plain : in  STD_LOGIC_VECTOR (127 downto 0);
        --output side signals
        ready : out  STD_LOGIC;
        cipher : out STD_LOGIC_VECTOR(127 downto 0));
    end component;
    ---------------------------------------------------------------------------
    -- UART signals
    ---------------------------------------------------------------------------
    signal uart_data_in : std_logic_vector(7 downto 0);
    signal uart_data_out : std_logic_vector(7 downto 0);
    signal uart_data_in_tmp: std_logic_vector(0 to 7); 
    signal uart_data_in_stb : std_logic := '0';
    signal uart_data_in_ack : std_logic := '0';
    signal uart_data_out_stb : std_logic := '0';
 	
	 -- Temporary Register
	 signal temp: std_logic_vector (7 downto 0);
	 signal key_reg, key_tmp: std_logic_vector (127 downto 0):= (others => '0');
	 signal pt_reg, pt_tmp : std_logic_vector (127 downto 0):= (others => '0');
	 signal cp_reg, cp_tmp : std_logic_vector (127 downto 0):= (others => '0');
	 
	 signal aes_empty   : std_logic;         -- Indicates that AES core is not busy  
	 signal aes_ready   : std_logic;         -- Indicates that Cipher is already
     signal aes_load 	: std_logic;         -- Signal indicates that the AES could load the data from the input register
	 signal cnt			: std_logic_vector (3 downto 0);
	 signal reg         : std_logic_vector(255 downto 0):= (others => '0');
	 signal write_cnt   : std_logic_vector (4 downto 0):= (others => '0');
	 
	 signal i  :integer range 0 to 16;
begin
    ---------------------------------------------------------------------------
    -- UART instantiation
    ---------------------------------------------------------------------------
    uart_comp : uart
    generic map (
        baud                => baud,
        clock_frequency     => clock_frequency
    )
    port map    (  
        -- general
        clock               => clock,
        reset               => reset,
        data_stream_in      => uart_data_in,
        data_stream_in_stb  => uart_data_in_stb,
        data_stream_in_ack  => uart_data_in_ack,
        data_stream_out     => uart_data_out,
        data_stream_out_stb => uart_data_out_stb,
        tx_tick             => tx_tick,
        rx_tick             => rx_tick,
        rx_bit_tick         => rx_bit_tick,
        tx                  => tx,
        rx                  => rx
    );
    ---------------------------------------------------------------------------
    -- AES instantiation
    ---------------------------------------------------------------------------   
    aes_comp: aes128key
    port map(reset, clock, aes_empty, aes_load, key_tmp, pt_tmp, aes_ready, cp_reg);
    
 
    key_tmp <=  reg(255 downto 128) when aes_load ='1' else key_tmp;
    pt_tmp  <=  reg(127 downto 0)  when aes_load ='1' else pt_tmp;

    uart_data_in_tmp <= cp_tmp(127 downto 120);
    uart_data_in <= uart_data_in_tmp;
	 wr_control: process (clock)

        begin
            if rising_edge(clock) then
                if (uart_data_out_stb ='1') then
                    if (write_cnt < "11111") then
                        aes_load <= '0';
                        write_cnt <= write_cnt + 1;
                    else
                        write_cnt <= (others => '0');
                        aes_load <= '1';
                    end if;
                    reg  <= reg(247 downto 0) & uart_data_out;
                end if;
                if aes_load = '1' then
                    aes_load <= '0';
                end if;
                
                if (aes_ready ='1') then        -- Ready to send the cipher
                    uart_data_in_stb <= '1';
                    cp_tmp  <=  cp_reg;
                else
                    uart_data_in_stb <=  uart_data_in_stb;
                end if;
                
                if uart_data_in_ack ='1' then
--                    uart_data_in_tmp <= cp_tmp(127 downto 120);   
                    if i <15 then           -- Update register for transmitting
                        i   <= i+1;
                        cp_tmp(127 downto 0) <= cp_tmp(119 downto 0)&"00000000";
                    else
                        i   <= 0;
                        uart_data_in_stb <= '0';
                        cp_tmp  <= cp_tmp;
--                        uart_data_in_tmp <= uart_data_in_tmp;
                    end if;
                end if;
            end if;    
        end process;  
end rtl;