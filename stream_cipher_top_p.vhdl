library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_top_p is
  port (
  clk           : in std_logic;
  rst           : in std_logic;
  start_attack  : in std_logic;
  new_key       : in std_logic;
  key_in   : in std_logic_vector (3 downto 0);
  mask_in  : in std_logic_vector (3 downto 0);
  WEB           : in std_logic;
  REN			: in std_logic;
  reg_full      : out std_logic;
  attack_finished : out std_logic;
  signature_out : out std_logic_vector (7 downto 0);
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  espresso_out  : out std_logic
   );
end entity;

architecture stream_cipher_top_pad of stream_cipher_top_p is

component stream_cipher_top is
  port (
  -- Inputs
  clk : in std_logic;
  rst : in std_logic;
  start_attack : in std_logic;
  new_key : in std_logic;
  key_in   : in std_logic_vector (3 downto 0);
  mask_in  : in std_logic_vector (3 downto 0);
  WEB	: in std_logic;
  REN	: in std_logic;
  -- Outputs
  reg_full : out std_logic;
  attack_finished : out std_logic;
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  signature_out : out std_logic_vector (7 downto 0);
  espresso_out : out std_logic
  );
end component;

component CPAD_S_74x50u_IN --input PAD
port (
COREIO : out std_logic;
PADIO : in std_logic);
end component;

component CPAD_S_74x50u_OUT --output PAD
port (
COREIO : in std_logic;
PADIO : out std_logic);
end component;

--*
--* Signals declaration
--*

-- Input signals for both components
signal clk_i : std_logic;
signal rst_i : std_logic;
signal new_key_i : std_logic;
signal start_attack_i : std_logic;
signal key_in_i : std_logic_vector (3 downto 0);
signal mask_in_i : std_logic_vector (3 downto 0);
signal WEB_i	: std_logic;
signal REN_i	: std_logic;
signal reg_full_i : std_logic;
signal attack_finished_i : std_logic;
-- Output signal for grain component
signal grain128a_out_i: std_logic_vector (GRAIN_STEP-1 downto 0);
-- Output signal for espresso component
signal espresso_out_i: std_logic; --has only single bit output
-- Signature output
signal signature_out_i : std_logic_vector (7 downto 0);

begin

--*
--* Pads declaration
--*

-- Input pads
  ClkPad : CPAD_S_74x50u_IN
    port map (COREIO => clk_i, PADIO => clk);

  RstPad : CPAD_S_74x50u_IN
    port map (COREIO => rst_i, PADIO => rst);

  NewKeyPad : CPAD_S_74x50u_IN
    port map (COREIO => new_key_i, PADIO => new_key);

  StartAttackPad : CPAD_S_74x50u_IN
    port map (COREIO => start_attack_i, PADIO => start_attack);

  KeyInPads: for I in 0 to 3 generate
  	KeyInPad : CPAD_S_74x50u_IN
    port map (COREIO => key_in_i(I), PADIO => key_in(I));
  end generate;

  MaskInPads : for I in 0 to 3 generate
    MaskInPad : CPAD_S_74x50u_IN
    port map (COREIO => mask_in_i(I), PADIO => mask_in(I));
  end generate;
  
  WEBPad : CPAD_S_74x50u_IN
    port map (COREIO => WEB_i, PADIO =>WEB);

  RENPad : CPAD_S_74x50u_IN
    port map (COREIO => REN_i, PADIO => REN);


-- Output pad for Grain128a cipher
  grain128aPads : for I in 0 to (GRAIN_STEP-1) generate
    grainPad : CPAD_S_74x50u_OUT
    port map (COREIO => grain128a_out_i(I), PADIO => grain128a_out(I));
  end generate;

-- Output for signature
  signatureOutPads : for I in 0 to 7 generate
    signatureOutPad : CPAD_S_74x50u_OUT
    port map (COREIO => signature_out_i(I), PADIO => signature_out(I));
  end generate;

-- Output pad for Espresso cipher
  espressoPads: CPAD_S_74x50u_OUT
    port map (COREIO => espresso_out_i, PADIO => espresso_out);

  RegFullPad: CPAD_S_74x50u_OUT
    port map (COREIO => reg_full_i, PADIO => reg_full);

  AttackFinishedPad: CPAD_S_74x50u_OUT
    port map (COREIO => attack_finished_i, PADIO => attack_finished);

stream_cipher_top_i: stream_cipher_top
  port map (
  -- Inputs
  clk => clk_i,
  rst => rst_i,
  start_attack => start_attack_i,
  new_key => new_key_i,
  key_in => key_in_i,
  mask_in => mask_in_i,
  WEB => WEB_i,
  REN => REN_i,
  -- Outputs
  reg_full => reg_full_i,
  attack_finished => attack_finished_i,
  signature_out => signature_out_i,
  grain128a_out => grain128a_out_i,
  espresso_out => espresso_out_i
  );

end architecture;
