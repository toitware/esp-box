// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import gpio
import i2c

TT2100_FLIP_X  := 0x1
TT2100_FLIP_Y  := 0x2
TT2100_FLIP_XY := 0x4

INVALID_VALUE_ ::= -1

bytes2ushort bytes/ByteArray -> int:
  return (bytes[0] + (bytes[1] << 8))

class Action:
  TOUCH_PAD ::= 0x1
  PRESS_BUTTON ::= 0x3

  type/int
  time_stamp/int

  x/int := INVALID_VALUE_
  y/int := INVALID_VALUE_
  touch_pressure/int := INVALID_VALUE_

  button/int := INVALID_VALUE_
  button_pressure/int := INVALID_VALUE_

  constructor data/ByteArray:
    length/int := bytes2ushort data[0..2]
    type = data[2]
    time_stamp = bytes2ushort data[3..5]

    if type == TOUCH_PAD:
      num/int := data[5] & 0x1f
      if num > 0:
        x = bytes2ushort data[9..11]
        y = bytes2ushort data[11..13]
        touch_pressure = data[13]
    else if type == PRESS_BUTTON:
      if data[5] & 0x1:
        button = 1
      else if data[5] & 0x2:
        button = 2
      else if data[5] & 0x4:
        button = 3
      
      button_pressure = bytes2ushort data[6..8]

  /**
  string format:
      action name(timestamp): action details description
  */
  stringify -> string:
    if type == TOUCH_PAD:
      if x != INVALID_VALUE_:
        return "touch-pad($time_stamp): X=$x Y=$y Pressure=$touch_pressure"
      else:
        return "touch-pad($time_stamp): done"
    else if type == PRESS_BUTTON:
      return "presss-button($time_stamp): Button=$button Pressure=$button_pressure"
    else:
      return "Action is not supported"

class Driver:
  ADDRESS_/int ::= 0x24

  features/int
  width/int
  height/int
  ready_pin/gpio.Pin
  device/i2c.Device

  constructor .width/int .height/int i2c_bus/i2c.Bus .ready_pin/gpio.Pin --frequency/int=400_000 --flags/int=0:
    features = flags
    device = i2c_bus.device ADDRESS_

  capture -> Action?:
    if ready_pin.get == 0:
      index := device.read 2
      msg_len := bytes2ushort index[0..2]
      action := Action (device.read msg_len)
      if action.type == action.TOUCH_PAD and action.x != INVALID_VALUE_:
        if features & TT2100_FLIP_X != 0:
          action.x = width - action.x
        if features & TT2100_FLIP_Y != 0:
          action.y = height - action.y
        if features & TT2100_FLIP_XY != 0:
          x := action.x
          action.x = action.y
          action.y = x
      return action
    else:
      return null
