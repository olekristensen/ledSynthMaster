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

    ble = [[BLEDelegate alloc] init];
    [ble initialize];
    [ble setApplication:this];
    
    gui.setup("ledSynth Master");
    //gui.add(parameters);

}

void ofApp::exit(){

    [ble cleanup];
//    [ble close];
}

//--------------------------------------------------------------
void ofApp::update(){
    /*int x = fmodf(ofGetElapsedTimef()*100.0, ofGetWidth()*1.0);
    int y = fmodf((ofGetElapsedTimef()+0.5)*100.0, ofGetHeight()*1.0);
    if(connected && ofGetFrameNum()%8 == 0){
        this->ofApp::mouseDragged(x, y, 0);
    }
     */
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofBackgroundGradient(ofColor::sandyBrown, ofColor::saddleBrown);
    ofPushMatrix();
    ofTranslate(20, 20);
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        l->draw();
        ofTranslate(120, 0);
    }
    ofPopMatrix();
    gui.draw();

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
    /*
    if(acknowledged){
        cout << x << ", " << y << endl;
    unsigned char msg[] = { 0x01, 'I', '0', '0', '0', '0', '0' , '0', 0x03,
                            0x01, 'T', '0', '0', '0', '0', '0' , '0', 0x03  };
    
    string iValue = ofToString(roundf(x*65535.0/ofGetWidth()));
    for (int i = iValue.length()-1; i >= 0; i--){
        msg[7-i] = iValue.data()[iValue.length()-(1+i)];
    }
    
    string tValue = ofToString(roundf(y*65535.0/ofGetHeight()));
    for (int i = tValue.length()-1; i >= 0; i--){
        msg[(9+7)-i] = tValue.data()[tValue.length()-(1+i)];
    }
    
    [ble send:msg len:9*2];
    }
     */
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    /*
    if(acknowledged){

    unsigned char msg[] = { 0x01, 'I', '0', '0', '0', '0', '0' , '0', 0x03,
        0x01, 'T', '0', '0', '0', '0', '0' , '0', 0x03  };
    
    string iValue = ofToString(roundf(x*65535.0/ofGetWidth()));
    for (int i = iValue.length()-1; i >= 0; i--){
        msg[7-i] = iValue.data()[iValue.length()-(1+i)];
    }
    
    string tValue = ofToString(roundf(y*65535.0/ofGetHeight()));
    for (int i = tValue.length()-1; i >= 0; i--){
        msg[(9+7)-i] = tValue.data()[tValue.length()-(1+i)];
    }
    
    [ble send:msg len:9*2];
    }
     */
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
        cout << " started scanning " << endl;
    }
    else
    {
        cout << " uh oh, this computer won't work :( :( :( :( " << endl;
        exit();
    }
}

void ofApp::didDiscoverRFduino(CBPeripheral *peripheral, NSDictionary *advertisementData)
{
    cout << " didDiscoverRFduino " << [[peripheral name] UTF8String];
    cout << " advertising " << [[advertisementData description] UTF8String] << endl;
    
    if( [[peripheral name] isEqualTo:@"LEDSYNTH"])
    {
        
        bool isNew = true;
        for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
            ledSynth * l = *it;
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
                isNew = false;
                cout << [peripheral identifier] << " allready connected" << endl;
            }
        }
        if(isNew){
            cout << [peripheral identifier] << " is NEW" << endl;
            
            ledSynth *l = new ledSynth();
            l->setPeripheral(peripheral);
            ledSynths.push_back(l);
            [ble connectDevice:peripheral];
        }
    }
}

void ofApp::didUpdateDiscoveredRFduino(CBPeripheral *peripheral)
{
    cout << " didUpdateDiscoveredRFduino " << endl;
}

void ofApp::didConnectRFduino(CBPeripheral *peripheral)
{
    cout << " didConnectRFduino " << endl;
}

void ofApp::didLoadServiceRFduino(CBPeripheral *peripheral)
{
    cout << " didLoadServiceRFduino " << endl;
    
    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            cout << "adding parameters" << endl;
            l->setPeripheral(peripheral);
            gui.add(l->parameters);
            break;
        }
    }

}

void ofApp::didDisconnectRFduino(CBPeripheral *peripheral)
{
    cout << " didDisconnectRFduino " << endl;
    
    bool found = false;
    std::vector<ledSynth*>::iterator it = ledSynths.begin();
    for ( ; it != ledSynths.end(); ++it){
        if ([[(*it)->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            found = true;
            break;
        }
    }
    if (found) {
            ledSynth * l = *it;
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
                ;
            }

        ledSynths.erase(it);
    }

}

