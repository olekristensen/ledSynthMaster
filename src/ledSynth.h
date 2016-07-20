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
#include "ofxImGui.h"
#include <EasyTransfer.h>
#include <string>       // std::string
#include <iostream>     // std::cout
#include <sstream>      // std::stringstream

class ledSynth : public ofxRFduino {
    
public:

    static ofFloatColor temperatureToColor(unsigned int temp)
    {
        
        temp = ofClamp(temp, 1000, 10000);
        
        float blackbodyColor[91*3] =
        {
            1.0000, 0.0425, 0.0000, // 1000K
            1.0000, 0.0668, 0.0000, // 1100K
            1.0000, 0.0911, 0.0000, // 1200K
            1.0000, 0.1149, 0.0000, // ...
            1.0000, 0.1380, 0.0000,
            1.0000, 0.1604, 0.0000,
            1.0000, 0.1819, 0.0000,
            1.0000, 0.2024, 0.0000,
            1.0000, 0.2220, 0.0000,
            1.0000, 0.2406, 0.0000,
            1.0000, 0.2630, 0.0062,
            1.0000, 0.2868, 0.0155,
            1.0000, 0.3102, 0.0261,
            1.0000, 0.3334, 0.0379,
            1.0000, 0.3562, 0.0508,
            1.0000, 0.3787, 0.0650,
            1.0000, 0.4008, 0.0802,
            1.0000, 0.4227, 0.0964,
            1.0000, 0.4442, 0.1136,
            1.0000, 0.4652, 0.1316,
            1.0000, 0.4859, 0.1505,
            1.0000, 0.5062, 0.1702,
            1.0000, 0.5262, 0.1907,
            1.0000, 0.5458, 0.2118,
            1.0000, 0.5650, 0.2335,
            1.0000, 0.5839, 0.2558,
            1.0000, 0.6023, 0.2786,
            1.0000, 0.6204, 0.3018,
            1.0000, 0.6382, 0.3255,
            1.0000, 0.6557, 0.3495,
            1.0000, 0.6727, 0.3739,
            1.0000, 0.6894, 0.3986,
            1.0000, 0.7058, 0.4234,
            1.0000, 0.7218, 0.4485,
            1.0000, 0.7375, 0.4738,
            1.0000, 0.7529, 0.4992,
            1.0000, 0.7679, 0.5247,
            1.0000, 0.7826, 0.5503,
            1.0000, 0.7970, 0.5760,
            1.0000, 0.8111, 0.6016,
            1.0000, 0.8250, 0.6272,
            1.0000, 0.8384, 0.6529,
            1.0000, 0.8517, 0.6785,
            1.0000, 0.8647, 0.7040,
            1.0000, 0.8773, 0.7294,
            1.0000, 0.8897, 0.7548,
            1.0000, 0.9019, 0.7801,
            1.0000, 0.9137, 0.8051,
            1.0000, 0.9254, 0.8301,
            1.0000, 0.9367, 0.8550,
            1.0000, 0.9478, 0.8795,
            1.0000, 0.9587, 0.9040,
            1.0000, 0.9694, 0.9283,
            1.0000, 0.9798, 0.9524,
            1.0000, 0.9900, 0.9763,
            1.0000, 1.0000, 1.0000, /* 6500K */
            0.9771, 0.9867, 1.0000,
            0.9554, 0.9740, 1.0000,
            0.9349, 0.9618, 1.0000,
            0.9154, 0.9500, 1.0000,
            0.8968, 0.9389, 1.0000,
            0.8792, 0.9282, 1.0000,
            0.8624, 0.9179, 1.0000,
            0.8465, 0.9080, 1.0000,
            0.8313, 0.8986, 1.0000,
            0.8167, 0.8895, 1.0000,
            0.8029, 0.8808, 1.0000,
            0.7896, 0.8724, 1.0000,
            0.7769, 0.8643, 1.0000,
            0.7648, 0.8565, 1.0000,
            0.7532, 0.8490, 1.0000,
            0.7420, 0.8418, 1.0000,
            0.7314, 0.8348, 1.0000,
            0.7212, 0.8281, 1.0000,
            0.7113, 0.8216, 1.0000,
            0.7018, 0.8153, 1.0000,
            0.6927, 0.8092, 1.0000,
            0.6839, 0.8032, 1.0000,
            0.6755, 0.7975, 1.0000,
            0.6674, 0.7921, 1.0000,
            0.6595, 0.7867, 1.0000,
            0.6520, 0.7816, 1.0000,
            0.6447, 0.7765, 1.0000,
            0.6376, 0.7717, 1.0000,
            0.6308, 0.7670, 1.0000,
            0.6242, 0.7623, 1.0000,
            0.6179, 0.7579, 1.0000,
            0.6117, 0.7536, 1.0000,
            0.6058, 0.7493, 1.0000,
            0.6000, 0.7453, 1.0000,
            0.5944, 0.7414, 1.0000 /* 10000K */
        };
        
        float alpha = (temp % 100) / 100.0;
        int temp_index = ((temp - 1000) / 100)*3;
        
        ofFloatColor fromColor = ofFloatColor(blackbodyColor[temp_index], blackbodyColor[temp_index+1], blackbodyColor[temp_index+2]);
        ofFloatColor toColor = ofFloatColor(blackbodyColor[temp_index+3], blackbodyColor[temp_index+3+1], blackbodyColor[temp_index+3+2]);
        
        return fromColor.lerp(toColor, alpha);
    };

    ledSynth();
    ~ledSynth();
    
    void setup();
    void update();
    void draw(bool selected = false);
    
    void receivedData( NSData *data);
    void hardwareInit();
    
    void updateHardwareValue(ofAbstractParameter &param);
    
    bool updateHardware = true;
    bool initDone = false;
    
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

    ofParameter<int> identify      {"identify",      0,0,1};
    ofParameter<int> remoteOverride{"remoteOverride",                0,0,1};

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
        doSaveId,
        identify,
        remoteOverride
    };
    
    ofParameterGroup graphParameters {"graphParameters",
        mixRemote,
        intensityOutput,
        intensityFader,
        movementSensorLevel,
        mixNoise,
        lightSensorLightLevel,
        temperatureFader,
        temperatureOutput
    };
    
    vector<ofAbstractParameter *> paramsToUpdate;

    ofParameter<bool> connected       {"connected", false};
    ofParameter<bool> disconnect      {"disconnect", false};
    ofParameter<ofVec2f> position     {"position", ofVec2f(0,0), ofVec2f(-1,-1), ofVec2f(1,1)};

    ofParameterGroup parameters { "parameters",
        hardware,
        connected,
        disconnect,
        position
    };
    
    ofParameterGroup persistentParameters { "persistentParameters",
        remoteID,
        mixRemote,
        mixNoise,
        intensityFader,
        temperatureFader,
        intensityRemote,
        temperatureRemote,
        intensityRangeTop,
        intensityRangeBottom,
        temperatureRangeTop,
        temperatureRangeBottom,
        useRanges,
        movementSensorLedActive,
        position
    };

    void connect();
    
    void setBounds(ofRectangle newBounds);
    
    void drawGui();
    
    void removeListeners();
    
    float *buffer;
    ofImage *img;
    std::queue <char> inputQueue;
    
    // GUI
    
    bool guiShown = false;
    
    int hardwareUpdateIntervalMillis = 1000/2;

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
    #define cmd_init_done 11
    
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
    long nextHardwareUpdateMillis = 0;
};


#endif /* defined(__ledSynthMaster__ledSynth__) */
