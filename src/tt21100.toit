// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import gpio
import i2c
import binary show LITTLE_ENDIAN

TT2100_FLIP_X  := 0x1
TT2100_FLIP_Y  := 0x2
TT2100_FLIP_XY := 0x4

TOUCH_PAD ::= 0x1
PRESS_BUTTON ::= 0x3

INVALID_VALUE ::= -1

class Event:
  type/int
  time_stamp/int

  x/int := INVALID_VALUE
  y/int := INVALID_VALUE
  touch_pressure/int := INVALID_VALUE

  button/int := INVALID_VALUE
  button_pressure/int := INVALID_VALUE

  constructor data/ByteArray:
    length/int := LITTLE_ENDIAN.uint16 data 0
    type = data[2]
    time_stamp = LITTLE_ENDIAN.uint16 data 3

    if type == TOUCH_PAD:
      num/int := data[5] & 0x1f
      if num > 0:
        x = LITTLE_ENDIAN.uint16 data 9
        y = LITTLE_ENDIAN.uint16 data 11
        touch_pressure = data[13]
    else if type == PRESS_BUTTON:
      if data[5] & 0x1:
        button = 1
      else if data[5] & 0x2:
        button = 2
      else if data[5] & 0x4:
        button = 3
      
      button_pressure = LITTLE_ENDIAN.uint16 data 6

  /**
  Returns a string representation of this instance.
  String format:
      event name(timestamp): event details description
  */
  stringify -> string:
    if type == TOUCH_PAD:
      if x != INVALID_VALUE:
        return "touch-pad($time_stamp): X=$x Y=$y Pressure=$touch_pressure"
      else:
        return "touch-pad($time_stamp): done"
    else if type == PRESS_BUTTON:
      return "presss-button($time_stamp): Button=$button Pressure=$button_pressure"
    else:
      return "Action is not supported"

class Tt21100:
  static I2C_ADDRESS ::= 0x24

  features/int
  width/int
  height/int
  ready_pin/gpio.Pin
  device/i2c.Device

  constructor i2c_bus/i2c.Bus .ready_pin/gpio.Pin --frequency/int=400_000 --flags/int=0 --.width/int --.height/int:
    features = flags
    device = i2c_bus.device I2C_ADDRESS

  capture -> Event?:
    if ready_pin.get != 0:
      return null

    index := device.read 2
    msg_len := LITTLE_ENDIAN.uint16 index 0
    event := Event (device.read msg_len)
    if event.type == TOUCH_PAD and event.x != INVALID_VALUE:
      if features & TT2100_FLIP_X != 0:
        event.x = width - event.x
      if features & TT2100_FLIP_Y != 0:
        event.y = height - event.y
      if features & TT2100_FLIP_XY != 0:
        x := event.x
        event.x = event.y
        event.y = x
    return event
