/*
 ledSynthMaster - a server/gateway for ledSynth dmx controllers
 for control praradigm experiments with LED fixtures.
 Copyright (C) 2015  Ole Kristensen
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 ole@kristensen.name
 olek@itu.dk
 */

#pragma once

#include "ofMain.h"
#include "ofxRFduinoApp.h"
#include "ledSynth.h"
#include "ofxImGui.h"
#import  "BLEDelegate.h"
#include "BaseTheme.h"

class GuiTheme : public BaseTheme
{
public:
    
    GuiTheme()
    {
        col_main_text = ofColor::darkGrey;
        col_main_head = ofColor(250,250,180,220);
        col_main_area = ofColor(225,225,200,200);
        col_win_popup = ofColor::black;
        col_win_backg = ofColor(255,255,200,200);
    }
    
};

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
    void disconnectRFduino(CBPeripheral *rfduino);
    
    void onBluetooth();
    
    ofEasyCam cam;
    ofTrueTypeFont fontStatus;
    ofTrueTypeFont fontNode;
    
    BLEDelegate *ble;
    vector<ledSynth*> ledSynths;
    
    ofxImGui gui;
    bool showNodeGuis;
    
    ofImage digitalWeatherImage;

    unsigned int kelvinCold;
    unsigned int kelvinWarm;
    
    float kelvinWarmRange;
    float kelvinColdRange;
    float temperatureSpeed;
    float temperatureTime;
    float temperatureSpread;
    
    float brightnessRangeFrom;
    float brightnessRangeTo;
    float brightnessSpeed;
    float brightnessTime;
    float brightnessSpread;
    
    float timeOffset = 100.0;
    float lastTemperatureManipulationSeconds = 0;
    float lastBrightnessManipulationSeconds = 0;
    float manipulationTimeoutSeconds = 30.0;


};
