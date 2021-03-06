//
//  ofxRFduinoApp.h
//  rfduino
//
//  Created by Joshua Noble on 8/5/14.
//
//

#ifndef rfduino_ofxRFduinoApp_h
#define rfduino_ofxRFduinoApp_h

#import <IOBluetooth/IOBluetooth.h>

class ofxRFduinoApp
{
public:
    virtual void didDiscoverRFduino(CBPeripheral * rfduino, NSDictionary * advertisementData) = 0;
    virtual void didDiscoverRFduino(CBPeripheral * rfduino) = 0;
    virtual void didUpdateDiscoveredRFduino(CBPeripheral * rfduino) = 0;
    virtual void didConnectRFduino(CBPeripheral * rfduino) = 0;
    virtual void didLoadServiceRFduino(CBPeripheral * rfduino) = 0;
    virtual void didDisconnectRFduino(CBPeripheral *rfduino) = 0;
    virtual void disconnectRFduino(CBPeripheral *rfduino) = 0;
    
    virtual void onBluetooth() = 0;
    
};
#endif
