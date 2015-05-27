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
#include "ofxGui.h"

class ledSynth : public ofxRFduino {
    
public:
    
    ledSynth();
    
    void setup();
    void update();
    void draw();
    
    void receivedData( unsigned char *data);

    int ownID;
  
    void setTemperature(float temperature);
    void temperatureChanged(float & temperature);
    float getTemperature();

    void setIntensity(float intensity);
    void intensityChanged(float & intensity);
    float getIntensity();
    
    ofParameterGroup parameters;
    ofParameter<int> otherID;
    ofParameter<ofVec2f> position;
    ofParameter<float> temperature;
    ofParameter<float> intensity;

private:
    void sendFloat(char t, float f);
};


#endif /* defined(__ledSynthMaster__ledSynth__) */
