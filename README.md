# ESP-BOX

The ESP-BOX based on ESP32-S3-BOX and ESP32-S3-BOX-Lite AIoT development boards that
are based on Espressif’s ESP32-S3 Wi-Fi + Bluetooth 5 (LE) SoC. The following
documents introduce more information about boards:

- [ESP32-S3-BOX](https://github.com/espressif/esp-box/blob/master/docs/hardware_overview/esp32_s3_box/hardware_overview_for_box.md)
- [ESP32-S3-BOX-Lite](https://github.com/espressif/esp-box/blob/master/docs/hardware_overview/esp32_s3_box_lite/hardware_overview_for_lite.md)

## Examples

- i2c_scan: scan all integrated I2C bus device and print its name with I2C bus address
- tft_demo: draw stopwatch and time per screen refreshing
- touchpad: read data from touchpad and print description

### Installing with Jaguar
Installing with Jaguar is mainly for testing, as Jaguar is already set up with
WiFi credentials.

Install Jaguar as described in the [Jaguar README](https://github.com/toitlang/jaguar/blob/main/README.md).

Flash a new device by following the instructions in the README.

All further commands should be executed in the `examples` folder.
```sh
cd examples
```

Install the package dependencies:
```sh
jag pkg install
```

Then install the example(i2c_scan) as a new container:
```sh
jag container install -D jag.disabled -D jag.timeout=2m  i2c_scan i2c_scan.toit
```
When the device reboots it will automatically start the provisioning process.

### With the Toit SDK
Download a Toit SDK from https://github.com/toitlang/toit/releases.
You will need the `toit-PLATFORM.tar.gz` and a firmware envelope (`firmware-MODEL.gz`).

Unzip the SDK and add the `toit/bin` and `toit/tools` folder to your path.

Unzip the firmware envelope. Make sure to *not* decompress the actual firmware archive file.
You can use `gunzip` to unzip the zipped file. You should end up with a single file and
not a folder.

All further commands should be executed in the `examples` folder.
```sh
cd examples
```

#### Install Dependencies

Install the package dependencies in the `examples` folder:

```sh
toit.pkg install
```

#### Compile and Flash

Compile the example(i2c_scan). From the examples folder:

```sh
toit.compile -w i2c_scan.snapshot i2c_scan.toit
```

Add it to the firmware (where `$FIRMWARE_ENVELOPE` is the path to the firmware envelope):

```sh
firmware -e "$FIRMWARE_ENVELOPE" container install i2c_scan i2c_scan.snapshot
```

Now you can flash the modified firmware to your ESP-BOX module.

```sh
firmware flash -e "$FIRMWARE_ENVELOPE" -p /dev/ttyACM0
```
You might need to change the `/dev/ttyACM0` to the correct port.
