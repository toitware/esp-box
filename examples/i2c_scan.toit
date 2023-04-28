// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import esp_box
import i2c
import gpio

main:
  device := esp_box.device

  device.i2c_bus.scan.do:
    desc := KNOWN_IDS.get it --if_absent=: ""
    print "0x$(%02x it) $desc"

KNOWN_IDS ::= {
  0x18: "ES8311: mono audio codec",
  0x24: "TT21100: touchpad sensor",
  0x40: "ES7210: 4 channels audio ADC",
  0x68: "ICM-42607-P(MPU6050): 6-axis motion sensor",
}
