// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import esp_box

main:
  device := esp_box.Device

  // Get touchpad driver.
  tp := device.touchpad

  while true:
    event := tp.capture
    if event:
      /**
      string format:
          event name(timestamp): event details description
      */
      print "$event"
    sleep --ms=10
