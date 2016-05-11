#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "ofxRFDuinoApp.h"
#import "BLEPeripheralDelegate.h"

@interface BLEDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate>
{
    
    CBCentralManager *manager;
    
    NSMutableArray *bleDevices;
    
    ofxRFduinoApp *app;
    
}

- (void) cleanup;

- (void) startScan;
- (void) stopScan;
- (void) connectDevice:(CBPeripheral *) aPeripheral;
- (void) disconnectDevice:(CBPeripheral *) aPeripheral;
- (BOOL) isLECapableHardware;

- (void) initialize;

- (void) setApplication:( ofxRFduinoApp* )application;

@end
