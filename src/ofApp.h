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
#include "ofxCv.h"


class GuiTheme : public BaseTheme
{
public:
    
    GuiTheme()
    {
        col_main_text = ledSynth::temperatureToColor(6300).getLerped(ofColor::black, 0.6);
        col_main_head = ofColor(64,255,0);
        col_main_area = ledSynth::temperatureToColor(6300);
        col_win_popup = ofColor::black;
        col_win_backg = ledSynth::temperatureToColor(6300).getLerped(ofColor::black, 0.075);
        setup();
    }
    
    void setup()
    {
        ImGuiStyle* style = &ImGui::GetStyle();
        
        style->WindowPadding            = ImVec2(15, 15);
        style->FramePadding             = ImVec2(5, 5);
        style->ItemSpacing              = ImVec2(12, 12);
        style->ItemInnerSpacing         = ImVec2(6, 6);
        //style->Alpha                    = 1.0f;
        //style->WindowFillAlphaDefault   = 1.0f;
        style->WindowRounding           = 0.0f;
        style->FrameRounding            = 4.0f;
        //style->IndentSpacing            = 6.0f;
        //style->ColumnsMinSpacing        = 50.0f;
        style->GrabMinSize              = 5.0f;
        style->GrabRounding             = 0.0f;
        //style->ScrollbarSize            = 12.0f;
        //style->ScrollbarRounding        = 0.0f;
    }
    
};

class ofApp : public ofBaseApp, public ofxRFduinoApp {

	public:

    void setup();
    void update();
    void draw();
    void layout();
    
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
    
    ofVec2f getMappedCoordsFromImage(ofVec2f v);
    ofVec2f getMappedCoordsFromNormalised(ofVec2f v);
    unsigned int getTemperature(ofVec2f v);
    float getIntensity(ofVec2f v);
    ofFloatColor getColor(ofVec2f v);
    unsigned int getTemperature(float x, float y);
    float getIntensity(float x, float y);
    ofFloatColor getColor(float x, float y);
    
    void onBluetooth();
    
    ofEasyCam cam;
    ofTrueTypeFont fontStatus;
    ofTrueTypeFont fontNode;
    float guiColumnWidth = 300;
    ofRectangle weatherRect;
    
    BLEDelegate *ble;
    vector<ledSynth*> ledSynths;
    
    ledSynth * draggedLedSynth;
    
    ofxImGui gui;
    bool showNodeGuis = false;
    
    ofImage digitalWeatherImage;
    int imageWidth;
    int imageHeight;

    unsigned int kelvinCold;
    unsigned int kelvinWarm;
    
    ofVec2f offset;

    float kelvinWarmRange;
    float kelvinColdRange;
    float temperatureSpeed = 0.3;
    float temperatureTime = 0.0;
    float temperatureSpread = 0.5;
    double temperatureSpreadCubic = 0.0;
    
    float brightnessRangeFrom = 0.0;
    float brightnessRangeTo = 1.0;
    float brightnessSpeed = 0.3;
    float brightnessTime = 0.0;
    float brightnessSpread = 0.5;
    double brightnessSpreadCubic = 0.0;
    
    float timeOffset = 1000.0;
    float lastTemperatureManipulationSeconds = 0;
    float lastBrightnessManipulationSeconds = 0;
    float manipulationTimeoutSeconds = 30.0;

    float statusbarHeight = 68;
    bool windowDidResize = false;
    
    ofVideoGrabber camera;
    
    ofxCv::FlowFarneback fb;
    ofxCv::FlowPyrLK lk;
    ofxCv::Flow* curFlow;
};
