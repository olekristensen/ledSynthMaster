//
//  ofxRFduino.h
//  ledSynthMaster
//
//  Created by ole kristensen on 27/05/15.
//
//

#ifndef ledSynthMaster_ofxRFduino_h
#define ledSynthMaster_ofxRFduino_h

#import <IOBluetooth/IOBluetooth.h>
#import "BLEPeripheralDelegate.h"
#include <iostream>

class ofxRFduino
{
public:
    
    virtual void receivedData( NSData *data ) = 0;
    void setPeripheral(CBPeripheral * p){
        std::cout << "SET PERIPHERAL" << std::endl;
        peripheral = p;
        [(BLEPeripheralDelegate*)[peripheral delegate] setRFDuino:this];
    };
    void send(unsigned char *data, int length){
        if(peripheral != NULL && canSend){
            [(BLEPeripheralDelegate*)[peripheral delegate] send:data len:length];
        }
    };
    bool canSend = false;
    
    CBPeripheral *peripheral;
};

#endif
