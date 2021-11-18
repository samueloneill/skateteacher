# Skate Teacher
With this project I wanted to design a movement tracking device that could help skateboarders learn new tricks. The aim is for the device to be attached to a skateboard, and wirelessly provide feedback on trick attempts to the user's phone or PC. For example feedback may include telling the user to apply more/less force to an area of the board. 
Currently, the device itself has been designed and built, and a demo application for PC has been developed to visualise the movement of the skateboard. This application uses the Processing IDE (based on Java). The device itself is made up of a SAMD21 microcontroller on a QtPy breakout board, programmed using Arduino. A BNO055 IMU is used for tracking, and data is sent to the application via a serial connection. 



# Updates to come
This project is a work in progress. My plan is for several updates including:
- machine-learning based trick feedback
- wireless communication using IoT and/or Bluetooth
- mobile application
