//
//  BLEPeripheralDelegate.cpp
//  ledSynthMaster
//
//  Created by ole kristensen on 27/05/15.
//
//

#include "BLEPeripheralDelegate.h"
#include "ofxRFduino.h"

@implementation BLEPeripheralDelegate

- (void) setApplication:( ofxRFduinoApp* )application
{
    app = application;
}

- (void) cleanup
{
    ;
}

- (ofxRFduinoApp* ) getApplication
{
    return app;
}

- (void) setRFDuino:(ofxRFduino *)aRfDuino
{
    rfDuino = aRfDuino;
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
        
            //if(aService.characteristics)
            //    [self peripheral:aPeripheral didDiscoverCharacteristicsForService:aService error:nil];
            //else
                [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"2220"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* rfduino receive */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2221"]])
            {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
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
    peripheral = aPeripheral;
    app->didLoadServiceRFduino(aPeripheral);
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2221"]])
    {
        NSData * updatedValue = characteristic.value;
        //NSLog(@"Received data: %@", updatedValue);
        rfDuino->receivedData(updatedValue);
    }
}

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


@end
