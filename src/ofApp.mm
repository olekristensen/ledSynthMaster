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

    connected = false;
    acknowledged = false;
    
    ble = [[BLEDelegate alloc] init];
    [ble initialize];
    [ble setApplication:this];
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
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
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
    }
    else
    {
        cout << " uh oh, this computer won't work :( :( :( :( " << endl;
        exit();
    }
}

void ofApp::didDiscoverRFduino(CBPeripheral *rfduino, NSDictionary *advertisementData)
{
    cout << " didDiscoverRFduino " << [[rfduino name] UTF8String];
    cout << " advertising " << [[advertisementData description] UTF8String] << endl;
    
    if( [[rfduino name] isEqualTo:@"LEDSYNTH"])
    {
         [ble connectDevice:rfduino];
//        ble->connectDevice(rfduino);
    }
}

void ofApp::didUpdateDiscoveredRFduino(CBPeripheral *rfduino)
{
    cout << " didUpdateDiscoveredRFduino " << endl;
}

void ofApp::didConnectRFduino(CBPeripheral *rfduino)
{
    cout << " didConnectRFduino " << endl;
    connected = true;
    acknowledged = true;
}

void ofApp::didLoadServiceRFduino(CBPeripheral *rfduino)
{
    cout << " didLoadServiceRFduino " << endl;
}

void ofApp::didDisconnectRFduino(CBPeripheral *rfduino)
{
    cout << " didDisconnectRFduino " << endl;
}

void ofApp::receivedData( unsigned char *data)
{
    cout << data    << endl;
    acknowledged = true;
        
}
