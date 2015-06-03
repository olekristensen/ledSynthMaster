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
#include "ofxUI.h"
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
    
    ofRectangle bounds;
    
    void receivedData( NSData *data);
    
    int index;
    static int nextIndex;
    
    int ownID;
    
    void guinoInit();
    void guinoClear();
    void setGUI();
    void connect();
    
    void setBounds(ofRectangle newBounds);
    
    ofxUICanvas *gui;
    
    void guiEvent(ofxUIEventArgs &e);
    
    ofxUIMovingGraph *mg;
    float *buffer;
    ofImage *img;
    std::queue <char> inputQueue;
    
private:
    
    float red, green, blue;
    
    bool connected = false;
    
    EasyTransfer ET;
    
    // COMMAND STRUCTURE
    
#define guino_executed -1
#define guino_init 0
#define guino_addSlider 1
#define guino_addButton 2
#define guino_iamhere 3
#define guino_addToggle 4
#define guino_addRotarySlider 5
#define guino_saveToBoard 6
#define guino_setFixedGraphBuffer 8
#define guino_clearLabel 7
#define guino_addWaveform 9
#define guino_addColumn 10
#define guino_addSpacer 11
#define guino_xypad 18
#define guino_addLabel 12
#define guino_addMovingGraph 13
#define guino_buttonPressed 14
#define guino_addChar 15
#define guino_setMin 16
#define guino_setMax 17
#define guino_setValue 20
#define guino_setColor  21
#define guino_addDropdown 22
    
    struct RECEIVE_DATA_STRUCTURE{
        //put your variable definitions here for the data you want to receive
        //THIS MUST BE EXACTLY THE SAME ON THE OTHER ARDUINO
        int16_t cmd = guino_executed;
        int16_t item = 0;
        int16_t value = 0;
    };
    

    
    vector<ofxUIWidget *> guino_items;
    
    // END COMMAND STRCUTURE
    
    RECEIVE_DATA_STRUCTURE guino_data;
    
    float guiSize = 18;
    float guiMargin = OFX_UI_GLOBAL_WIDGET_SPACING*2;
    
};


#endif /* defined(__ledSynthMaster__ledSynth__) */
