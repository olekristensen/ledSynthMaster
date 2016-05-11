//
//  ledSynth.cpp
//  ledSynthMaster
//
//  Created by ole kristensen on 27/05/15.
//
//

#include "ledSynth.h"

int ledSynth::nextIndex = 0;

ledSynth::ledSynth(){
    index = nextIndex++;
    this->setup();
}

ledSynth::~ledSynth(){
    index = nextIndex--;
}

void ledSynth::setup(){
    position.set(ofVec2f(ofRandom(-1.0,1.0), ofRandom(-0.5,0.5)));
}

//--------------------------------------------------------------
void ledSynth::update(){
    if(peripheral != NULL){
        switch (peripheral.state) {
            case CBPeripheralStateConnected:

                if(!connected){
                    ET.begin((uint8_t*)&cmd_data, sizeof(cmd_data),this);
                    connected = true;
                    connectionEstablishedSeconds = ofGetElapsedTimef();
                }
                while(inputQueue.size() > 0 && ET.receiveData())
                    {
                        switch (cmd_data.cmd)
                        {
                            case cmd_setValue:
                                hardware.getInt(cmd_data.item) = cmd_data.value;
                                break;
                            case cmd_setMin:
                                hardware.getInt(cmd_data.item).setMin(cmd_data.value);
                                break;
                            case cmd_setMax:
                                hardware.getInt(cmd_data.item).setMax(cmd_data.value);
                                break;
                            case cmd_ping:
                                ofLogVerbose() << "ping" << endl;
                                hardwareInit();
                                break;

                        }
                        cmd_data.cmd = cmd_executed;
                    }
                break;
            case CBPeripheralStateConnecting:
                connected = false;
                break;
            case CBPeripheralStateDisconnected:
                connected = false;
                while(!inputQueue.empty()){
                    inputQueue.pop();
                }
                break;
            default:
                break;
        }
    }
}

//--------------------------------------------------------------
void ledSynth::draw(){
    ofPushMatrix();
    ofTranslate(position.get());
    if(connected) {
        ofSetColor(255,255);
    }else{
        ofSetColor(255,64);
    }
    ofFill();
    ofDrawCircle(0, 0, 0.1);
    ofSetColor(0,255);
    ofDrawBitmapString(ofToString(ownID),0,0);
    ofPopMatrix();
}

void ledSynth::receivedData(NSData *data )
{
    cout << "rec " << (char *)[data bytes] << endl;
    for (int i = 0; i < [data length]; i++) {
        inputQueue.push(*(((char *)[data bytes])+i));
    }
}

void ledSynth::hardwareInit()
{
    cmd_data.cmd = cmd_init;
    ET.sendData();
    cout << "sent init" << endl;
}