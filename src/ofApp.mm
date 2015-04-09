#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    connected = false;
    
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
