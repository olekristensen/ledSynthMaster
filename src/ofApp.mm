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

//#define USE_DUMMY_NODES 1

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
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Regular.ttf", true).c_str(), 11);
    io.Fonts->AddFontFromFileTTF(ofToDataPath("fonts/OpenSans-Bold.ttf", true).c_str(), 11);
    io.Fonts->Build();
    
    gui.setup(new GuiTheme());
    
    ImGuiStyle * style = &ImGui::GetStyle();
    
    style->WindowPadding            = ImVec2(15, 15);
    style->WindowRounding           = 5.0f;
    style->FramePadding             = ImVec2(5, 5);
    style->FrameRounding            = 4.0f;
    style->ItemSpacing              = ImVec2(12, 8);
    style->ItemInnerSpacing         = ImVec2(8, 6);
    style->IndentSpacing            = 25.0f;
    style->ScrollbarSize            = 15.0f;
    style->ScrollbarRounding        = 9.0f;
    style->GrabMinSize              = 5.0f;
    style->GrabRounding             = 3.0f;
    
    style->Colors[ImGuiCol_Text]                  = ImVec4(0.40f, 0.39f, 0.38f, 1.00f);
    style->Colors[ImGuiCol_TextDisabled]          = ImVec4(0.40f, 0.39f, 0.38f, 0.77f);
    style->Colors[ImGuiCol_WindowBg]              = ImVec4(0.92f, 0.91f, 0.88f, 0.70f);
    style->Colors[ImGuiCol_ChildWindowBg]         = ImVec4(1.00f, 0.98f, 0.95f, 0.58f);
    style->Colors[ImGuiCol_PopupBg]               = ImVec4(0.92f, 0.91f, 0.88f, 0.92f);
    style->Colors[ImGuiCol_Border]                = ImVec4(0.84f, 0.83f, 0.80f, 0.65f);
    style->Colors[ImGuiCol_BorderShadow]          = ImVec4(0.92f, 0.91f, 0.88f, 0.00f);
    style->Colors[ImGuiCol_FrameBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
    style->Colors[ImGuiCol_FrameBgHovered]        = ImVec4(0.99f, 1.00f, 0.40f, 0.78f);
    style->Colors[ImGuiCol_FrameBgActive]         = ImVec4(0.26f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_TitleBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
    style->Colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(1.00f, 0.98f, 0.95f, 0.75f);
    style->Colors[ImGuiCol_TitleBgActive]         = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_MenuBarBg]             = ImVec4(1.00f, 0.98f, 0.95f, 0.47f);
    style->Colors[ImGuiCol_ScrollbarBg]           = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
    style->Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.00f, 0.00f, 0.00f, 0.21f);
    style->Colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(0.90f, 0.91f, 0.00f, 0.78f);
    style->Colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_ComboBg]               = ImVec4(1.00f, 0.98f, 0.95f, 1.00f);
    style->Colors[ImGuiCol_CheckMark]             = ImVec4(0.25f, 1.00f, 0.00f, 0.80f);
    style->Colors[ImGuiCol_SliderGrab]            = ImVec4(0.00f, 0.00f, 0.00f, 0.14f);
    style->Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_Button]                = ImVec4(0.00f, 0.00f, 0.00f, 0.14f);
    style->Colors[ImGuiCol_ButtonHovered]         = ImVec4(0.99f, 1.00f, 0.22f, 0.86f);
    style->Colors[ImGuiCol_ButtonActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_Header]                = ImVec4(0.25f, 1.00f, 0.00f, 0.76f);
    style->Colors[ImGuiCol_HeaderHovered]         = ImVec4(0.25f, 1.00f, 0.00f, 0.86f);
    style->Colors[ImGuiCol_HeaderActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_Column]                = ImVec4(0.00f, 0.00f, 0.00f, 0.32f);
    style->Colors[ImGuiCol_ColumnHovered]         = ImVec4(0.25f, 1.00f, 0.00f, 0.78f);
    style->Colors[ImGuiCol_ColumnActive]          = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.00f, 0.00f, 0.00f, 0.04f);
    style->Colors[ImGuiCol_ResizeGripHovered]     = ImVec4(0.25f, 1.00f, 0.00f, 0.78f);
    style->Colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_CloseButton]           = ImVec4(0.40f, 0.39f, 0.38f, 0.16f);
    style->Colors[ImGuiCol_CloseButtonHovered]    = ImVec4(0.40f, 0.39f, 0.38f, 0.39f);
    style->Colors[ImGuiCol_CloseButtonActive]     = ImVec4(0.40f, 0.39f, 0.38f, 1.00f);
    style->Colors[ImGuiCol_PlotLines]             = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
    style->Colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_PlotHistogram]         = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
    style->Colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
    style->Colors[ImGuiCol_TextSelectedBg]        = ImVec4(0.25f, 1.00f, 0.00f, 0.43f);
    style->Colors[ImGuiCol_ModalWindowDarkening]  = ImVec4(1.00f, 0.98f, 0.95f, 0.73f);
    
    // DUMMY NODES
#ifdef USE_DUMMY_NODES
    
    for (int i = 1; i < USE_DUMMY_NODES; i++){
        ledSynth *l = new ledSynth();
        l->setPeripheral(NULL);
        l->canSend = false;
        l->ownID = -1;
        l->remoteID = i-1;
        ledSynths.push_back(l);
    }
#endif
    
    // Digital Weather
    
    imageWidth = imageHeight = 640;
    
    digitalWeatherImage.allocate(imageWidth, imageHeight, OF_IMAGE_COLOR);
    
    layout();
    
    temperatureTime = intensityTime = timeOffset;
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
    //camera.setup(320, 320*9/16);
    camera.setup(320, 320*3/4);
    cameraImage.allocate(camera.getWidth(), camera.getHeight(), OF_IMAGE_COLOR);
    
    kalman.init(1/5000., 1/10.); // inverse of (smoothness, rapidness)
    
    fbPyrScale = .25;
    fbLevels = 2;
    fbIterations = 2;
    fbPolyN = 7;
    fbPolySigma = 1.5;
    fbWinSize = 32;
    fbUseGaussian = false;
    
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
        
#ifdef USE_DUMMY_NODES
        
        if(!l->connected && l->ownID == -1 && ofRandom(1.0) > 0.99)
            l->connected = true;
        
        if(l->connected && l->ownID == -1 && ofRandom(1.0) > 0.99){
            l->ownID = l->remoteID + 1;
        }
        
        if(l->connected && l->ownID != -1 && ofRandom(1.0) > 0.99){
            l->initDone = true;
        }
        
#endif
        
        if(l->initDone && l->connected){
#ifdef USE_DUMMY_NODES
            
            l->intensityFader.set(floor(ofNoise(ofGetElapsedTimef()+l->ownID)*1000));
            l->temperatureFader.set(floor(ofMap(ofNoise(23+ofGetElapsedTimef()+l->ownID), 0.0, 1.0, l->temperatureFader.getMin(), l->temperatureFader.getMax()) ));
            
#endif
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
    if(showGuiDemo) ImGui::ShowTestWindow();
    
    ImGuiWindowFlags window_flags = 0;
    window_flags |= ImGuiWindowFlags_NoTitleBar;
    window_flags |= ImGuiWindowFlags_NoResize;
    window_flags |= ImGuiWindowFlags_NoMove;
    window_flags |= ImGuiWindowFlags_NoCollapse;
    window_flags |= ImGuiWindowFlags_ShowBorders;
    
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
    ImGuiSliderFromParam(globalNoiseLevel);
    ImGuiSliderFromParam(hardwareUpdateIntervalFps);
    for (auto l : ledSynths){
        l->hardwareUpdateIntervalMillis = 1000/hardwareUpdateIntervalFps;
    }
    
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Temperature");
    ImGui::PopFont();
    
    ImGuiRangeFromParams(kelvinWarmRange, kelvinColdRange);
    ImGuiSliderFromParam(temperatureSpeed);
    ImGuiSliderFromParam(temperatureSpread);
    
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Intensity");
    ImGui::PopFont();
    
    ImGuiRangeFromParams(intensityRangeFrom, intensityRangeTo);
    
    ImGuiSliderFromParam(intensitySpeed);
    ImGuiSliderFromParam(intensitySpread);
    
    temperatureSpreadCubic = powf(temperatureSpread, 3);
    intensitySpreadCubic = powf(intensitySpread, 3);
    
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
             float intensitySize = size * intensitySpreadCubic;
             
             float intensity = ofNoise((nx*intensitySize)+intensityTime,
             (ny*intensitySize)+intensityTime,
             (nz*intensitySize)+intensityTime,
             (nw*intensitySize)+intensityTime);
             intensity = ofMap(intensity, 0.0, 1.0, intensityRangeFrom, intensityRangeTo);
             
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
    intensityTime += powf(intensitySpeed,8) * ofGetLastFrameTime();
    
    digitalWeatherImage.update();
    
    ofSetColor(255,255);
    
    // Nodes
    
    digitalWeatherImage.draw(weatherRect);
    
    // Connections
    
    ofSetColor(255,63);
    for (auto l :ledSynths){
        
        if(l->initDone){
            
            if(l->remoteID != l->ownID){
                
                ledSynth * remote = NULL;
                
                for (auto r :ledSynths){
                    if (r->ownID == l->remoteID) {
                        remote = r;
                        break;
                    }
                }
                
                if(remote != NULL && remote->initDone){
                    
                    ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
                    ofVec2f remotePosition = (remote->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
                    
                    ofVec2f positionToRemote = remotePosition - position;
                    ofVec2f remoteToPosition = position - remotePosition;
                    
                    positionToRemote.scale(33);
                    remoteToPosition.scale(37);
                    
                    ofDrawArrow(remotePosition-positionToRemote, position-remoteToPosition, 4);
                }
            }
        }
    }
    
    int numberOfConnectingLedSynths = 0;
    
    for (auto l :ledSynths){
        
        ofPushMatrix();
        
        if(l->initDone){
            ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
            
            ofTranslate(position.x, position.y);
            l->intensityNoise = 1000*getIntensity(l->position.get());
            l->temperatureNoise = getTemperature(l->position.get());
        } else {
            ofTranslate((weatherRect.getRight()-(statusbarHeight/2.0))-numberOfConnectingLedSynths*statusbarHeight/1.5, weatherRect.getBottom()+(statusbarHeight/2.0));
            numberOfConnectingLedSynths++;
        }
        
        l->draw(l==guiLedSynth);
        
        if(l->ownID > 0){
            ofSetColor((l->intensityOutput > l->intensityOutput.getMax()/2)?0:255, 200);
            fontNode.drawStringAsShapes(ofToString(l->ownID), -fontNode.stringWidth(ofToString(l->ownID))*0.5, fontNode.stringHeight(ofToString(l->ownID))*0.5);
        }
        ofPopMatrix();
        
    }
    
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Presets");
    ImGui::PopFont();
    
    ImGui::PushItemWidth(195);
    
    bool updatePresetItem = false;
    
    ImGui::InputText("##PresetSaveFileName", strSaveFileName, 128, ImGuiInputTextFlags_CallbackCharFilter,
                     [] (ImGuiTextEditCallbackData* data) { if (strchr("\\/%&.:<>|", (char)data->EventChar)) return 1; return 0; }
                     );
    ImGui::PopItemWidth();
    ImGui::SameLine();
    if(strlen(strSaveFileName) > 0){
        if(ImGui::Button("Save", ofVec2f(50,25))){
            saveParameterGroup(rootParameters, strSaveFileName);
            updatePresetItem = true;
        }
    } else {
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, 0.5 );
        ImGui::Button("Save", ofVec2f(50,25));
        ImGui::PopStyleVar();
    }
    
    vector<string> presetItems;
    
    ofDirectory presetsDir("presets");
    for (auto f : presetsDir.getFiles()){
        if(f.isDirectory()){
            presetItems.push_back(f.getFileName());
        }
    }
    
    static int presetComboItem = -1;
    
    std::vector<const char *> cStrArray;
    cStrArray.reserve(presetItems.size());
    for(int index = 0; index < presetItems.size(); ++index)
    {
        cStrArray.push_back(presetItems[index].c_str());
        if(updatePresetItem){
            if(strcmp(presetItems[index].c_str(), strSaveFileName) == 0)
            {
                presetComboItem = index;
            }
        }
    }
    
    ImGui::PushItemWidth(195);
    ImGui::Combo("##PresetLoadFileName", &presetComboItem, &cStrArray[0], cStrArray.size());
    ImGui::PopItemWidth();
    ImGui::SameLine();
    if(presetComboItem > -1){
        if(ImGui::Button("Load", ofVec2f(50,25))){
            loadParameterGroup(rootParameters, cStrArray[presetComboItem]);
            strcpy (strSaveFileName,cStrArray[presetComboItem]);
        }
    } else {
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, 0.5 );
        ImGui::Button("Load", ofVec2f(50,25));
        ImGui::PopStyleVar();
    }
    
    ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
    ImGui::TextUnformatted("Movement");
    ImGui::PopFont();
    bool mirrorCameraVal = mirrorCamera.get();
    if(ImGui::Checkbox("Mirrored", &mirrorCameraVal)){
        mirrorCamera.set(mirrorCameraVal);
    }
    ImGuiSliderFromParam(offsetScale);
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
    
    
    if(guiLedSynth != nullptr){
        //TODO: Node editor
        
        ImGui::End();
        
        ImGui::SetNextWindowPos(ofVec2f(ofGetWidth()-guiColumnWidth,0));
        ImGui::SetNextWindowSize(ofVec2f(guiColumnWidth,ofGetHeight()));
        ImGui::Begin("Node Editor", NULL, window_flags);
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[2]);
        ImGui::Text("Node %i",guiLedSynth->ownID.get());
        ImGui::PopFont();
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[3]);
        ImGui::Text("Software version: %i.%i", guiLedSynth->versionMajor.get(), guiLedSynth->versionMinor.get());
        ImGui::PopFont();

        ImGui::PushItemWidth(195-60);

        ImGuiInputFromParam(guiLedSynth->ownID);
        ImGui::SameLine();
        if(ImGui::Button("Save in node##doSaveId")){
            guiLedSynth->doSaveId.set(1);
        };
        
        ImGuiInputFromParam(guiLedSynth->remoteID);
        
        ImGui::PopItemWidth();

        ImGui::PushFont(ImGuiIO().Fonts->Fonts[3]);
        if(guiLedSynth->ownID.get() == guiLedSynth->remoteID.get()){
            ImGui::TextUnformatted("Movement sensor selected");
        } else if (guiLedSynth->remoteID.get() == 0){
            ImGui::TextUnformatted("Light sensor selected");
        } else {
            ImGui::Text("Remote %i selected", guiLedSynth->remoteID.get());
        }
        ImGui::PopFont();

        //  ImGui::TextUnformatted([guiLedSynth->peripheral identifier]);
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Ranges");
        ImGui::PopFont();
        ImGui::Text("Intensity: %.1f %%  ...  %.1f %%",
                    ofMap(guiLedSynth->intensityRangeBottom, 0, 1023, 0.0, 100.0),
                    ofMap(guiLedSynth->intensityRangeTop, 0, 1023, 0.0, 100.0)
                    );
        ImGui::Text("Temperature: %i k  ...  %i k", int(
                    floor(ofMap(guiLedSynth->temperatureRangeBottom, 0, 1023, guiLedSynth->temperatureOutput.getMin(), guiLedSynth->temperatureOutput.getMax()))),
                    int(floor(ofMap(guiLedSynth->temperatureRangeTop, 0, 1023, guiLedSynth->temperatureOutput.getMin(), guiLedSynth->temperatureOutput.getMax())))
                    );
        bool useRanges = guiLedSynth->useRanges.get() == 1;
        if(ImGui::Checkbox("Use Ranges", &useRanges)){
            guiLedSynth->useRanges.set(useRanges?1:0);
        }
        
        bool remoteOverride = guiLedSynth->remoteOverride.get() == 1;
        if(ImGui::Checkbox("Override", &remoteOverride)){
            guiLedSynth->remoteOverride.set(remoteOverride?1:0);
        }
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Faders");
        ImGui::PopFont();
        ImGuiSliderFromParam(guiLedSynth->intensityFader);
        ImGuiSliderFromParam(guiLedSynth->temperatureFader);
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Remote");
        ImGui::PopFont();
        ImGuiSliderFromParam(guiLedSynth->intensityRemote);
        ImGuiSliderFromParam(guiLedSynth->temperatureRemote);
        ImGuiSliderFromParam(guiLedSynth->mixRemote);
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Weather");
        ImGui::PopFont();
        ImGuiSliderFromParam(guiLedSynth->intensityNoise);
        ImGuiSliderFromParam(guiLedSynth->temperatureNoise);
        ImGuiSliderFromParam(guiLedSynth->mixNoise);
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[1]);
        ImGui::TextUnformatted("Output");
        ImGui::PopFont();
        ImGuiSliderFromParam(guiLedSynth->intensityOutput);
        ImGuiSliderFromParam(guiLedSynth->temperatureOutput);
        
    }
    
    
    // Node Tooltips
    
    if(tooltipLedSynth != nullptr){
        
        ImGui::BeginTooltip();
        float percent;
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[3]);
        
        ImGui::Text("ID: %i\nVersion: %i.%i", tooltipLedSynth->ownID.get(), tooltipLedSynth->versionMajor.get(), tooltipLedSynth->versionMinor.get());
        if(tooltipLedSynth->ownID.get() == tooltipLedSynth->remoteID.get()){
            ImGui::TextUnformatted("Movement sensor selected");
        } else if (tooltipLedSynth->remoteID.get() == 0){
            ImGui::TextUnformatted("Light sensor selected");
        } else {
            ImGui::Text("Remote %i selected", tooltipLedSynth->remoteID.get());
        }
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Faders");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityFader.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k", percent, tooltipLedSynth->temperatureFader.get());
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Remote");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityRemote.get() * 0.1;
        ImGui::Text("Channel: %i\nIntensity: %.1f %%\nTemperature: %i k\nMix: %.1f %%", tooltipLedSynth->remoteID.get(), percent, tooltipLedSynth->temperatureRemote.get(), ofMap(tooltipLedSynth->mixRemote.get(), tooltipLedSynth->mixRemote.getMin(), tooltipLedSynth->mixRemote.getMax(), 0.0, 100.0));
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Weather");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityNoise.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k\nMix: %.1f %%", percent, tooltipLedSynth->temperatureNoise.get(), ofMap(tooltipLedSynth->mixNoise.get(), tooltipLedSynth->mixNoise.getMin(), tooltipLedSynth->mixNoise.getMax(), 0.0, 100.0));
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Output");
        ImGui::PopFont();
        percent = tooltipLedSynth->intensityOutput.get() * 0.1;
        ImGui::Text("Intensity: %.1f %%\nTemperature: %i k", percent, tooltipLedSynth->temperatureOutput.get());
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Movement Sensor");
        ImGui::PopFont();
        ImGui::Text("Sensor: %s\nLevel: %.1f %%", tooltipLedSynth->movementSensor.get()>0?"activity":"still", ofMap(tooltipLedSynth->movementSensorLevel.get(), 0, 1000, 0.0, 100.0));
        
        ImGui::PushFont(ImGuiIO().Fonts->Fonts[4]);
        ImGui::TextUnformatted("Light Sensor");
        ImGui::PopFont();
        ImGui::Text("Intensity: %i lux\nTemperature: %i k\nLevel: %i", tooltipLedSynth->lightSensorLux.get(), tooltipLedSynth->lightSensorTemperature.get(), tooltipLedSynth->lightSensorLightLevel.get());
        ImGui::PopFont();
        
        ImGui::EndTooltip();
    }
    
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
    
}

void ofApp::layout(){
    int windowHeight = (ofGetWindowWidth()-(guiColumnWidth*2))+statusbarHeight;
    ofSetWindowShape(ofGetWindowWidth(), windowHeight);
    ofLogNotice(__FUNCTION__) << ofGetWindowRect() << endl;
    windowDidResize = false;
    weatherRect.set(guiColumnWidth, 0, ofGetWindowWidth()-(guiColumnWidth*2), ofGetWindowHeight()-statusbarHeight);
}

#pragma mark Noise image functions

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
    float intensity = ofNoise(x*intensitySpreadCubic, y*intensitySpreadCubic, intensityTime);
    return ofMap(intensity, 0, 1, intensityRangeFrom, intensityRangeTo);
}

ofFloatColor ofApp::getColor(float x, float y){
    float intensity = getIntensity(x, y);
    int temp = getTemperature(x, y);
    ofFloatColor c = ledSynth::temperatureToColor(temp);
    c *= intensity;
    return c;
}

#pragma mark OF callbacks

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    if(key == OF_KEY_TAB) showGuiDemo = !showGuiDemo;
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y){
    for (auto l :ledSynths){
        
        ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
        
        if(position.distance(ofVec2f(x,y)) < 30.0){
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
        
        if(fabs(position.x) > 1.0 || fabs(position.y) > 1.0){
            if(fabs(position.x)>fabs(position.y)){
                position *= 1.0/fabs(position.x);
            } else{
                position *= 1.0/fabs(position.y);
            }
        }
        
        draggedLedSynth->position = position;
    }
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    
    if(draggedLedSynth == nullptr){
        for (auto l :ledSynths){
            
            ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
            
            if(position.distance(ofVec2f(x,y)) < 30.0){
                draggedLedSynth = l;
                mouseDragOffset = position - ofVec2f(x,y);
                break;
            }
            
        }
    }
    
    bool ledSynthClicked = false;
    
    for (auto l :ledSynths){
        
        if(l->initDone){
            ofVec2f position = (l->position.get()*weatherRect.getWidth()/2.0) + weatherRect.getCenter();
            
            if(position.distance(ofVec2f(x,y)) < 30.0){
                guiLedSynth = l;
                l->identify = 1;
                ledSynthClicked = true;
            }
            
        }
        
    }
    if(weatherRect.inside(x, y) && !ledSynthClicked) {
        if(guiLedSynth != nullptr) guiLedSynth->identify = 0;
        guiLedSynth = nullptr;
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

#pragma mark BLE callbacks

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
        if(tooltipLedSynth == (*it)){
            tooltipLedSynth = nullptr;
        }
        if(guiLedSynth == (*it)){
            guiLedSynth = nullptr;
        }
        ledSynths.erase(it);
        delete l;
        [ble stopScan];
        [ble startScan];
    }
}

#pragma mark Gui functions

void ofApp::ImGuiSliderFromParam(ofAbstractParameter &p){
    ofParameter<int> pInt;
    if(p.type() == pInt.type()){
        ofParameter<int> &pIntValue = p.cast<int>();
        int value = pIntValue;
        if(ImGui::SliderInt(pIntValue.getName().c_str(), &value, pIntValue.getMin(), pIntValue.getMax())){
            pIntValue.set(value);
        }
        return;
    }
    ofParameter<float> pFloat;
    if(p.type() == pFloat.type()){
        ofParameter<float> &pFloatValue = p.cast<float>();
        float value = pFloatValue.get();
        if(ImGui::SliderFloat(pFloatValue.getName().c_str(), &value, pFloatValue.getMin(), pFloatValue.getMax())){
            pFloatValue.set(value);
        }
        return;
    }
}

void ofApp::ImGuiDragFromParam(ofAbstractParameter &p){
    ofParameter<int> pInt;
    if(p.type() == pInt.type()){
        ofParameter<int> &pIntValue = p.cast<int>();
        int value = pIntValue;
        if(ImGui::DragInt(pIntValue.getName().c_str(), &value, pIntValue.getMin(), pIntValue.getMax())){
            pIntValue.set(value);
        }
        return;
    }
    ofParameter<float> pFloat;
    if(p.type() == pFloat.type()){
        ofParameter<float> &pFloatValue = p.cast<float>();
        float value = pFloatValue.get();
        if(ImGui::DragFloat(pFloatValue.getName().c_str(), &value, pFloatValue.getMin(), pFloatValue.getMax())){
            pFloatValue.set(value);
        }
        return;
    }
}

void ofApp::ImGuiInputFromParam(ofAbstractParameter &p){
    ofParameter<int> pInt;
    if(p.type() == pInt.type()){
        ofParameter<int> &pIntValue = p.cast<int>();
        int value = pIntValue;
        if(ImGui::InputInt(pIntValue.getName().c_str(), &value)){
            pIntValue.set(value);
        }
        return;
    }
    ofParameter<float> pFloat;
    if(p.type() == pFloat.type()){
        ofParameter<float> &pFloatValue = p.cast<float>();
        float value = pFloatValue.get();
        if(ImGui::InputFloat(pFloatValue.getName().c_str(), &value)){
            pFloatValue.set(value);
        }
        return;
    }
}

void ofApp::ImGuiRangeFromParams(ofAbstractParameter &pFrom, ofAbstractParameter &pTo){
    ofParameter<int> pInt;
    if(pFrom.type() == pInt.type()){
        ofParameter<int> &pIntFromValue = pFrom.cast<int>();
        ofParameter<int> &pIntToValue = pTo.cast<int>();
        int valueFrom = pIntFromValue;
        int valueTo = pIntToValue;
        if(ImGui::DragIntRange2(pIntFromValue.getName().c_str(), &valueFrom, &valueTo, 1.0, pIntFromValue.getMin(), pIntFromValue.getMax())){
            pIntFromValue.set(valueFrom);
            pIntToValue.set(valueTo);
        }
        return;
    }
    ofParameter<float> pFloat;
    if(pFrom.type() == pFloat.type()){
        ofParameter<float> &pFloatFromValue = pFrom.cast<float>();
        ofParameter<float> &pFloatToValue = pTo.cast<float>();
        float valueFrom = pFloatFromValue;
        float valueTo = pFloatToValue;
        if(ImGui::DragFloatRange2(pFloatFromValue.getName().c_str(), &valueFrom, &valueTo, 0.001, pFloatFromValue.getMin(), pFloatFromValue.getMax(), "%.3f")){
            pFloatFromValue.set(valueFrom);
            pFloatToValue.set(valueTo);
        }
        return;
    }
}


void ofApp::saveParameterGroup(ofParameterGroup &g, string name){
    ofxPanel ofxGuiPanel;
    for(auto p : g){
        string newName(p->getName());
        ofStringReplace(newName, "##", "__");
        p->setName(newName);
    }
    ofxGuiPanel.setup("_"+name);
    ofxGuiPanel.add(g);
    ofxGuiPanel.saveToFile("presets/" + name + "/globals.xml");
    for(auto p : g){
        string newName(p->getName());
        ofStringReplace(newName, "__", "##");
        p->setName(newName);
    }
    
    for(auto l : ledSynths){
        ofxPanel ofxGuiPanelForLeds;
        ofxGuiPanelForLeds.setup("_"+name);
        ofxGuiPanelForLeds.add(l->persistentParameters);
        ofxGuiPanelForLeds.saveToFile("presets/" + name + "/node-" + ofToString(l->ownID) + ".xml");
    }
    
}

void ofApp::loadParameterGroup(ofParameterGroup &g, string name){
    ofxPanel ofxGuiPanel;
    for(auto p : g){
        string newName(p->getName());
        ofStringReplace(newName, "##", "__");
        p->setName(newName);
    }
    ofxGuiPanel.setup("_"+name);
    ofxGuiPanel.add(g);
    ofxGuiPanel.loadFromFile("presets/" + name + "/globals.xml");
    for(auto p : g){
        string newName(p->getName());
        ofStringReplace(newName, "__", "##");
        p->setName(newName);
    }
    
    for(auto l : ledSynths){
        ofxPanel ofxGuiPanelForLeds;
        ofxGuiPanelForLeds.setup("_"+name);
        ofxGuiPanelForLeds.add(l->persistentParameters);
        ofxGuiPanelForLeds.loadFromFile("presets/" + name + "/node-" + ofToString(l->ownID) + ".xml");
    }
    
}

