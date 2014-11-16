-----------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2011, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.net.all;
use gaisler.jtag.all;

library esa;
use esa.memoryctrl.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    ncpu      : integer := CFG_NCPU;
    disas     : integer := CFG_DISAS;	-- Enable disassembly to console
    dbguart   : integer := CFG_DUART;	-- Print UART on console
    pclow     : integer := CFG_PCLOW
  );
  port (
    sys_rst_in	    : in  std_ulogic;
    clk_100	    : in  std_ulogic; 	-- 100 MHz main clock
    clk_200_p	    : in  std_ulogic; 	-- 200 MHz 
    clk_200_n	    : in  std_ulogic; 	-- 200 MHz 
    clk_33          : in  std_ulogic;
    sram_flash_addr : out std_logic_vector(23 downto 0);
    sram_flash_data : inout std_logic_vector(31 downto 0);
    sram_cen  	    : out std_logic;
    sram_bw   	    : out std_logic_vector (0 to 3);
    sram_oen        : out std_ulogic;
    sram_flash_we_n : out std_ulogic;
    flash_ce  	    : out std_logic;
    flash_oen 	    : out std_logic;
    flash_adv_n     : out std_logic;
    sram_clk  	    : out std_ulogic;
    sram_clk_fb	    : in  std_ulogic; 
    sram_mode 	    : out std_ulogic;
    sram_adv_ld_n   : out std_ulogic;
--pragma translate_off
    iosn            : out std_ulogic;
--pragma translate_on
    
    ddr_clk  	    : out std_logic_vector(1 downto 0);
    ddr_clkb  	    : out std_logic_vector(1 downto 0);
    ddr_cke  	    : out std_logic_vector(1 downto 0);
    ddr_csb  	    : out std_logic_vector(1 downto 0);
    ddr_odt  	    : out std_logic_vector(1 downto 0);
    ddr_web         : out std_ulogic;                       -- ddr write enable
    ddr_rasb        : out std_ulogic;                       -- ddr ras
    ddr_casb  	    : out std_ulogic;                       -- ddr cas
    ddr_dm   	    : out std_logic_vector (7 downto 0);    -- ddr dm
    ddr_dqsp  	    : inout std_logic_vector (7 downto 0);    -- ddr dqs
    ddr_dqsn  	    : inout std_logic_vector (7 downto 0);    -- ddr dqs
    ddr_ad          : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba          : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq  	    : inout std_logic_vector (63 downto 0); -- ddr data

    txd1   	    : out std_ulogic; 			-- UART1 tx data
    rxd1   	    : in  std_ulogic;  			-- UART1 rx data
    txd2   	    : out std_ulogic; 			-- UART2 tx data
    rxd2   	    : in  std_ulogic;  			-- UART2 rx data

    gpio            : inout std_logic_vector(12 downto 0); 	-- I/O port
    led             : out std_logic_vector(12 downto 0);
    bus_error       : out std_logic_vector(1 downto 0);

    phy_gtx_clk     : out std_logic;
    phy_mii_data    : inout std_logic;		-- ethernet PHY interface
    phy_tx_clk 	    : in std_ulogic;
    phy_rx_clk 	    : in std_ulogic;
    phy_rx_data	    : in std_logic_vector(7 downto 0);   
    phy_dv  	    : in std_ulogic; 
    phy_rx_er	    : in std_ulogic; 
    phy_col 	    : in std_ulogic;
    phy_crs 	    : in std_ulogic;
    phy_tx_data     : out std_logic_vector(7 downto 0);   
    phy_tx_en 	    : out std_ulogic; 
    phy_tx_er 	    : out std_ulogic; 
    phy_mii_clk	    : out std_ulogic;
    phy_rst_n	    : out std_ulogic;

    ps2_keyb_clk    : inout std_logic;
    ps2_keyb_data   : inout std_logic;
    ps2_mouse_clk   : inout std_logic;
    ps2_mouse_data  : inout std_logic;

    usb_csn         : out std_logic;
    usb_rstn        : out std_logic;

    iic_scl_main    : inout std_ulogic;
    iic_sda_main    : inout std_ulogic;

    dvi_iic_scl     : inout std_logic;
    dvi_iic_sda     : inout std_logic;

    tft_lcd_data    : out std_logic_vector(11 downto 0);
    tft_lcd_clk_p   : out std_ulogic;
    tft_lcd_clk_n   : out std_ulogic;
    tft_lcd_hsync   : out std_ulogic;
    tft_lcd_vsync   : out std_ulogic;
    tft_lcd_de      : out std_ulogic;
    tft_lcd_reset_b : out std_ulogic;

    sysace_mpa      : out std_logic_vector(6 downto 0);
    sysace_mpce     : out std_ulogic;
    sysace_mpirq    : in  std_ulogic;
    sysace_mpoe     : out std_ulogic;
    sysace_mpwe     : out std_ulogic;
    sysace_d        : inout std_logic_vector(15 downto 0)
    );
end;

architecture rtl of leon3mp is

component svga2ch7301c
  generic (
    tech    : integer := 0;
    idf     : integer := 0;
    dynamic : integer := 0
    );
  port (
    clk         : in  std_ulogic;
    rstn        : in  std_ulogic;
    clksel      : in  std_logic_vector(1 downto 0);
    vgao        : in  apbvga_out_type;
    vgaclk_fb   : in  std_ulogic;
    clk25_fb    : in  std_ulogic;
    clk40_fb    : in  std_ulogic;
    clk65_fb    : in  std_ulogic;
    vgaclk      : out std_ulogic;
    clk25       : out std_ulogic;
    clk40       : out std_ulogic;
    clk65       : out std_ulogic;
    dclk_p      : out std_ulogic;
    dclk_n      : out std_ulogic;
    locked      : out std_ulogic;
    data        : out std_logic_vector(11 downto 0);
    hsync       : out std_ulogic;
    vsync       : out std_ulogic;
    de          : out std_ulogic
    );
end component;
  
constant blength : integer := 12;
constant fifodepth : integer := 8;
constant maxahbm : integer := NCPU+CFG_AHB_UART
	+CFG_GRETH+CFG_AHB_JTAG+CFG_SVGA_ENABLE;

signal ddr_clk_fb  : std_logic;
signal vcc, gnd   : std_logic_vector(4 downto 0);
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdctrl_out_type;
signal sdo2, sdo3 : sdctrl_out_type;

signal apbi  : apb_slv_in_type;
signal apbo  : apb_slv_out_vector := (others => apb_none);
signal ahbsi : ahb_slv_in_type;
signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
signal ahbmi : ahb_mst_in_type;
signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

signal clkm, rstn, rstraw, srclkl : std_ulogic;
signal clk_200 : std_ulogic;
signal clk25, clk40, clk65 : std_ulogic;

signal cgi, cgi2   : clkgen_in_type;
signal cgo, cgo2   : clkgen_out_type;
signal u1i, u2i, dui : uart_in_type;
signal u1o, u2o, duo : uart_out_type;

signal irqi : irq_in_vector(0 to NCPU-1);
signal irqo : irq_out_vector(0 to NCPU-1);

signal dbgi : l3_debug_in_vector(0 to NCPU-1);
signal dbgo : l3_debug_out_vector(0 to NCPU-1);

signal dsui : dsu_in_type;
signal dsuo : dsu_out_type; 

signal ethi, ethi1, ethi2 : eth_in_type;
signal etho, etho1, etho2 : eth_out_type;

signal gpti : gptimer_in_type;

signal gpioi : gpio_in_type;
signal gpioo : gpio_out_type;

signal clklock, lock, lclk, clkml, rst, ndsuact : std_ulogic;
signal tck, tckn, tms, tdi, tdo : std_ulogic;
signal ddrclk, ddrrst : std_ulogic;


signal egtx_clk_fb : std_ulogic;
signal egtx_clk, legtx_clk, l2egtx_clk : std_ulogic;

signal kbdi  : ps2_in_type;
signal kbdo  : ps2_out_type;
signal moui  : ps2_in_type;
signal mouo  : ps2_out_type;

signal vgao  : apbvga_out_type;
signal lcd_datal : std_logic_vector(11 downto 0);
signal lcd_hsyncl, lcd_vsyncl, lcd_del, lcd_reset_bl : std_ulogic;
signal clk_sel : std_logic_vector(1 downto 0);
signal vgalock : std_ulogic;
signal clkvga, clkvga_p, clkvga_n : std_ulogic;

signal i2ci, dvi_i2ci : i2c_in_type;
signal i2co, dvi_i2co : i2c_out_type;

constant BOARD_FREQ_200 : integer := 200000;   -- input frequency in KHz
constant BOARD_FREQ : integer := 100000;   -- input frequency in KHz
constant CPU_FREQ : integer := BOARD_FREQ * CFG_CLKMUL / CFG_CLKDIV;  -- cpu frequency in KHz
constant I2C_FILTER : integer := (CPU_FREQ*5+50000)/100000+1;
constant IOAEN : integer := CFG_DDR2SP;

signal stati : ahbstat_in_type;

signal ddsi  : ddrmem_in_type;
signal ddso  : ddrmem_out_type;

signal ddrclkfb, ssrclkfb, ddr_clkl, ddr_clk90l, ddr_clknl, ddr_clk270l : std_ulogic;
signal ddr_clkv 	: std_logic_vector(2 downto 0);
signal ddr_clkbv	: std_logic_vector(2 downto 0);
signal ddr_ckev  	: std_logic_vector(1 downto 0);
signal ddr_csbv  	: std_logic_vector(1 downto 0);
signal ddr_adl      	: std_logic_vector (13 downto 0);

signal clkace : std_ulogic;
signal acei   : gracectrl_in_type;
signal aceo   : gracectrl_out_type;

attribute syn_keep : boolean;
attribute syn_preserve : boolean;
attribute syn_keep of clkml : signal is true;
attribute syn_preserve of clkml : signal is true;
attribute syn_keep of clkm : signal is true;
attribute syn_preserve of clkm : signal is true;
attribute syn_keep of egtx_clk : signal is true;
attribute syn_preserve of egtx_clk : signal is true;
attribute syn_keep of clkvga : signal is true;
attribute syn_preserve of clkvga : signal is true;
attribute syn_keep of clk25 : signal is true;
attribute syn_preserve of clk25 : signal is true;
attribute syn_keep of clk40 : signal is true;
attribute syn_preserve of clk40 : signal is true;
attribute syn_keep of clk65 : signal is true;
attribute syn_preserve of clk65 : signal is true;
attribute syn_keep of clk_200 : signal is true;
attribute syn_preserve of clk_200 : signal is true;

attribute keep : boolean;
attribute keep of lock : signal is true;
attribute keep of clkml : signal is true;
attribute keep of clkm : signal is true;
attribute keep of egtx_clk : signal is true;
attribute keep of clkvga : signal is true;
attribute keep of clk25 : signal is true;
attribute keep of clk40 : signal is true;
attribute keep of clk65 : signal is true;
attribute keep of clk_200 : signal is true;

-- Prevent synplify from removing clk_33_pad since
-- this will lead to I/O standard conflicts
attribute syn_noprune : boolean;
attribute syn_noprune of clk_33_pad : label is true;

begin

  usb_csn <= '1';
  usb_rstn <= rstn;
----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  
  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw; cgi.pllref <= ssrclkfb;

  ssrref_pad : clkpad generic map (tech => padtech) 
    	port map (sram_clk_fb, ssrclkfb); 
  clk_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (clk_100, lclk); 
  clk200_pad : clkpad_ds generic map (tech => padtech, level => lvds, voltage => x25v) 
	port map (clk_200_p, clk_200_n, clk_200); 

  srclk_pad : outpad generic map (tech => padtech, slew => 1, strength => 24) 
	port map (sram_clk, srclkl);

  clk_33_pad : clkpad generic map (tech => padtech) 
        port map (clk_33, clkace);
  
  clkgen0 : clkgen  		-- system clock generator
    generic map (CFG_FABTECH, CFG_CLKMUL, CFG_CLKDIV, 1, 0, 0, 0, 0, BOARD_FREQ, 0)
    port map (lclk, gnd(0), clkm, open, open, srclkl, open, cgi, cgo);

  clkgen1 : clkgen  		-- Ethernet 1G PHY clock generator
    generic map (CFG_FABTECH, 5, 4, 0, 0, 0, 0, 0, BOARD_FREQ, 0)
    port map (lclk, gnd(0), egtx_clk, open, open, open, open, cgi2, cgo2);
  cgi2.pllctrl <= "00"; cgi2.pllrst <= rstraw; --cgi2.pllref <= egtx_clk_fb;
  egtx_clk_pad : outpad generic map (tech => padtech)
      port map (phy_gtx_clk, egtx_clk);

  resetn_pad : inpad generic map (tech => padtech) port map (sys_rst_in, rst); 
  rst0 : rstgen			-- reset generator
  port map (rst, clkm, clklock, rstn, rstraw);
  clklock <= lock and cgo2.clklock and vgalock;

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------

  ahb0 : ahbctrl 		-- AHB arbiter/multiplexer
  generic map (defmast => CFG_DEFMST, split => CFG_SPLIT, 
	rrobin => CFG_RROBIN, ioaddr => CFG_AHBIO, devid => XILINX_ML509,
	ioen => IOAEN, nahbm => maxahbm, nahbs => 8)
  port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to NCPU-1 generate
      u0 : leon3s			-- LEON3 processor      
      generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8, 
	0, CFG_MAC, pclow, 0, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE, 
	CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
	CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
        CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP, 
        CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR, NCPU-1)
      port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, 
    		irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;
    bus_error(0) <= not dbgo(0).error;
  
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3			-- LEON3 Debug Support Unit
      generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, 
         ncpu => NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
      port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);
      dsui.enable <= '1';
--    dsubre_pad : inpad generic map (tech => padtech) port map (dsubre, dsui.break); 
       dsui.break <= gpioo.val(11); --  South Button
--    dsuact_pad : outpad generic map (tech => padtech) port map (dsuact, ndsuact);
    led(4) <= dsuo.active;
    end generate;
  end generate;

  nodsu : if CFG_DSU = 0 generate 
    dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0: ahbuart		-- Debug UART
    generic map (hindex => NCPU, pindex => 7, paddr => 7)
    port map (rstn, clkm, dui, duo, apbi, apbo(7), ahbmi, ahbmo(NCPU));
--    dsurx_pad : inpad generic map (tech => padtech) port map (rxd1, dui.rxd); 
--    dsutx_pad : outpad generic map (tech => padtech) port map (txd1, duo.txd);
    dui.rxd <= rxd1 when gpioo.val(0) = '1' else '1';
  end generate;

  txd1 <= duo.txd when  gpioo.val(0) = '1' else u1o.txd;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd(0));
  end generate;
  
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------

  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";
  memi.brdyn <= '1'; memi.bexcn <= '1';

  mctrl0 : if CFG_MCTRL_LEON2 = 1 generate
    mctrl0 : mctrl generic map (hindex => 3, pindex => 0, 
	ramaddr => 16#400# + CFG_DDR2SP*16#800#, rammask => 16#FE0#,
	paddr => 0, srbanks => 1, ram8 => CFG_MCTRL_RAM8BIT, 
	ram16 => CFG_MCTRL_RAM16BIT, sden => CFG_MCTRL_SDEN, 
	invclk => CFG_MCTRL_INVCLK, sepbus => CFG_MCTRL_SEPBUS)
    port map (rstn, clkm, memi, memo, ahbsi, ahbso(3), apbi, apbo(0), wpo, open);
  end generate;

  flash_adv_n_pad : outpad generic map (tech => padtech) 
	port map (flash_adv_n, gnd(0)); 
  sram_adv_ld_n_pad : outpad generic map (tech => padtech) 
	port map (sram_adv_ld_n, gnd(0)); 
  sram_mode_pad : outpad generic map (tech => padtech) 
	port map (sram_mode, gnd(0)); 
  addr_pad : outpadv generic map (width => 24, tech => padtech) 
	port map (sram_flash_addr, memo.address(24 downto 1)); 
  rams_pad : outpad generic map ( tech => padtech) 
	port map (sram_cen, memo.ramsn(0)); 
  roms_pad : outpad generic map (tech => padtech) 
	port map (flash_ce, memo.romsn(0)); 
  ramoen_pad  : outpad generic map (tech => padtech) 
	port map (sram_oen, memo.ramoen(0));
  flash_oen_pad  : outpad generic map (tech => padtech) 
	port map (flash_oen, memo.oen);
--pragma translate_off
  iosn_pad  : outpad generic map (tech => padtech) 
	port map (iosn, memo.iosn);
--pragma translate_on
  rwen_pad : outpadv generic map (width => 2, tech => padtech) 
	port map (sram_bw(0 to 1), memo.wrn(3 downto 2)); 
  rwen_pad2 : outpadv generic map (width => 2, tech => padtech) 
	port map (sram_bw(2 to 3), memo.wrn(1 downto 0)); 
  wri_pad  : outpad generic map (tech => padtech) 
	port map (sram_flash_we_n, memo.writen);
  data_pads : iopadvv generic map (tech => padtech, width => 16)
      port map (sram_flash_data(15 downto 0), memo.data(31 downto 16), 
		memo.vbdrive(31 downto 16), memi.data(31 downto 16));
  data_pads2 : iopadvv generic map (tech => padtech, width => 16)
      port map (sram_flash_data(31 downto 16), memo.data(15 downto 0), 
		memo.vbdrive(15 downto 0), memi.data(15 downto 0));
 
  ddrsp0 : if (CFG_DDR2SP /= 0) generate 
    ddrc0 : ddr2spa generic map ( fabtech => fabtech, memtech => memtech, 
      hindex => 0, haddr => 16#400#, hmask => 16#E00#, ioaddr => 1, 
      pwron => CFG_DDR2SP_INIT, MHz => BOARD_FREQ_200/1000, TRFC => CFG_DDR2SP_TRFC, 
      clkmul => CFG_DDR2SP_FREQ/10, clkdiv => 20, ahbfreq => CPU_FREQ/1000,
      col => CFG_DDR2SP_COL, Mbyte => CFG_DDR2SP_SIZE, ddrbits => 64,
      ddelayb0 => CFG_DDR2SP_DELAY0, ddelayb1 => CFG_DDR2SP_DELAY1, 
      ddelayb2 => CFG_DDR2SP_DELAY2, ddelayb3 => CFG_DDR2SP_DELAY3, 
      ddelayb4 => CFG_DDR2SP_DELAY4, ddelayb5 => CFG_DDR2SP_DELAY5,
      ddelayb6 => CFG_DDR2SP_DELAY6, ddelayb7 => CFG_DDR2SP_DELAY7,
      numidelctrl => 3, norefclk => 0, odten => 3)
    port map ( rst, rstn, clk_200, clkm, clk_200, lock, clkml, clkml, ahbsi, ahbso(0),
               ddr_clkv, ddr_clkbv, ddr_clk_fb, ddr_clk_fb, ddr_ckev, ddr_csbv, ddr_web, ddr_rasb, ddr_casb, 
               ddr_dm, ddr_dqsp, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt);
    ddr_clk <= ddr_clkv(1 downto 0); ddr_clkb <= ddr_clkbv(1 downto 0);
    ddr_cke <= ddr_ckev(1 downto 0); ddr_csb <= ddr_csbv(1 downto 0);
  end generate;

  noddr :  if (CFG_DDR2SP = 0) generate lock <= '1'; end generate;

----------------------------------------------------------------------
---  System ACE I/F Controller ---------------------------------------
----------------------------------------------------------------------
  
  grace: if CFG_GRACECTRL = 1 generate
    grace0 : gracectrl generic map (hindex => 4, hirq => 13,
        haddr => 16#002#, hmask => 16#fff#, split => CFG_SPLIT)
      port map (rstn, clkm, clkace, ahbsi, ahbso(4), acei, aceo);
  end generate;
  nograce: if CFG_GRACECTRL /= 1 generate
    aceo <= gracectrl_none;
  end generate;
  
  sysace_mpa_pads : outpadv generic map (width => 7, tech => padtech) 
    port map (sysace_mpa, aceo.addr); 
  sysace_mpce_pad : outpad generic map (tech => padtech)
    port map (sysace_mpce, aceo.cen); 
  sysace_d_pads : iopadv generic map (tech => padtech, width => 16)
    port map (sysace_d, aceo.do, aceo.doen, acei.di); 
  sysace_mpoe_pad : outpad generic map (tech => padtech)
    port map (sysace_mpoe, aceo.oen);
  sysace_mpwe_pad : outpad generic map (tech => padtech)
    port map (sysace_mpwe, aceo.wen); 
  sysace_mpirq_pad : inpad generic map (tech => padtech)
    port map (sysace_mpirq, acei.irq);
  
  
----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  bpromgen : if CFG_AHBROMEN /= 0 generate
    brom : entity work.ahbrom
      generic map (hindex => 6, haddr => CFG_AHBRODDR, pipe => CFG_AHBROPIP)
      port map ( rstn, clkm, ahbsi, ahbso(6));
  end generate;

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------

  apb0 : apbctrl				-- AHB/APB bridge
  generic map (hindex => 1, haddr => CFG_APBADDR, nslaves => 16)
  port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo );

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart			-- UART 1
    generic map (pindex => 1, paddr => 1,  pirq => 2, console => dbguart,
	fifosize => CFG_UART1_FIFO)
    port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.extclk <= '0'; u1i.ctsn <= '0';
    u1i.rxd <= rxd1 when gpioo.val(0) = '0' else '1';
  end generate;

  led(0) <= gpioo.val(0); led(1) <= not rxd1;
  led(2) <= not duo.txd when gpioo.val(0) = '1' else not u1o.txd;

  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp			-- interrupt controller
    generic map (pindex => 2, paddr => 2, ncpu => NCPU)
    port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer 			-- timer unit
    generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ, 
	sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW, ntimers => CFG_GPT_NTIM, 
	nbits => CFG_GPT_TW)
    port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti.dhalt <= dsuo.tstop; gpti.extclk <= '0';
  end generate;

  nogpt : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  kbd : if CFG_KBD_ENABLE /= 0 generate
    ps21 : apbps2 generic map(pindex => 4, paddr => 4, pirq => 4)
      port map(rstn, clkm, apbi, apbo(4), moui, mouo);
    ps20 : apbps2 generic map(pindex => 5, paddr => 5, pirq => 5)
      port map(rstn, clkm, apbi, apbo(5), kbdi, kbdo);
  end generate;
  nokbd : if CFG_KBD_ENABLE = 0 generate apbo(5) <= apb_none; kbdo <= ps2o_none; end generate;
  kbdclk_pad : iopad generic map (tech => padtech)
      port map (ps2_keyb_clk,kbdo.ps2_clk_o, kbdo.ps2_clk_oe, kbdi.ps2_clk_i);
  kbdata_pad : iopad generic map (tech => padtech)
        port map (ps2_keyb_data, kbdo.ps2_data_o, kbdo.ps2_data_oe, kbdi.ps2_data_i);
  mouclk_pad : iopad generic map (tech => padtech)
      port map (ps2_mouse_clk, mouo.ps2_clk_o, mouo.ps2_clk_oe, moui.ps2_clk_i);
  mouata_pad : iopad generic map (tech => padtech)
        port map (ps2_mouse_data, mouo.ps2_data_o, mouo.ps2_data_oe, moui.ps2_data_i);

  vga : if CFG_VGA_ENABLE /= 0 generate
    vga0 : apbvga generic map(memtech => memtech, pindex => 6, paddr => 6)
      port map(rstn, clkm, clkvga, apbi, apbo(6), vgao);
      clk_sel <= "00";
  end generate;

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(memtech => memtech, pindex => 6, paddr => 6,
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG, 
	clk0 => 40000, clk1 => 40000, clk2 => 25000, clk3 => 15385, burstlen => 6)
       port map(rstn, clkm, clkvga, apbi, apbo(6), vgao, ahbmi, 
		ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG), clk_sel);
  end generate;

  vgadvi : if (CFG_VGA_ENABLE + CFG_SVGA_ENABLE) /= 0 generate 
    dvi0 : svga2ch7301c generic map (tech => fabtech, idf => 2)
      port map (lclk, rstraw, clk_sel, vgao, clkvga, clk25, clk40, clk65,
                clkvga, clk25, clk40, clk65, clkvga_p, clkvga_n, 
                vgalock, lcd_datal, lcd_hsyncl, lcd_vsyncl, lcd_del);
    
    i2cdvi : i2cmst
      generic map (pindex => 9, paddr => 9, pmask => 16#FFF#,
                   pirq => 14, filter => I2C_FILTER)
      port map (rstn, clkm, apbi, apbo(9), dvi_i2ci, dvi_i2co);
  end generate;

  novga : if (CFG_VGA_ENABLE + CFG_SVGA_ENABLE) = 0 generate 
     apbo(6) <= apb_none; vgalock <= '1';
     lcd_datal <= (others => '0'); clkvga_p <= '0'; clkvga_n <= '0';
     lcd_hsyncl <= '0'; lcd_vsyncl <= '0'; lcd_del <= '0';
     dvi_i2co.scloen <= '1'; dvi_i2co.sdaoen <= '1';
  end generate;

  tft_lcd_data_pad : outpadv generic map (width => 12, tech => padtech)
        port map (tft_lcd_data, lcd_datal);
  tft_lcd_clkp_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_clk_p, clkvga_p);
  tft_lcd_clkn_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_clk_n, clkvga_n);
  tft_lcd_hsync_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_hsync, lcd_hsyncl);
  tft_lcd_vsync_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_vsync, lcd_vsyncl);
  tft_lcd_de_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_de, lcd_del);
  tft_lcd_reset_pad : outpad generic map (tech => padtech)
    port map (tft_lcd_reset_b, rstn);
  dvi_i2c_scl_pad : iopad generic map (tech => padtech)
    port map (dvi_iic_scl, dvi_i2co.scl, dvi_i2co.scloen, dvi_i2ci.scl);
  dvi_i2c_sda_pad : iopad generic map (tech => padtech)
    port map (dvi_iic_sda, dvi_i2co.sda, dvi_i2co.sdaoen, dvi_i2ci.sda);

  gpio0 : if CFG_GRGPIO_ENABLE /= 0 generate     -- GPIO unit
    grgpio0: grgpio
    generic map(pindex => 8, paddr => 8, imask => 16#00F0#, nbits => 13)
    port map(rst => rstn, clk => clkm, apbi => apbi, apbo => apbo(8),
    gpioi => gpioi, gpioo => gpioo);
    gpio_pads : iopadvv generic map (tech => padtech, width => 13)
      port map (gpio, gpioo.dout(12 downto 0), gpioo.oen(12 downto 0), 
		gpioi.din(12 downto 0));
  end generate;

  ahbs : if CFG_AHBSTAT = 1 generate	-- AHB status register
    ahbstat0 : ahbstat generic map (pindex => 15, paddr => 15, pirq => 7,
	nftslv => CFG_AHBSTATN)
      port map (rstn, clkm, ahbmi, ahbsi, stati, apbi, apbo(15));
  end generate;

  i2cm: if CFG_I2C_ENABLE = 1 generate  -- I2C master
    i2c0 : i2cmst
    generic map (pindex => 12, paddr => 12, pmask => 16#FFF#,
                 pirq => 11, filter => I2C_FILTER)
    port map (rstn, clkm, apbi, apbo(12), i2ci, i2co);
    i2c_scl_pad : iopad generic map (tech => padtech)
      port map (iic_scl_main, i2co.scl, i2co.scloen, i2ci.scl);
    i2c_sda_pad : iopad generic map (tech => padtech)
      port map (iic_sda_main, i2co.sda, i2co.sdaoen, i2ci.sda);
  end generate i2cm;
  
-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

    eth1 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
      e1 : grethm generic map(hindex => NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE, 
	pindex => 11, paddr => 11, pirq => 12, memtech => memtech,
        mdcscaler => CPU_FREQ/1000, enable_mdio => 1, fifosize => CFG_ETH_FIFO,
        nsync => 1, edcl => CFG_DSU_ETH, edclbufsz => CFG_ETH_BUF,
        macaddrh => CFG_ETH_ENM, macaddrl => CFG_ETH_ENL, phyrstadr => 7,
	ipaddrh => CFG_ETH_IPM, ipaddrl => CFG_ETH_IPL, giga => CFG_GRETH1G)
      port map( rst => rstn, clk => clkm, ahbmi => ahbmi,
        ahbmo => ahbmo(NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_SVGA_ENABLE), 
	apbi => apbi, apbo => apbo(11), ethi => ethi, etho => etho); 

      emdio_pad : iopad generic map (tech => padtech) 
      port map (phy_mii_data, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
      etxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (phy_tx_clk, ethi.tx_clk);
      erxc_pad : clkpad generic map (tech => padtech, arch => 2) 
	port map (phy_rx_clk, ethi.rx_clk);
      erxd_pad : inpadv generic map (tech => padtech, width => 8) 
	port map (phy_rx_data, ethi.rxd(7 downto 0));
      erxdv_pad : inpad generic map (tech => padtech) 
	port map (phy_dv, ethi.rx_dv);
      erxer_pad : inpad generic map (tech => padtech) 
	port map (phy_rx_er, ethi.rx_er);
      erxco_pad : inpad generic map (tech => padtech) 
	port map (phy_col, ethi.rx_col);
      erxcr_pad : inpad generic map (tech => padtech) 
	port map (phy_crs, ethi.rx_crs);

      etxd_pad : outpadv generic map (tech => padtech, width => 8) 
	port map (phy_tx_data, etho.txd(7 downto 0));
      etxen_pad : outpad generic map (tech => padtech) 
	port map ( phy_tx_en, etho.tx_en);
      etxer_pad : outpad generic map (tech => padtech) 
	port map (phy_tx_er, etho.tx_er);
      emdc_pad : outpad generic map (tech => padtech) 
	port map (phy_mii_clk, etho.mdc);
      erst_pad : outpad generic map (tech => padtech) 
	port map (phy_rst_n, rstn);

      ethi.gtx_clk <= egtx_clk;

    end generate;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------

  ocram : if CFG_AHBRAMEN = 1 generate 
    ahbram0 : ahbram generic map (hindex => 7, haddr => CFG_AHBRADDR, 
	tech => CFG_MEMTECH, kbytes => CFG_AHBRSZ)
    port map ( rstn, clkm, ahbsi, ahbso(7));
  end generate;

-----------------------------------------------------------------------
---  AHB DEBUG --------------------------------------------------------
-----------------------------------------------------------------------

--  dma0 : ahbdma
--    generic map (hindex => CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG,
--	pindex => 13, paddr => 13, dbuf => 6)
--    port map (rstn, clkm, apbi, apbo(13), ahbmi, 
--	ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_GRETH+CFG_AHB_JTAG));

--  at0 : ahbtrace
--  generic map ( hindex  => 7, ioaddr => 16#200#, iomask => 16#E00#,
--    tech    => memtech, irq     => 0, kbytes  => 8) 
--  port map ( rstn, clkm, ahbmi, ahbsi, ahbso(7));

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------

--  nam1 : for i in (NCPU+CFG_AHB_UART+CFG_ETH+CFG_AHB_ETH+CFG_AHB_JTAG) to NAHBMST-1 generate
--    ahbmo(i) <= ahbm_none;
--  end generate;
--  nap0 : for i in 11 to NAPBSLV-1 generate apbo(i) <= apb_none; end generate;
--  nah0 : for i in 8 to NAHBSLV-1 generate ahbso(i) <= ahbs_none; end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------

-- pragma translate_off
  x : report_version 
  generic map (
   msg1 => system_table(XILINX_ML509),
   msg2 => "GRLIB Version " & tost(LIBVHDL_VERSION/1000) & "." & tost((LIBVHDL_VERSION mod 1000)/100)
      & "." & tost(LIBVHDL_VERSION mod 100) & ", build " & tost(LIBVHDL_BUILD),
   msg3 => "Target technology: " & tech_table(fabtech) & ",  memory library: " & tech_table(memtech),
   mdel => 1
  );
-- pragma translate_on
end;
