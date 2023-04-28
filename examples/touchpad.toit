// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import esp_box

main:
  device := esp_box.device

  // Get touchpad driver.
  tp := device.touchpad

  while true:
    action := tp.capture
    if action:
      /**
      string format:
          action name(timestamp): action details description
      */
      print "$action"
    sleep --ms=10
