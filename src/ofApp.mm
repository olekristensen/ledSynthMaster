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
#include <dispatch/dispatch.h>

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetLogLevel(OF_LOG_NOTICE);
    ofSetCircleResolution(200);

    ble = [[BLEDelegate alloc] init];
    [ble initialize];
    [ble setApplication:this];
    
    ofEnableAntiAliasing();
    
    fontStatus.load("fonts/OpenSans-Light.ttf", 10, true, true, true);
    fontNode.load("fonts/OpenSans-Regular.ttf", 11, true, true, true);
    
    ImGuiIO& io = ImGui::GetIO();

    io.Fonts->Clear();
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Light.ttf", true).c_str(), 16);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Regular.ttf", true).c_str(), 16);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Light.ttf", true).c_str(), 32);
    io.Fonts->Build();
    gui.setup(new GuiTheme());
        
    // FAKE NODES
    /*
    for (int i = 1; i < 10; i++){
    ledSynth *l = new ledSynth();
        l->setPeripheral(NULL);
        l->canSend = false;
        l->ownID = i;
        l->remoteID = i;
        ledSynths.push_back(l);
    }
    */
    // Digital Weather
    
    imageWidth = imageHeight = 640;
    
    digitalWeatherImage.allocate(imageWidth, imageHeight, OF_IMAGE_COLOR);
    
    kelvinColdRange = kelvinCold = 6500;
    kelvinWarmRange = kelvinWarm = 1800;
    
    layout();
    
    temperatureTime = brightnessTime = timeOffset;
    offset.set(0,0);
    
    draggedLedSynth = nullptr;

    camera.setup(320, 240);
    camera.setUseTexture(true);
}

void ofApp::exit(){

    [ble cleanup];
}

//--------------------------------------------------------------
void ofApp::update(){
    
    camera.update();
    
    if(camera.isFrameNew()) {
        /*
        curFlow = &fb;
        fb.setPyramidScale(fbPyrScale);
        fb.setNumLevels(fbLevels);
        fb.setWindowSize(fbWinSize);
        fb.setNumIterations(fbIterations);
        fb.setPolyN(fbPolyN);
        fb.setPolySigma(fbPolySigma);
        fb.setUseGaussian(fbUseGaussian);
        
        // you can use Flow polymorphically
        curFlow->calcOpticalFlow(camera);
         */
    }

    
    if(ofGetFrameNum() == 3){
        cam.disableMouseInput();
    }
    
    if(windowDidResize){
        layout();
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
    
    gui.begin();

    // Guis
    ImGui::End();

    ImGuiWindowFlags window_flags = 0;
    window_flags |= ImGuiWindowFlags_NoTitleBar;
    window_flags |= ImGuiWindowFlags_NoResize;
    window_flags |= ImGuiWindowFlags_NoMove;
    window_flags |= ImGuiWindowFlags_NoCollapse;
    
    ImGui::SetNextWindowPos(ofVec2f(0,0));
    ImGui::SetNextWindowSize(ofVec2f(guiColumnWidth,ofGetHeight()));
    ImGui::Begin("Main###Debug", NULL, window_flags);
    //ImGui::ShowTestWindow();
    
    // Digital Weather
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[2]);
    ImGui::TextUnformatted("Digital Weather");
    ImGui::PopFont();

    ImGui::Text("FPS %.3f", ofGetFrameRate());
    ImGui::SliderFloat("Offset X", &offset.x, -1, 1);
    ImGui::SliderFloat("Offset Y", &offset.y, -1, 1);

    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Temperature");
    ImGui::PopFont();

    ImGui::DragFloatRange2("Range##Temperature", &kelvinWarmRange, &kelvinColdRange, 1.0, kelvinWarm*1.0, kelvinCold*1.0, "%.0f");
    ImGui::SliderFloat("Speed##Temperature", &temperatureSpeed, 0.0, 1.0);
    ImGui::SliderFloat("Spread##Temperature", &temperatureSpread, 0.0, 1.0);

    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Brightness");
    ImGui::PopFont();

    ImGui::DragFloatRange2("Range##Brightness", &brightnessRangeFrom, &brightnessRangeTo, 0.001, 0.0, 1.0, "%.3f");
    ImGui::SliderFloat("Speed##Brightness", &brightnessSpeed, 0.0, 1.0);
    ImGui::SliderFloat("Spread##Brightness", &brightnessSpread, 0.0, 1.0);
    
    
    //FIXME: Camera texture does not draw
    
    cameraTextureSourceID = camera.getTexture().getTextureData().textureID;
    ImGui::Image((void*)&cameraTextureSourceID, ofVec2f(camera.getWidth(), camera.getHeight()));
    
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Options");
    ImGui::PopFont();
    
    ImGui::Checkbox("Show Node Guis", &showNodeGuis);
    
    temperatureSpreadCubic = powf(temperatureSpread, 3);
    brightnessSpreadCubic = powf(brightnessSpread, 3);
    
    int imageWidth = digitalWeatherImage.getWidth();
    int imageHeight = digitalWeatherImage.getHeight();
    
    ofPixels &pix = digitalWeatherImage.getPixels();
    
    dispatch_apply( imageHeight, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^(size_t y){
        
        double yMapped = ofMap(y+(imageHeight*offset.y), imageHeight, 0, -10.0, 10.0);
        
        //double yMapped = fmodf(y+(imageHeight*offset.y), imageHeight);

        auto line = pix.getLine(y);
        
        for (int x = 0; x < imageWidth ; x++) {
            
            double xMapped = ofMap(x+(imageWidth*offset.x), imageWidth, 0, -10.0, 10.0);

            /*
             // 4D shape that wraps to make tiling
             float s=xMapped*1.0/imageWidth;
             float t=yMapped*1.0/imageHeight;
             
             float multiplier = 10 / TWO_PI;
             float nx = cos( s * TWO_PI ) * multiplier;
             float ny = cos( t * TWO_PI ) * multiplier;
             float nz = sin( s * TWO_PI ) * multiplier;
             float nw = sin( t * TWO_PI ) * multiplier;
             
             float size = 10.0;
             float brightnessSize = size * brightnessSpreadCubic;
             
             float brightness = ofNoise((nx*brightnessSize)+brightnessTime,
             (ny*brightnessSize)+brightnessTime,
             (nz*brightnessSize)+brightnessTime,
             (nw*brightnessSize)+brightnessTime);
             brightness = ofMap(brightness, 0.0, 1.0, brightnessRangeFrom, brightnessRangeTo);
             
             float temperatureSize = size * temperatureSpreadCubic;
             
             float tempNoise = ofNoise(
             (nx*temperatureSize)+temperatureTime,
             (ny*temperatureSize)+temperatureTime,
             (nz*temperatureSize)+temperatureTime,
             (nw*temperatureSize)+temperatureTime);
             unsigned int temp = round(ofMap(tempNoise, 0, 1, kelvinWarmRange, kelvinColdRange));
             */
            
            pix.setColor(x, y, getColor(xMapped, yMapped));

        }

    });
    
    temperatureTime += powf(temperatureSpeed,8) * ofGetLastFrameTime();
    brightnessTime += powf(brightnessSpeed,8) * ofGetLastFrameTime();

//    digitalWeatherImage.setFromPixels(pix);
    digitalWeatherImage.update();

    ofSetColor(255,255);
    
    // Nodes

    digitalWeatherImage.draw(weatherRect);

    for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
        ledSynth * l = *it;
        ofPushMatrix();
        
        ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
        
        ofTranslate(position.x, position.y);
        l->intensityNoise = 1000*getIntensity(l->position.get());
        l->temperatureNoise = getTemperature(l->position.get());
        
        l->draw();
        ofSetColor((l->intensityOutput > l->intensityOutput.getMax()/2)?0:255, 200);
        fontNode.drawStringAsShapes(ofToString(l->ownID), -fontNode.stringWidth(ofToString(l->ownID))*0.55, fontNode.stringHeight(ofToString(l->ownID))*0.55);
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
    
    if(showNodeGuis) {
        for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
            ledSynth * l = *it;
            l->drawGui();
        }
    }
    gui.end();
    
    // Status bar
    
    string status = ([ble isLECapableHardware]?"Bluetooth LE supported":"No Bluetooth LE support");
    status += "\n" + ofToString(ledSynth::nextIndex) + " devices connected";
    
    float statusbarMargin = 20;
//    statusbarHeight = fontStatus.stringHeight(status) + (statusbarMargin * 2.0);
    ofSetColor(255, 200);
    ofDrawRectangle(guiColumnWidth, ofGetHeight()-statusbarHeight, ofGetWidth(), statusbarHeight);
    ofSetColor(0, 127);
    ofPushMatrix();
    ofTranslate(statusbarMargin+guiColumnWidth, (ofGetHeight()-statusbarHeight)+32);
    fontStatus.drawString(status, 0, 0);
    ofPopMatrix();

}

void ofApp::layout(){
    int windowHeight = (ofGetWindowWidth()-guiColumnWidth)+statusbarHeight;
    ofSetWindowShape(ofGetWindowWidth(), windowHeight);
    ofLogNotice(__FUNCTION__) << ofGetWindowRect() << endl;
    windowDidResize = false;
    weatherRect.set(guiColumnWidth, 0, ofGetWindowWidth()-guiColumnWidth, ofGetWindowHeight()-statusbarHeight);
}


ofVec2f ofApp::getMappedCoordsFromImage(ofVec2f v){
    ofVec2f iVec;
    iVec.x = ofMap(v.x+(imageWidth*offset.x), imageWidth, 0, -10.0, 10.0);
    iVec.y = ofMap(v.y+(imageHeight*offset.y), imageHeight, 0, -10.0, 10.0);
    return iVec;
}

ofVec2f ofApp::getMappedCoordsFromNormalised(ofVec2f v){
    ofVec2f iVec;
    iVec.x = ofMap(v.x+(offset.x), 1.0, -1.0, -10.0, 10.0);
    iVec.y = ofMap(v.y+(offset.y), 1.0, -1.0, -10.0, 10.0);
    return iVec;
}

unsigned int ofApp::getTemperature(ofVec2f v){
    ofVec2f vScaled = getMappedCoordsFromNormalised(v);
    return getTemperature(vScaled.x, vScaled.y);
}

float ofApp::getIntensity(ofVec2f v){
    ofVec2f vScaled = getMappedCoordsFromNormalised(v);
    return getIntensity(vScaled.x, vScaled.y);
}

ofFloatColor ofApp::getColor(ofVec2f v){
    ofVec2f vScaled = getMappedCoordsFromNormalised(v);
    return getColor(vScaled.x,vScaled.y);
}

unsigned int ofApp::getTemperature(float x, float y){
    float tempNoise = ofNoise(x*temperatureSpreadCubic, y*temperatureSpreadCubic, temperatureTime);
    return round(ofMap(tempNoise, 0, 1, kelvinWarmRange, kelvinColdRange));
}

float ofApp::getIntensity(float x, float y){
    float brightness = ofNoise(x*brightnessSpreadCubic, y*brightnessSpreadCubic, brightnessTime);
    return ofMap(brightness, 0, 1, brightnessRangeFrom, brightnessRangeTo);
}

ofFloatColor ofApp::getColor(float x, float y){
    float brightness = getIntensity(x, y);
    int temp = getTemperature(x, y);
    ofFloatColor c = ledSynth::temperatureToColor(temp);
    c *= brightness;
    return c;
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
    if(draggedLedSynth != nullptr){
        
        ofVec2f mouseVec(x, y);
        
        ofVec2f position = (mouseVec - weatherRect.getCenter()) / (weatherRect.getWidth()*0.5);

        draggedLedSynth->position = position;
    
    }
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

    if(draggedLedSynth == nullptr){
            for (std::vector<ledSynth*>::iterator it = ledSynths.begin() ; it != ledSynths.end(); ++it){
            ledSynth * l = *it;
        
            ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();

            if(position.distance(ofVec2f(x,y)) < 10.0){
                draggedLedSynth = l;
            }
        
        }
    }
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

    if(draggedLedSynth != nullptr){
        draggedLedSynth = nullptr;
    }
    
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){
    windowDidResize = true;
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
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
}

void ofApp::didConnectRFduino(CBPeripheral *peripheral)
{
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
    
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
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
    
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
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
    
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
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
    
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

