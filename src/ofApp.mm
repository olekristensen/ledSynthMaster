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

#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetLogLevel(OF_LOG_NOTICE);
    ofSetCircleResolution(200);

    ble = [[BLEDelegate alloc] init];
    [ble initialize];
    [ble setApplication:this];
    
    ofEnableAntiAliasing();
    
    fontStatus.load("fonts/Avenir.ttc", 10, true, true, true);
    fontNode.load("fonts/Avenir Next.ttc", 10, true, true, true);
    
}

void ofApp::exit(){

    [ble cleanup];
}

//--------------------------------------------------------------
void ofApp::update(){
    
    if(ofGetFrameNum() == 3){
        cam.disableMouseInput();
    }
    int index = 0;

    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        
        // update values
        
        if(l->connected){
        if (l->ownID > 0 && l->mixRemote >= 0 && l->remoteID >= 0) {
            
      
            if(l->ownID != l->remoteID) {
                if(l->remoteID == 0){
                 // using light sensor
                    
                    ;
                    
                } else {
                    
                    ledSynth * remote = NULL;
                    
                    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
                        ledSynth * r = *it;
                        if (r->ownID == l->remoteID) {
                            remote = r;
                            break;
                        }
                    }
                    
                    if(remote != NULL){
                        
                        l->intensityRemote = remote->intensityOutput;
                        l->temperatureRemote = remote->temperatureOutput;
                    }
                }
            }
        
        }
        }

        l->update();
        // rearrange
        
        
        index++;
    }
    
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofBackgroundGradient(ofColor::lightGrey, ofColor::whiteSmoke);
    
    // Nodes
    
    ofPushMatrix();
    float scale = ofGetWidth() / 2.0;
    cam.begin();
    ofScale(scale, scale, scale);
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        l->draw();
        ofSetColor(0, 0, 0, 64);
        ofPushMatrix();
        ofTranslate(l->position.get());
        ofScale(1/scale,1/scale,1/scale);
        fontNode.drawStringAsShapes(ofToString(l->ownID), -fontNode.stringWidth(ofToString(l->ownID))*0.55, -fontNode.stringHeight(ofToString(l->ownID))*0.35);
        ofPopMatrix();
        
    }
    
    // Connections
    
    ofSetColor(63,255);
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        if(l->remoteID != l->ownID){
            
            ledSynth * remote = NULL;
            
            for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
                ledSynth * r = *it;
                if (r->ownID == l->remoteID) {
                    remote = r;
                    break;
                }
            }
            
            if(remote != NULL){
                ofDrawArrow(remote->position.get(), l->position.get(), 0.01);
            }
        }
    }
    
    cam.end();
    ofPopMatrix();
    
    // Guis
    
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        l->gui.draw();
    }
    
    // Status bar
    
    string status = ([ble isLECapableHardware]?"Bluetooth LE supported":"No Bluetooth LE support");
    status += "\n" + ofToString(ledSynth::nextIndex) + " devices connected";
    status += "\nFPS: " + ofToString(ofGetFrameRate(), 2);
    
    float statusbarMargin = 20;
    float statusbarHeight = fontStatus.stringHeight(status) + (statusbarMargin * 2.0);
    ofSetColor(255, 200);
    ofDrawRectangle(0, ofGetHeight()-statusbarHeight, ofGetWidth(), statusbarHeight);
    ofSetColor(0, 127);
    ofPushMatrix();
    ofTranslate(statusbarMargin, (ofGetHeight()-statusbarHeight)+32);
    fontStatus.drawString(status, 0, 0);
    ofPopMatrix();

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}

void ofApp::onBluetooth()
{
    if([ble isLECapableHardware])
    {
        [ble startScan];
        ofLogNotice() << " started scanning " << endl;
    }
    else
    {
        ofLogError() << " uh oh, this computer won't work :( :( :( :( " << endl;
        exit();
    }
}

void ofApp::didDiscoverRFduino(CBPeripheral *peripheral, NSDictionary *advertisementData)
{
    ofLogNotice() << " didDiscoverRFduino " << [[peripheral name] UTF8String];
    ofLogNotice() << " advertising " << [[advertisementData description] UTF8String] << endl;
    
    if( [[peripheral name] isEqualTo:@"LEDSYNTH"] || [[peripheral name] isEqualTo:@"light node"])
    {
        
        bool isNew = true;
        for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
            ledSynth * l = *it;
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
                isNew = false;
                ofLogNotice() << [peripheral identifier] << " allready connected" << endl;
                //[ble disconnectDevice:peripheral];
            }
        }
        if(isNew){
            ofLogNotice() << [peripheral identifier] << " is new" << endl;
            
            ledSynth *l = new ledSynth();
            l->setPeripheral(peripheral);
            l->canSend = false;
            ledSynths.push_back(l);
            [ble connectDevice:peripheral];
        }
    }
}

void ofApp::didUpdateDiscoveredRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " didUpdateDiscoveredRFduino " << endl;
}

void ofApp::didConnectRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " didConnectRFduino " << endl;
    
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            ofLogNotice() << "ready to receive" << endl;
            [(BLEPeripheralDelegate*)[l->peripheral delegate] setRFDuino:l];
            break;
        }
    }

    
}

void ofApp::disconnectRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " disconnectRFduino " << endl;
    
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            [ble disconnectDevice:peripheral];
            break;
        }
    }
    
    
}


void ofApp::didLoadServiceRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " didLoadServiceRFduino " << endl;
    
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            ofLogNotice() << "ready to send" << endl;
            l->canSend = true;
            break;
        }
    }

}

void ofApp::didDisconnectRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " didDisconnectRFduino " << endl;
    
    bool found = false;
    std::vector<ledSynth*>::iterator it = ledSynths.begin();
    for ( ; it != ledSynths.end(); ++it){
        if ([[(*it)->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            (*it)->canSend = false;
            found = true;
            break;
        }
    }
    if (found) {
            ledSynth * l = *it;
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
           //     l->parameters.clear();
            }

        ledSynths.erase(it);
        delete l;
    }

}

