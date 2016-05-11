//
//  ledSynth.h
//  ledSynthMaster
//
//  Created by ole kristensen on 27/05/15.
//
//

#ifndef __ledSynthMaster__ledSynth__
#define __ledSynthMaster__ledSynth__

#include "ofMain.h"
#include "ofxRFduino.h"
#include <EasyTransfer.h>
#include <string>       // std::string
#include <iostream>     // std::cout
#include <sstream>      // std::stringstream

class ledSynth : public ofxRFduino {
    
public:
    
    ledSynth();
    ~ledSynth();
    
    void setup();
    void update();
    void draw();
    
    void receivedData( NSData *data);
    void hardwareInit();
    
    int index;
    static int nextIndex;

    ofParameter<int> ownID                  {"ownID",                   -1,0,9};
    ofParameter<int> remoteID               {"remoteID",                -1,0,9};
    ofParameter<int> versionMajor           {"versionMajor",                   -1,0,9999};
    ofParameter<int> versionMinor           {"versionMinor",                -1,0,9999};
    
    ofParameter<int> mixRemote              {"mixRemote",               0,0,5*12};
    ofParameter<int> mixNoise               {"mixNoise",                0,0,5*12};
    
    ofParameter<int> intensityFader         {"intensityFader",          0,0,1000};
    ofParameter<int> temperatureFader       {"temperatureFader",        4200,1000,10000};
    ofParameter<int> intensityRemote        {"intensityRemote",         0,0,1000};
    ofParameter<int> temperatureRemote      {"temperatureRemote",       4200,1000,10000};
    ofParameter<int> intensityNoise         {"intensityNoise",          0,0,1000};
    ofParameter<int> temperatureNoise       {"temperatureNoise",        4200,1000,10000};
    ofParameter<int> intensityOutput        {"intensityOutput",         0,0,1000};
    ofParameter<int> temperatureOutput      {"temperatureOutput",       4200,1000,10000};
    
    ofParameter<int> intensityRangeTop      {"intensityRangeTop",       1023,0,1023};
    ofParameter<int> intensityRangeBottom   {"intensityRangeBottom",    0,0,1023};
    ofParameter<int> temperatureRangeTop    {"temperatureRangeTop",     1023,0,1023};
    ofParameter<int> temperatureRangeBottom {"temperatureRangeBottom",  0,0,1023};
    ofParameter<int> useRanges              {"useRanges",               1,0,1};
    
    ofParameter<int> movementSensor         {"movementSensor",          0,0,1};
    ofParameter<int> movementSensorLevel    {"movementSensorLevel",     0,0,1000};
    ofParameter<int> movementSensorLedActive{"movementSensorLedActive", 1,0,1};
    
    ofParameter<int> lightSensorTemperature {"lightSensorTemperature",  0,0,10000};
    ofParameter<int> lightSensorLux         {"lightSensorLux",          0,0,30000};
    ofParameter<int> lightSensorLightLevel  {"lightSensorLightLevel",   0,0,1000};
    
    ofParameter<int> doFaderCalibration     {"doFaderCalibration",      0,0,1};
    ofParameter<int> doSaveId               {"doSaveId",                0,0,1};
    
    ofParameterGroup hardware {"node",
        ownID,
        remoteID,
        versionMajor,
        versionMinor,
        mixRemote,
        mixNoise,
        intensityFader,
        temperatureFader,
        intensityRemote,
        temperatureRemote,
        intensityNoise,
        temperatureNoise,
        intensityOutput,
        temperatureOutput,
        intensityRangeTop,
        intensityRangeTop,
        intensityRangeBottom,
        temperatureRangeTop,
        temperatureRangeBottom,
        useRanges,
        movementSensor,
        movementSensorLevel,
        movementSensorLedActive,
        lightSensorTemperature,
        lightSensorLux,
        lightSensorLightLevel,
        doFaderCalibration,
        doSaveId
    };

    ofParameter<bool> connected       {"connected", false};
    ofParameter<bool> disconnect      {"disconnect", false};
    ofParameter<ofVec2f> position     {"position", ofVec2f(0,0), ofVec2f(-1,-1), ofVec2f(1,1)};

    ofParameterGroup parameters { "parameters",
        hardware,
        connected,
        disconnect,
        position
    };

    void connect();
    
    void setBounds(ofRectangle newBounds);
    
    float *buffer;
    ofImage *img;
    std::queue <char> inputQueue;
    
private:
    
    EasyTransfer ET;
    
    // COMMAND STRUCTURE

    #define cmd_executed -1
    #define cmd_init 0
    #define cmd_ping 1
    #define cmd_setValue 2
    #define cmd_setMin 3
    #define cmd_setMax 4
    #define cmd_saveToBoard 9
    #define cmd_disconnect 10
    
    struct RECEIVE_DATA_STRUCTURE{
        //put your variable definitions here for the data you want to receive
        //THIS MUST BE EXACTLY THE SAME ON THE OTHER ARDUINO
        int16_t cmd = cmd_executed;
        int16_t item = 0;
        int16_t value = 0;
    };
    
    
    // END COMMAND STRCUTURE
    
    RECEIVE_DATA_STRUCTURE cmd_data;
    
    float connectionEstablishedSeconds = -1.0;
    float cmdPingTimeoutSeconds = 10.0;
    
};


#endif /* defined(__ledSynthMaster__ledSynth__) */
