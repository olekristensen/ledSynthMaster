/*
     File: HeartRateMonitorAppDelegate.m
 Abstract: Implementatin of Heart Rate Monitor app using Bluetooth Low Energy (LE) Heart Rate Service. This app demonstrats the use of CoreBluetooth APIs for LE devices.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "BLEDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation BLEDelegate

//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//    self.heartRate = 0;
//
//    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    if( autoConnect )
//    {
//        [self startScan];
//    }
//}

- (void) close
{
    [self stopScan];
    
    for(CBPeripheral* peripheral in bleDevices){
        BLEPeripheralDelegate * pd = [peripheral delegate];
 //       [peripheral setDelegate:nil];
        [peripheral release];
        [pd release];
    }
    
    [bleDevices release];
    
    [manager release];
    
    [super dealloc];
}

- (void)cleanup
{
    for(CBPeripheral* peripheral in bleDevices){
        // See if we are subscribed to a characteristic on the peripheral
        if (peripheral.services != nil) {
            for (CBService *service in peripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        //if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                        //}
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        if( peripheral != nil)
        {
            [manager cancelPeripheralConnection:peripheral];
        }
    }
}


- (void) initialize
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"Initialised managaer: %@", manager);
}

- (void) setApplication:( ofxRFduinoApp* )application
{
    app = application;
    NSLog(@"set application");
}

/*
 Disconnect peripheral when application terminate 
*/
- (void) applicationWillTerminate:(NSNotification *)notification
{
    for(CBPeripheral* peripheral in bleDevices){
    if(peripheral)
    {
        [manager cancelPeripheralConnection:peripheral];
    }
    }
}

#pragma mark - Start/Stop Scan methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state]) 
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    return FALSE;
}

/*
 Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
 */
- (void) startScan 
{
    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2220"]] options:nil];
}

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan 
{
    [manager stopScan];
}

- (void) connectDevice:(CBPeripheral *) aPeripheral
{
    CBPeripheral * peripheral = aPeripheral;
    [peripheral retain];
    [manager connectPeripheral:peripheral options:nil];
}

- (void) disconnectDevice:(CBPeripheral *) aPeripheral
{
    CBPeripheral * peripheral = aPeripheral;
    [manager cancelPeripheralConnection:peripheral];
}


#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central 
{
    app->onBluetooth();
}

/*
 Invoked when the central discovers devices while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI 
{    
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"bleDevices"];
    if( ![self->bleDevices containsObject:aPeripheral] )
    {
        [peripherals addObject:aPeripheral];
    }
    
    app->didDiscoverRFduino(aPeripheral, advertisementData);
    
//    [manager retrievePeripherals:[NSArray arrayWithObject:(id)aPeripheral.UUID]];
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */
//- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
//{
//    //NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
//    
//    [self stopScan];
//    
//    /* If there are any known devices, automatically connect to it.*/
//    if([peripherals count] >=1)
//    {
//        for( CBPeripheral * p in peripherals )
//        {
//            app->didDiscoverRFduino(p);
//        }
//    }
//}

/*
 Invoked whenever a connection is succesfully created with the peripheral. 
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral 
{
    BLEPeripheralDelegate * pd = [[BLEPeripheralDelegate alloc] init];
    [pd retain];
    [pd setApplication:app];
    [aPeripheral setDelegate:pd];
    [aPeripheral discoverServices:nil];
    app->didConnectRFduino(aPeripheral);

}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    if([bleDevices containsObject:aPeripheral]){
        app->didDisconnectRFduino(aPeripheral);
        [bleDevices removeObject:aPeripheral];
        BLEPeripheralDelegate * pd = [aPeripheral delegate];
        [aPeripheral release];
        [pd release];
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    
    if([bleDevices containsObject:aPeripheral]){
        app->didDisconnectRFduino(aPeripheral);
        [bleDevices removeObject:aPeripheral];
        BLEPeripheralDelegate * pd = [aPeripheral delegate];
        [aPeripheral release];
        [pd release];
    }
}

@end
