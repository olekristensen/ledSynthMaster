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
    /**
    for (int i = 1; i < 10; i++){
    ledSynth *l = new ledSynth();
        l->setPeripheral(NULL);
        l->canSend = false;
        l->ownID = i;
        l->remoteID = i;
        ledSynths.push_back(l);
    }
    //*/
    
    // Digital Weather
    
    imageWidth = imageHeight = 640;
    
    digitalWeatherImage.allocate(imageWidth, imageHeight, OF_IMAGE_COLOR);
    
    kelvinColdRange = kelvinCold = 6500;
    kelvinWarmRange = kelvinWarm = 1800;
    
    layout();
    
    temperatureTime = brightnessTime = timeOffset;
    offset.set(0,0);
    
    draggedLedSynth = nullptr;
    guiLedSynth = nullptr;
    tooltipLedSynth = nullptr;

    int deviceId = 0;
    
    for(auto dev : camera.listDevices()){
        ofLogNotice(__FUNCTION__) << dev.deviceName << ": " << dev.id << endl;
        for (auto f : dev.formats){
            ofLogVerbose(__FUNCTION__) << f.width << " x " << f.height << endl;
            for (auto framerate : f.framerates){
                ofLogVerbose(__FUNCTION__) << "\t - " << framerate;
            }
        }
        if(dev.deviceName.find("FaceTime") == string::npos){
            deviceId = dev.id;
        }
    }
    camera.setDeviceID(deviceId);
    camera.setup(320, 320*9/16);
    cameraImage.allocate(camera.getWidth(), camera.getHeight(), OF_IMAGE_COLOR);
    mirrorCamera = false;
    
    kalman.init(1/5000., 1/10.); // inverse of (smoothness, rapidness)
    
    fbPyrScale = .25;
    fbLevels = 2;
    fbIterations = 2;
    fbPolyN = 7;
    fbPolySigma = 1.5;
    fbWinSize = 32;
    fbUseGaussian = false;
    offsetScale = 0.1;
    
    globalNoiseLevel = 0.5;

}

void ofApp::exit(){

    [ble cleanup];
}

//--------------------------------------------------------------
void ofApp::update(){
    
    camera.update();
    
    if(camera.isFrameNew()) {
        fb.setPyramidScale(fbPyrScale);
        fb.setNumLevels(fbLevels);
        fb.setWindowSize(fbWinSize);
        fb.setNumIterations(fbIterations);
        fb.setPolyN(fbPolyN);
        fb.setPolySigma(fbPolySigma);
        fb.setUseGaussian(fbUseGaussian);
        
        cameraImage.setFromPixels(camera.getPixels());
        if(mirrorCamera)
            cameraImage.mirror(false, true);
        fb.calcOpticalFlow(cameraImage);
        averageMovement = fb.getAverageFlow();
    }

    kalman.update(averageMovement);
    averageMovementFiltered = kalman.getEstimation();

    
    if(ofGetFrameNum() == 3){
        cam.disableMouseInput();
    }
    
    if(windowDidResize){
        layout();
    }
    int index = 0;

    for (auto l : ledSynths){
        
        // update values
        
        if(l->connected){
        if (l->ownID > 0 && l->mixRemote >= 0 && l->remoteID >= 0) {
            
      
            if(l->ownID != l->remoteID) {
                if(l->remoteID == 0){
                 // using light sensor
                    
                    ;
                    
                } else {
                    
                    ledSynth * remote = NULL;
                    
                    for (auto r :ledSynths){
                        if (r->ownID == l->remoteID) {
                            remote = r;
                            break;
                        }
                    }
                    
                    if(remote != NULL){
                        l->intensityRemote = ofLerp(remote->intensityOutput, l->intensityNoise, globalNoiseLevel);
                        l->temperatureRemote = cvRound(ofLerp(remote->temperatureOutput, l->temperatureNoise, globalNoiseLevel));
                    } else {
                        l->intensityRemote = ofLerp(l->intensityFader, l->intensityNoise, globalNoiseLevel);
                        l->temperatureRemote = cvRound(ofLerp(l->temperatureFader, l->temperatureNoise, globalNoiseLevel));
                    }
                }
            }
        
        }
        }
        l->update();
        // rearrange
        
        
        index++;
    }
    
    offset+=averageMovementFiltered*ofGetLastFrameTime()*offsetScale;
    
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofBackgroundGradient(ofColor::lightGrey, ofColor::whiteSmoke);
    
    gui.begin();

    // Guis
    //ImGui::End();
    //ImGui::ShowTestWindow();
    
    ImGuiWindowFlags window_flags = 0;
    window_flags |= ImGuiWindowFlags_NoTitleBar;
    window_flags |= ImGuiWindowFlags_NoResize;
    window_flags |= ImGuiWindowFlags_NoMove;
    window_flags |= ImGuiWindowFlags_NoCollapse;
    
    ImGui::SetNextWindowPos(ofVec2f(0,0));
    ImGui::SetNextWindowSize(ofVec2f(guiColumnWidth,ofGetHeight()));
    ImGui::Begin("Main###Debug", NULL, window_flags);
    
    // Digital Weather
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[2]);
    ImGui::TextUnformatted("Digital Weather");
    ImGui::PopFont();

    ImGui::Text("FPS %.3f", ofGetFrameRate());

    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Weather Level");
    ImGui::PopFont();
    
    ImGui::SliderFloat("Level##Weater", &globalNoiseLevel, 0.0, 1.0);
    ImGui::SliderInt("Update interval millis", &hardwareUpdateIntervalMillis, 0, 1000);
    for (auto l : ledSynths){
        l->hardwareUpdateIntervalMillis = hardwareUpdateIntervalMillis;
    }
    
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
    
    temperatureSpreadCubic = powf(temperatureSpread, 3);
    brightnessSpreadCubic = powf(brightnessSpread, 3);
    
    int imageWidth = digitalWeatherImage.getWidth();
    int imageHeight = digitalWeatherImage.getHeight();
    
    ofPixels &pix = digitalWeatherImage.getPixels();
    
    dispatch_apply( imageHeight, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t y){
        
        double yMapped = ofMap(y-(imageHeight*offset.y), 0, imageHeight, -10.0, 10.0);
        
        auto line = pix.getLine(y);
        
        for (int x = 0; x < imageWidth ; x++) {
            
            double xMapped = ofMap(x-(imageWidth*offset.x), 0, imageWidth, -10.0, 10.0);

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

    digitalWeatherImage.update();

    ofSetColor(255,255);
    
    // Nodes

    digitalWeatherImage.draw(weatherRect);

    for (auto l :ledSynths){

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
    for (auto l :ledSynths){

        if(l->remoteID != l->ownID){
            
            ledSynth * remote = NULL;
            
            for (auto r :ledSynths){
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
    
    // Node Tooltips
    
    if(tooltipLedSynth != nullptr){
        
        ImGui::BeginTooltip();
        float percent;

        ImGui::Text("ID: %i\nVersion: %i.%i", tooltipLedSynth->ownID.get(), tooltipLedSynth->versionMajor.get(), tooltipLedSynth->versionMinor.get());
        if(tooltipLedSynth->ownID.get() == tooltipLedSynth->remoteID.get()){
            ImGui::TextUnformatted("Movement sensor selected");
        } else if (tooltipLedSynth->remoteID.get() == 0){
            ImGui::TextUnformatted("Light sensor selected");
        } else {
            ImGui::Text("Remote %i selected", tooltipLedSynth->remoteID.get());
        }
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Faders");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityFader.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k", percent, tooltipLedSynth->temperatureFader.get());
        
            ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
            ImGui::TextUnformatted("Remote");
            ImGui::PopFont();
            percent = tooltipLedSynth->intensityRemote.get() * 0.1;
            ImGui::Text("Channel: %i\nIntensity: %.1f %%\nTemperature: %i k\nMix: %.1f %%", tooltipLedSynth->remoteID.get(), percent, tooltipLedSynth->temperatureRemote.get(), ofMap(tooltipLedSynth->mixRemote.get(), tooltipLedSynth->mixRemote.getMin(), tooltipLedSynth->mixRemote.getMax(), 0.0, 100.0));

        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Weather");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityNoise.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k\nMix: %.1f %%", percent, tooltipLedSynth->temperatureNoise.get(), ofMap(tooltipLedSynth->mixNoise.get(), tooltipLedSynth->mixNoise.getMin(), tooltipLedSynth->mixNoise.getMax(), 0.0, 100.0));
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Output");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityOutput.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k", percent, tooltipLedSynth->temperatureOutput.get());
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Movement Sensor");
        ImGui::PopFont();
        ImGui::Text("Sensor: %s\nLevel: %.1f %%", tooltipLedSynth->movementSensor.get()>0?"activity":"still", ofMap(tooltipLedSynth->movementSensorLevel.get(), 0, 1000, 0.0, 100.0));
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Light Sensor");
        ImGui::PopFont();
        ImGui::Text("Intensity: %i lux\nTemperature: %i k\nLevel: %i", tooltipLedSynth->lightSensorLux.get(), tooltipLedSynth->lightSensorTemperature.get(), tooltipLedSynth->lightSensorLightLevel.get());
        
        ImGui::EndTooltip();
    }
    

    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Movement");
    ImGui::PopFont();
    ImGui::Checkbox("Mirrored", &mirrorCamera);
    ImGui::SliderFloat("Scale", &offsetScale, 0.0, 1.0);
    ImGui::InputFloat2("Offset", offset.getPtr());
    
    /*
    ImGui::End();
    
    ImGui::SetNextWindowPos(ofVec2f(400,0), ImGuiSetCond_FirstUseEver);
    ImGui::SetNextWindowSize(ofVec2f(guiColumnWidth,ofGetHeight()), ImGuiSetCond_FirstUseEver);
    ImGui::Begin("OpenCv");

    ImGui::SliderFloat("Pyramid Scale", &fbPyrScale, 0, .99);
    ImGui::SliderInt("Levels", &fbLevels, 1, 8);
    ImGui::SliderInt("Iterations", &fbIterations, 1, 8);
    ImGui::SliderInt("Poly N", &fbPolyN, 5, 10);
    ImGui::SliderFloat("Poly Sigma", &fbPolySigma, 1.1, 2.0);
    ImGui::Checkbox("Use Gaussian", &fbUseGaussian);
    ImGui::SliderInt("Window Size", &fbWinSize, 4, 64);
*/
    gui.end();
    
    // Camera
    
    ofSetColor(255,255);
    float camHeight = guiColumnWidth * camera.getHeight() / camera.getWidth();
    cameraImage.draw(15, ofGetHeight()-(camHeight-15), guiColumnWidth-30, camHeight-30);
    //fb.draw(15,ofGetHeight()-(camHeight-15), guiColumnWidth-30, camHeight-30);
    ofVec2f center = ofVec2f(guiColumnWidth/2.0, ofGetHeight()-(camHeight/2.0));
    ofDrawEllipse(center.x, center.y, 10, 10);
    ofPushMatrix();
    ofScale(1.0, 1.0, 0.0);
        if((averageMovementFiltered*guiColumnWidth*0.2).length() > 5)
        ofDrawArrow(center, center+(averageMovementFiltered*guiColumnWidth*0.2), 5);
    ofPopMatrix();
    
    // Status bar
    
    string status = ([ble isLECapableHardware]?"Bluetooth LE supported":"No Bluetooth LE support");
    status += "\n" + ofToString(ledSynths.size()) + " devices connected";
    
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
    iVec.x = ofMap(v.x-(imageWidth*offset.x), 0, imageWidth, -10.0, 10.0);
    iVec.y = ofMap(v.y-(imageHeight*offset.y), 0, imageHeight, -10.0, 10.0);
    return iVec;
}

ofVec2f ofApp::getMappedCoordsFromNormalised(ofVec2f v){
    ofVec2f iVec;
    iVec.x = ofMap(v.x-(offset.x*2.0), -1.0, 1.0, -10.0, 10.0);
    iVec.y = ofMap(v.y-(offset.y*2.0), -1.0, 1.0, -10.0, 10.0);
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
    for (auto l :ledSynths){
        
        ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
        
        if(position.distance(ofVec2f(x,y)) < 10.0){
            tooltipLedSynth = l;
            return;
        }
        
    }
    tooltipLedSynth = nullptr;
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    if(draggedLedSynth != nullptr){
        
        ofVec2f mouseVec(x, y);
        mouseVec += mouseDragOffset;
        
        ofVec2f position = (mouseVec - weatherRect.getCenter()) / (weatherRect.getWidth()*0.5);

        draggedLedSynth->position = position;
    
    }
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

    if(draggedLedSynth == nullptr){
        for (auto l :ledSynths){
        
            ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();

            if(position.distance(ofVec2f(x,y)) < 10.0){
                draggedLedSynth = l;
                mouseDragOffset = position - ofVec2f(x,y);
            }
        
        }
    }
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

    if(draggedLedSynth != nullptr){
        draggedLedSynth = nullptr;
    }
    
    for (auto l :ledSynths){
        
        ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
        
        if(position.distance(ofVec2f(x,y)) < 10.0){
            guiLedSynth = l;
            return;
        }
        
    }
    guiLedSynth = nullptr;

    
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
        for (auto l :ledSynths){
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
                isNew = false;
                ofLogNotice() << [peripheral identifier] << " allready connected" << endl;
                //[ble disconnectDevice:peripheral];
            }
        }
        if(isNew){
            ofLogNotice() << [peripheral identifier] << " is new" << endl;
            //[peripheral retain];
            ledSynth *l = new ledSynth();
            l->setPeripheral(peripheral);
            l->canSend = false;
            ledSynths.push_back(l);
            [ble connectDevice:peripheral];
        }
    }
}

void ofApp::didDiscoverRFduino(CBPeripheral *peripheral)
{
    ofLogNotice() << " didDiscoverRFduino " << [[peripheral name] UTF8String];
    
    if( [[peripheral name] isEqualTo:@"LEDSYNTH"] || [[peripheral name] isEqualTo:@"light node"])
    {
        
        bool isNew = true;
        for (auto l :ledSynths){
            if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
                isNew = false;
                ofLogNotice() << [peripheral identifier] << " allready connected" << endl;
                //[ble disconnectDevice:peripheral];
            }
        }
        if(isNew){
            ofLogNotice() << [peripheral identifier] << " is new" << endl;
            //[peripheral retain];
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
    
    for (auto l :ledSynths){
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
    
    for (auto l :ledSynths){
        if ([[l->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            [ble disconnectDevice:peripheral];
            break;
        }
    }
    
    
}


void ofApp::didLoadServiceRFduino(CBPeripheral *peripheral)
{
    ofLogNotice(__FUNCTION__) << [peripheral identifier] << endl;
    
    for (auto l :ledSynths){
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
    
    ledSynth * l;
    bool found = false;
    std::vector<ledSynth*>::iterator it = ledSynths.begin();
    for ( ; it != ledSynths.end(); ++it){
        if ([[(*it)->peripheral identifier] isEqualTo:[peripheral identifier]]) {
            l = (*it);
            l->canSend = false;
            found = true;
            break;
        }
    }
    if (found) {
        //[peripheral release];
        //l->removeListeners();
        
        ledSynths.erase(it);
        delete l;
        [ble stopScan];
        [ble startScan];
    }
}

void ofApp::ImGuiSliderFromParam(ofAbstractParameter &p){
    ofParameter<int> pInt;
    if(p.type() == pInt.type()){
        pInt = p.cast<ofParameter<int>>();
        int value = pInt;
        if(ImGui::SliderInt(pInt.getName().c_str(), &value, pInt.getMin(), pInt.getMax())){
            pInt.set(value);
        }
    }
}

