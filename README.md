# Elevator Controller VHDL

This VHDL file (`elevator_controller.vhdl`) implements an elevator controller for a multi-floor elevator system. It provides the control logic necessary to manage the movement of the elevator car between floors, process floor selection requests from users, and display relevant information on the elevator control panel.

## Functionality

- **Floor Selection:** The controller processes input signals from floor selection buttons (`cabin_btn`) to determine the desired floor.
- **Floor Position Sensing:** It monitors signals from floor position sensors (`floor_sensor`) to determine the current position of the elevator car.
- **Motor Control:** Based on the desired floor and current position, the controller activates the elevator motor (`motor_led`) to move the car up or down.
- **Display Control:** It controls the display of floor numbers (`floor_led`) and other relevant information on the elevator control panel.
- **Alarm Management:** The controller includes functionality to manage an alarm system (`alarm_led`) in case of emergencies.

## Usage

This VHDL file can be used as a module within a larger digital design project for implementing the control logic of a multi-floor elevator system. It provides a modular and reusable solution for elevator control, facilitating easy integration into various designs.

## License

This VHDL code is provided under the CC0 1.0 Universal License, allowing for unrestricted use, modification, and distribution without requiring attribution or permission.

