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
    //gui.setup(parameters, "settings.xml");
    ofAddListener(parameters.parameterChangedE(), this, &ledSynth::updateHardwareValue);
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
                            updateHardware = false;
                            p = cmd_data.value;
                            updateHardware = true;
                            break;
                        case cmd_setMin:
                            p.setMin(cmd_data.value);
                            break;
                        case cmd_setMax:
                            p.setMax(cmd_data.value);
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
    
    float innerRadius = 0.02;
    float outerRadius = 0.08;

    ofPushMatrix();
    ofTranslate(position.get());
    ofFill();
    ofSetColor(200,255);
    ofDrawCircle(0, 0, outerRadius);
    
    ofPath graph;
    ofPath graphBackground;
    
    graph.setFilled(true);
    graphBackground.setFilled(true);
    graph.setColor(ofColor(233,255));
    graphBackground.setColor(ofColor(180,255));
    
    int i = 0;
    
    for(auto p : graphParameters){
        
        ofVec2f pVec(0,
                     ofMap(p->cast<int>().get(), p->cast<int>().getMin(), p->cast<int>().getMax(), innerRadius, outerRadius)
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
    
    if(connected) {
        ofSetColor(temperatureToColor(temperatureOutput)*ofMap(intensityOutput,intensityOutput.getMin(),intensityOutput.getMax(), 0.0, 1.0),255);
    }else{
        ofSetColor(255,64);
    }
    ofDrawCircle(0, 0, innerRadius);
    
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
    if(updateHardware && canSend){
        int i = 0;
        for(auto p : hardware){
            if(p.get()->getName() == param.getName()){
                ofLogNotice() << "updating " << param.getName() << endl;
                cmd_data.cmd = cmd_setValue;
                cmd_data.value = param.cast<int>();
                cmd_data.item = i;
                ET.sendData();
                break;
            }
            i++;
        }
    }
}

void ledSynth::hardwareInit()
{
    cmd_data.cmd = cmd_init;
    ET.sendData();
    ofLogVerbose() << "sent init" << endl;
}