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

@synthesize manufacturer;

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
    
    [peripheral setDelegate:nil];
    [peripheral release];
    
    [bleDevices release];
    
    [manager release];
    
    [super dealloc];
}

- (void)cleanup
{
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


- (void) initialize
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void) setApplication:( ofxRFduinoApp* )application
{
    app = application;
}

/*
 Disconnect peripheral when application terminate 
*/
- (void) applicationWillTerminate:(NSNotification *)notification
{
    if(peripheral)
    {
        [manager cancelPeripheralConnection:peripheral];
    }
}

#pragma mark - Scan sheet methods



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
    
//    NSLog(@"Central manager state: %@", state);
//    
//    [self cancelScanSheet:nil];
//    
//    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
//    [alert setMessageText:state];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setIcon:[[[NSImage alloc] initWithContentsOfFile:@"AppIcon"] autorelease]];
//    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
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
    peripheral = aPeripheral;
    [peripheral retain];
    [manager connectPeripheral:peripheral options:nil];
}


#pragma mark - CBCentralManager delegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central 
{
    //[self isLECapableHardware];
    app->onBluetooth();
}

/*
 Invoked when the central discovers devices while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI 
{    
    //NSMutableArray *peripherals = [self mutableArrayValueForKey:@"bleDevices"];
//    if( ![self->bleDevices containsObject:aPeripheral] )
//    {
//        [peripherals addObject:aPeripheral];
//    }
    
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
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
//    peripheral = aPeripheral;
//    [peripheral retain];
    
    app->didConnectRFduino(aPeripheral);

}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{

    if( peripheral )
    {
        [peripheral setDelegate:nil];
        [peripheral release];
        peripheral = nil;
        
        app->didDisconnectRFduino(aPeripheral);
        
    }
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
//    [connectButton setTitle:@"Connect"]; 
    if( peripheral )
    {
        [peripheral setDelegate:nil];
        [peripheral release];
        peripheral = nil;
    }
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error 
{
    for (CBService *aService in aPeripheral.services) 
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"2220"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
            app->didLoadServiceRFduino(aPeripheral);
        }
        
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */

- (void) send:( unsigned char *) data len:(int)length
{
    for (CBService *aService in peripheral.services)
    {
        if( [aService.UUID isEqual:[CBUUID UUIDWithString:@"2220"]])
        {
            for (CBCharacteristic *aChar in aService.characteristics)
            {
                /* rfduino send */
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2222"]])
                {
                    //[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                    NSData *d = [NSData dataWithBytes:data length:length];
                    [peripheral writeValue:d forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
                }
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"2220"]]) 
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* rfduino receive */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2221"]])
            {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found a receive ");
            }
            /* rfduino send */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2222"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found send");
            } 
            
            /* rfduino disconnect */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2223"]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found disconnect");
            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) 
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) 
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* Read manufacturer name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) 
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2221"]])
    {
        NSData * updatedValue = characteristic.value;
        uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
        app->receivedData(dataPointer);
    }
//    /* Value for body sensor location received */
//    else  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]]) 
//    {
//        NSData * updatedValue = characteristic.value;        
//        uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
//        if(dataPointer)
//        {
//            uint8_t location = dataPointer[0];
//            NSString*  locationString;
//            switch (location)
//            {
//                case 0:
//                    locationString = @"Other";
//                    break;
//                case 1:
//                    locationString = @"Chest";
//                    break;
//                case 2:
//                    locationString = @"Wrist";
//                    break;
//                case 3:
//                    locationString = @"Finger";
//                    break;
//                case 4:
//                    locationString = @"Hand";
//                    break;
//                case 5:
//                    locationString = @"Ear Lobe";
//                    break;
//                case 6: 
//                    locationString = @"Foot";
//                    break;
//                default:
//                    locationString = @"Reserved";
//                    break;
//            }
//            NSLog(@"Body Sensor Location = %@ (%d)", locationString, location);
//        }
//    }
//    /* Value for device Name received */
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
//    {
//        NSString * deviceName = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
//        NSLog(@"Device Name = %@", deviceName);
//    } 
//    /* Value for manufacturer name received */
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) 
//    {
//        self.manufacturer = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
//        NSLog(@"Manufacturer Name = %@", self.manufacturer);
//    }
}

@end
