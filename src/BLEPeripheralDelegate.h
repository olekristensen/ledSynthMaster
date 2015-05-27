#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "ofxRFDuinoApp.h"
#import "ofxRFDuino.h"

@interface BLEPeripheralDelegate : NSObject <CBPeripheralDelegate>
{
    
    CBPeripheral *peripheral;
    
    ofxRFduino* rfDuino;
    
    ofxRFduinoApp *app;

}

//- (void) cleanup;
- (void) send:( unsigned char *) data len:(int)length;
- (void) setApplication:( ofxRFduinoApp* )application;
- (void) setRFDuino:( ofxRFduino* ) rfDuino;

@end
