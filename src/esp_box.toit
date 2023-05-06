// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import color_tft show *
import gpio
import i2c
import pixel_display
import spi
import .tt21100

BSP_CONFIG_DEFAULT ::= BspConfig

class BspConfig:
  i2c_scl_pin/int ::= ?
  i2c_sda_pin/int ::= ?
  i2c_clock/int ::= ?

  lcd_width/int ::= ?
  lcd_height/int ::= ?
  lcd_freq_hz/int ::= ?

  lcd_color_depth/int ::= ?
  lcd_color_invert/bool ::= ?
  lcd_color_flip_x/bool ::= ?
  lcd_color_flip_y/bool ::= ?
  lcd_color_flip_xy/bool ::= ?

  lcd_spi_cs_pin/int ::= ?
  lcd_spi_clk_pin/int ::= ?
  lcd_spi_mosi_pin/int ::= ?

  lcd_dc_pin/int ::= ?
  lcd_reset_pin/int ::= ?
  lcd_backlight_pin/int ::= ?

  touchpad_flip_x/bool ::= ?
  touchpad_flip_y/bool ::= ?
  touchpad_flip_xy/bool ::= ?

  touchpad_i2c_addr/int ::= ?
  touchpad_ready_pin/int ::= ?

  constructor --.i2c_scl_pin/int=18
              --.i2c_sda_pin/int=8
              --.i2c_clock/int=400_000
              --.lcd_width/int=320
              --.lcd_height/int=240
              --.lcd_freq_hz/int=40_000_000
              --.lcd_color_depth/int=16
              --.lcd_color_invert/bool=false
              --.lcd_color_flip_x/bool=true
              --.lcd_color_flip_y/bool=true
              --.lcd_color_flip_xy/bool=false
              --.lcd_spi_cs_pin/int=5
              --.lcd_spi_clk_pin/int=7
              --.lcd_spi_mosi_pin/int=6
              --.lcd_dc_pin/int=4
              --.lcd_reset_pin/int=48
              --.lcd_backlight_pin/int=45
              --.touchpad_flip_x/bool=true
              --.touchpad_flip_y/bool=false
              --.touchpad_flip_xy/bool=false
              --.touchpad_i2c_addr/int=0x24
              --.touchpad_ready_pin/int=3:

class Device:
  config/BspConfig
  i2c_bus/i2c.Bus
  spi_bus/spi.Bus

  constructor .config/BspConfig=BSP_CONFIG_DEFAULT:
    i2c_bus = i2c.Bus
        --scl=(gpio.Pin config.i2c_scl_pin)
        --sda=(gpio.Pin config.i2c_sda_pin)
        --frequency=config.i2c_clock

    spi_bus = spi.Bus
        --clock=(gpio.Pin config.lcd_spi_clk_pin)
        --mosi=(gpio.Pin config.lcd_spi_mosi_pin)

  touchpad -> Tt21100:
    flags/int := 0
    if config.touchpad_flip_x:
      flags |= TT2100_FLIP_X
    
    if config.touchpad_flip_y:
      flags |= TT2100_FLIP_Y

    if config.touchpad_flip_xy:
      flags |= TT2100_FLIP_XY

    device := i2c_bus.device config.touchpad_i2c_addr
    tt21100 := Tt21100
        device
        gpio.Pin config.touchpad_ready_pin
        --flags=flags
        --width=config.lcd_width
        --height=config.lcd_height

    return tt21100

  display -> pixel_display.TrueColorPixelDisplay:
    flags/int := ?
    if config.lcd_color_depth == 16:
      flags = COLOR_TFT_16_BIT_MODE
    else if config.lcd_color_depth == 24:
      flags = 0
    else:
      throw "Color depth must be 16 or 24 bits"
    
    if config.lcd_color_flip_x:
      flags |= COLOR_TFT_FLIP_X
    
    if config.lcd_color_flip_y:
      flags |= COLOR_TFT_FLIP_Y

    if config.lcd_color_flip_xy:
      flags |= COLOR_TFT_FLIP_XY

    device := spi_bus.device
      --cs=(gpio.Pin config.lcd_spi_cs_pin)
      --dc=(gpio.Pin config.lcd_dc_pin)
      --frequency=config.lcd_freq_hz

    driver := ColorTft device config.lcd_width config.lcd_height
      --reset=(gpio.Pin config.lcd_reset_pin)
      --backlight=(gpio.Pin config.lcd_backlight_pin)
      --flags=flags
      --invert_colors=config.lcd_color_invert

    return pixel_display.TrueColorPixelDisplay driver
