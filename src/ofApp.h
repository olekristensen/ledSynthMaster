#pragma once

#include "ofMain.h"
#include "ofxRFduinoApp.h"
#import "BLEDelegate.h"

class ofApp : public ofBaseApp, public ofxRFduinoApp {

	public:

    void setup();
    void update();
    void draw();
    
    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y);
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    void exit();
    
    void didDiscoverRFduino(CBPeripheral *rfduino, NSDictionary *advertisementData);
    void didUpdateDiscoveredRFduino(CBPeripheral *rfduino);
    void didConnectRFduino(CBPeripheral *rfduino);
    void didLoadServiceRFduino(CBPeripheral *rfduino);
    void didDisconnectRFduino(CBPeripheral *rfduino);
    void receivedData( unsigned char *data);
    
    void onBluetooth();
    
    bool acknowledged = true;
    
    BLEDelegate *ble;
    
    bool connected;
//
//     ofxRFduinoDelegate *rfduinoImpl;
};
