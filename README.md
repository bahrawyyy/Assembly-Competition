## Assembly Smart Home (Fan control system)
This repository contains an assembly-based project that controls a fan based on temperature readings from the LM35 temperature sensor. An LCD is used to enhance the user experience by displaying the current temperature and fan status. The project is implemented on the STM32F103 microcontroller.

### Table of Contents
- Introduction
- Features
- Hardware Requirements
- Software Requirements
- Project Structure
- Installation and Setup
- Usage
- Contributing
- License
--


## Introduction
This project demonstrates a temperature-based fan control system using the STM32F103 microcontroller. The system reads the temperature from an LM35 sensor, and based on predefined thresholds, it controls the speed of a connected fan. The temperature readings and fan status are displayed on an LCD to provide real-time feedback to the user.

## Features
- Temperature Sensing: Accurate temperature measurement using the LM35 sensor.
- Fan Control: Fan speed control based on temperature thresholds.
- LCD Display: Real-time display of temperature and fan status for enhanced user experience.
- Low-Level Programming: Entire project is implemented in assembly language.
---

## Hardware Requirements
- STM32F103C6/C8 Microcontroller
- LM35 Temperature Sensor
- 16x2 LCD (HD44780 Controller)
- Fan (DC Motor)
- Resistors, Capacitors, and other passive components as needed
- Breadboard and Jumper Wires for prototyping


## Software Requirements
- Keil uVision
- Proteus
- ST-Link or other programming/debugging tool for STM32

## Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes. Make sure to follow the existing coding style and include detailed descriptions of your modifications.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
