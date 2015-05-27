//
//  ledSynth.cpp
//  ledSynthMaster
//
//  Created by ole kristensen on 27/05/15.
//
//

#include "ledSynth.h"

ledSynth::ledSynth(){
    this->setup();
}

void ledSynth::setup(){
    parameters.setName("ledSynth " + ofToString(ownID));
    parameters.add(otherID.set("number",0,0,20));
    parameters.add(position.set("position",ofVec2f(0,0),ofVec2f(0,0),ofVec2f(1,1)));
    temperature.addListener(this,&ledSynth::temperatureChanged);
    parameters.add(temperature.set("temperature",0.0,0.0,1.0));
    intensity.addListener(this,&ledSynth::intensityChanged);
    parameters.add(intensity.set("intensity",0.0,0.0,1.0));
}

//--------------------------------------------------------------
void ledSynth::update(){
    ;
}

//--------------------------------------------------------------
void ledSynth::draw(){
    if(peripheral != NULL){
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            ofSetColor(255*intensity);
            break;
        case CBPeripheralStateConnecting:
            ofSetColor(0,255,0);
            break;
        case CBPeripheralStateDisconnected:
            ofSetColor(255,0,0);
            break;
        default:
            break;
    }
    }
    ofRect(0,0,100,300);
}

void ledSynth::receivedData( unsigned char *data)
{
    cout << data << endl;
}

void ledSynth::temperatureChanged(float & temperature)
{
    this->setTemperature(temperature);
}
void ledSynth::setTemperature(float temperature)
{
    this->temperature = temperature;
    sendFloat('T', temperature);
    
}
float ledSynth::getTemperature()
{
    return temperature;
}


void ledSynth::intensityChanged(float & intensity)
{
    this->setIntensity(intensity);
}
void ledSynth::setIntensity(float intensity)
{
    this->intensity = intensity;
    sendFloat('I', intensity);
}
float ledSynth::getIntensity()
{
    return intensity;
}

void ledSynth::sendFloat(char t, float f){
    
    unsigned char msg[] = { 0x01, t, '0', '0', '0', '0', '0' , '0', 0x03 };
    
    string fValue = ofToString(roundf(f*65535.0));
    for (int i = fValue.length()-1; i >= 0; i--){
        msg[7-i] = fValue.data()[fValue.length()-(1+i)];
    }

    this->send(msg,9);
    
}

