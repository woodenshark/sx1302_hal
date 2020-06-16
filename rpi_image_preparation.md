# Woodenshark LoRa SX1302 Gateway software

## Prepare SD card with raspbian 
1. https://www.raspberrypi.org/downloads/raspberry-pi-os/
1. https://www.raspberrypi.org/documentation/installation/installing-images/README.md
1. make `/boot/wpa_supplicant.conf` as described in https://www.raspberrypi.org/documentation/configuration/wireless/headless.md to connect to your local WiFi network
1. enable ssh server by making empty file named `ssh` in `/boot` directory
1. add to /boot/config.txt
   ```
   dtparam=spi=on
   enable_uart=1
   dtoverlay=i2c-gpio,i2c_gpio_sda=19,i2c_gpio_scl=16,bus=1
   dtoverlay=pps-gpio,gpiopin=3
   ``` 
1. replace `/boot/overlays/i2c-gpio.dtbo` with this version https://drive.google.com/file/d/1-4vyUf83--nReBnNGhY_VZSHckXOEjo2/view?usp=sharing because of bug in new Raspberry OS images (https://github.com/raspberrypi/firmware/issues/1401)

## Power on, log in
1. install needed packages
   ```console
   sudo apt update
   sudo apt install gpiod i2c-tools git make gcc
   ```
1. enable UART in raspi-config
   ```console
   sudo raspi-config
   #5 Interfacing options -> P6 Serial -> No -> Yes
   ```
1. add i2c-dev and spidev modules to `/etc/modules`
   ```console
   sudo sh -c "echo 'i2c-dev\nspidev\n' >> /etc/modules"
   ```
1. reboot
   ```console
   sudo reboot
   ```
1. install sx1302_hal
   ```console
   git clone -b woodenshark_gw https://github.com/woodenshark/sx1302_hal.git
   cd sx1302_hal
   make
   ssh-keygen -t rsa
   ssh-copy-id -i ~/.ssh/id_rsa.pub pi@localhost
   make install
   make install_conf
   cd bin
   ./chip_id
   ```
1. shure that you can see chip id like `0x0016c001ff1038a4` and then run
   ```console
   sed -i "s_AA555A0000000000_$(./chip_id | grep "EUI:" | cut -d' ' -f4 | cut -c3-)_g" global_conf.json.sx1250.EU868
   ```
1. install systemd service
   ```console
   sudo cp ~/sx1302_hal/tools/systemd/lora_pkt_fwd.service /etc/systemd/system
   sudo systemctl daemon-reload
   sudo systemctl enable lora_pkt_fwd.service
   sudo reboot
   ```
1. make a tea and take a rest, you are done!
1. use `sudo journalctl -u lora_pkt_fwd -f` to view packet_forwarder log
