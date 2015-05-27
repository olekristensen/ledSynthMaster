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
#include <iostream>

class ofxRFduino
{
public:
    
    virtual void receivedData( unsigned char *data) = 0;
    void setPeripheral(CBPeripheral * p){
        peripheral = p;
    };
    void send( unsigned char *data, int length){
        //std::cout << "ofxRF send"  << std::endl;
        [[peripheral delegate] send:data len:length];
    };
    
    CBPeripheral *peripheral;
};

#endif
