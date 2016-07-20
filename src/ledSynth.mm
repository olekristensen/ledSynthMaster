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

void ledSynth::removeListeners(){
    ofRemoveListener(hardware.parameterChangedE(),
                     this, &ledSynth::updateHardwareValue);
}

void ledSynth::setup(){
    position.set(ofVec2f(ofRandom(-1.0,1.0), ofRandom(-1.0,1.0)));
    //gui.setup(parameters, "settings.xml");
    ofAddListener(hardware.parameterChangedE(),
                  this, &ledSynth::updateHardwareValue);
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
                    ofLogVerbose() << cmd_data.cmd << " " << cmd_data.item << " " << cmd_data.value << endl;
                    ofParameter<int> & p = hardware.getInt(cmd_data.item);
                    switch (cmd_data.cmd)
                    {
                        case cmd_setValue:

                            p.disableEvents();
                            p = cmd_data.value;
                            p.enableEvents();
                            break;
                        case cmd_setMin:
                            p.setMin(cmd_data.value);
                            break;
                        case cmd_setMax:
                            p.setMax(cmd_data.value);
                            break;
                        case cmd_ping:
                            ofLogVerbose(__FUNCTION__) << "received ping" << endl;
                            hardwareInit();
                            break;
                        case cmd_init_done:
                            ofLogVerbose(__FUNCTION__) << "received init done" << endl;
                            initDone = true;
                            break;
                            
                    }
                    cmd_data.cmd = cmd_executed;
                }
                if(canSend){
                    // wait a bit between update bathces
                    if(nextHardwareUpdateMillis < ofGetElapsedTimeMillis()){
                        // go through the queue of params to update
                        for (auto paramToUpdate : paramsToUpdate){
                            int i = 0;
                            // find it in the hardware group
                            for(auto paramInHardware : hardware){
                                if(paramInHardware->getName() == paramToUpdate->getName()){
                                    // send update
                                    ofLogVerbose() << "updating " << paramToUpdate->getName() << endl;
                                    cmd_data.cmd = cmd_setValue;
                                    cmd_data.value = paramToUpdate->cast<int>();
                                    cmd_data.item = i;
                                    ET.sendData();
                                    break;
                                }
                            i++;
                        }
                    }
                    paramsToUpdate.clear();
                        nextHardwareUpdateMillis = ofGetElapsedTimeMillis() + hardwareUpdateIntervalMillis;
                    }
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
void ledSynth::draw(bool selected){
    
    float innerRadius = 10;
    float outerRadius = 30;

    ofPushMatrix();
    ofFill();
    ofSetColor(64,55);
    
    ofPath graph;
    ofPath graphBackground;
    
    graph.setFilled(true);
    graphBackground.setFilled(true);
    graph.setColor(ofColor(255,200));
    graphBackground.setColor(ofColor(255,55));
    
    int i = 0;
    
    for(auto p : graphParameters){
        
        ofVec2f pVec(0,
                     ofMap(p->cast<int>().get(), p->cast<int>().getMin(), p->cast<int>().getMax(), innerRadius, outerRadius, true)
                     );
        
        pVec.rotate(360.0*i/graphParameters.size());
        
        if(i==0){
            graph.moveTo(pVec);
            graphBackground.moveTo(pVec.getScaled(outerRadius));
        } else {
            graph.lineTo(pVec);
            graphBackground.lineTo(pVec.getScaled(outerRadius));
        }
        i++;
    }
    graph.close();
    graphBackground.close();
    graphBackground.draw();
    graph.draw();
    
    graphBackground.setFilled(false);
    if(selected){
        graphBackground.setStrokeColor(ofColor(255,255));
    } else {
        graphBackground.setStrokeColor(ofColor(255,64));
    }
    graphBackground.setStrokeWidth(1.0);
    graphBackground.draw();

    if(connected) {
        ofSetColor(ofColor::red, movementSensor*127);
        ofDrawCircle(0, 0, innerRadius+2);
        ofSetColor(temperatureToColor(temperatureOutput)*ofMap(intensityOutput,intensityOutput.getMin(),intensityOutput.getMax(), 0.0, 1.0),255);
        ofDrawCircle(0, 0, innerRadius);
    }else{
        ofFill();
        ofSetColor(temperatureToColor(temperatureNoise)*ofMap(intensityNoise,intensityNoise.getMin(),intensityNoise.getMax(), 0.0, 1.0),255);
        ofDrawCircle(0, 0, innerRadius);
        ofNoFill();
        ofSetColor(255,200);
        ofDrawCircle(0, 0, innerRadius);
        ofFill();
    }
    
    ofPopMatrix();
    
}

void ledSynth::drawGui(){
    ImGui::SetNextWindowSize(ofVec2f(200,100), ImGuiSetCond_FirstUseEver);
    ImGui::SetWindowPos(position.get());
    char buf[128];
    sprintf(buf, "Node %i", ownID.get());
    ImGui::Begin(buf, &guiShown);
    int remoteIDGui = remoteID.get();
    if(ImGui::DragInt("Remote ID", &remoteIDGui, 1, 0, 9))
        remoteID.set(remoteIDGui);
    ImGui::End();
    
}

void ledSynth::receivedData(NSData *data )
{
    for (int i = 0; i < [data length]; i++) {
        inputQueue.push(*(((char *)[data bytes])+i));
    }
}

void ledSynth::updateHardwareValue(ofAbstractParameter &param){
        // check if this is a hardware parameter
        if(hardware.contains(param.getName())){
            // check if this parameter is allready queued
            for(auto paramToUpdate : paramsToUpdate){
                if(paramToUpdate->getName() == param.getName()){
                    return; // param is allready queued
                }
            }
            // push this parameter onto the update queue
            paramsToUpdate.push_back(&param);
        }
}

void ledSynth::hardwareInit()
{
    cmd_data.cmd = cmd_init;
    ET.sendData();
    ofLogVerbose(__FUNCTION__) << "sent init" << endl;
}