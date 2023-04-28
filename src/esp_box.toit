// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import color_tft show *
import gpio
import i2c
import pixel_display
import spi
import .tt21100

BSP_CONFIG_DEFAULT ::= bsp_config

class bsp_config:
  I2C_SCL_PIN := 18
  I2C_SDA_PIN := 8
  I2C_CLOCK := 400_000

  LCD_WIDTH/int := 320
  LCD_HEIGHT/int := 240
  LCD_FREQ_HZ/int := 40_000_000

  LCD_COLOR_DEPTH/int := 16
  LCD_COLOR_INVERT/bool := false
  LCD_COLOR_FLIP_X/bool := true
  LCD_COLOR_FLIP_Y/bool := true
  LCD_COLOR_FLIP_XY/bool := false

  LCD_SPI_CS_PIN/int := 5
  LCD_SPI_CLK_PIN/int := 7
  LCD_SPI_MOSI_PIN/int := 6

  LCD_DC_PIN/int := 4
  LCD_RESET_PIN/int := 48
  LCD_BACKLIGHT_PIN/int := 45

  TOUCHPAD_FLIP_X/bool := true
  TOUCHPAD_FLIP_Y/bool := false
  TOUCHPAD_FLIP_XY/bool := false

  TOUCHPAD_I2C_ADDR/int := 0x24
  TOUCHPAD_I2C_READY_PIN/int := 3

class device:
  config/bsp_config
  i2c_bus/i2c.Bus
  spi_bus/spi.Bus

  constructor .config/bsp_config=BSP_CONFIG_DEFAULT:
    i2c_bus = i2c.Bus
        --scl=(gpio.Pin config.I2C_SCL_PIN)
        --sda=(gpio.Pin config.I2C_SDA_PIN)
        --frequency=config.I2C_CLOCK

    spi_bus = spi.Bus
        --clock=(gpio.Pin config.LCD_SPI_CLK_PIN)
        --mosi=(gpio.Pin config.LCD_SPI_MOSI_PIN)

  touchpad -> Driver:
    flags/int := 0
    if config.TOUCHPAD_FLIP_X:
      flags |= TT2100_FLIP_X
    
    if config.TOUCHPAD_FLIP_Y:
      flags |= TT2100_FLIP_Y

    if config.TOUCHPAD_FLIP_XY:
      flags |= TT2100_FLIP_XY

    tt21100 := Driver
        config.LCD_WIDTH
        config.LCD_HEIGHT
        i2c_bus
        gpio.Pin config.TOUCHPAD_I2C_READY_PIN
        --frequency=config.I2C_CLOCK
        --flags=flags
    
    return tt21100

  display -> pixel_display.TrueColorPixelDisplay:
    flags/int := ?
    if config.LCD_COLOR_DEPTH == 16:
      flags = COLOR_TFT_16_BIT_MODE
    else if config.LCD_COLOR_DEPTH == 24:
      flags = 0
    else:
      throw "Color depth must be 16 or 24 bits"
    
    if config.LCD_COLOR_FLIP_X:
      flags |= COLOR_TFT_FLIP_X
    
    if config.LCD_COLOR_FLIP_Y:
      flags |= COLOR_TFT_FLIP_Y

    if config.LCD_COLOR_FLIP_XY:
      flags |= COLOR_TFT_FLIP_XY

    device := spi_bus.device
      --cs=(gpio.Pin config.LCD_SPI_CS_PIN)
      --dc=(gpio.Pin config.LCD_DC_PIN)
      --frequency=config.LCD_FREQ_HZ

    driver := ColorTft device config.LCD_WIDTH config.LCD_HEIGHT
      --reset=(gpio.Pin config.LCD_RESET_PIN)
      --backlight=(gpio.Pin config.LCD_BACKLIGHT_PIN)
      --flags=flags
      --invert_colors=config.LCD_COLOR_INVERT

    return pixel_display.TrueColorPixelDisplay driver
