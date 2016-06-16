#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "ofxRFDuinoApp.h"

class ofxRFduino;

@interface BLEPeripheralDelegate : NSObject <CBPeripheralDelegate>
{
    
    CBPeripheral *peripheral;
    ofxRFduino* rfDuino;
    ofxRFduinoApp *app;

}

- (void) cleanup;
- (void) send:( unsigned char *) data len:(int)length;
- (void) setApplication:( ofxRFduinoApp* )application;
- (ofxRFduinoApp*) getApplication;
- (void) setRFDuino:( ofxRFduino* ) rfDuino;

@end
