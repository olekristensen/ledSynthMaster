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
    bounds.set(0, 0, 250, 500);
    ownID = 0;
    index = nextIndex++;
    bounds.setPosition((index*bounds.width*1.05)+20, - bounds.height*1.1);
    setGUI();
    this->setup();
}

ledSynth::~ledSynth(){
    guinoClear();
    index = nextIndex--;
}

void ledSynth::setup(){
    gui->setDrawBack(true);
}

//--------------------------------------------------------------
void ledSynth::update(){
    if(peripheral != NULL){
        switch (peripheral.state) {
            case CBPeripheralStateConnected:
                if(!connected && canSend){
                    ET.begin((uint8_t*)&guino_data, sizeof(guino_data),this);
                    connected = true;
                    //guinoInit();
                }
                while(inputQueue.size() > 0){
                    if(ET.receiveData())
                    {
                        float length = gui->getRect()->getWidth() - guiMargin;
                        
                        switch (guino_data.cmd)
                        {
                            case guino_addSlider:
                                ofxUISlider *slider;
                                slider = new ofxUISlider("", 0.0, 255.0, 0.0, length-guiMargin, guiSize);
                                gui->addWidgetDown(slider);
                                slider->setID(guino_data.item);
                                slider->setDrawOutline(true);
                                slider->setColorOutline(ofxUIColor::black);
                                slider->setColorOutlineHighlight(ofxUIColor::black);
                                slider->setValue(guino_data.value);
                                guino_items.push_back(slider);
                                
                                break;
                            case guino_setMax:
                                if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_SLIDER_H)
                                {
                                    ((ofxUISlider *)guino_items[guino_data.item])->setMax(guino_data.value);
                                    
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_MOVINGGRAPH)
                                {
                                    ((ofxUIMovingGraph *)guino_items[guino_data.item])->setMax(guino_data.value);
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_WAVEFORM)
                                {
                                    ((ofxUIWaveform *)guino_items[guino_data.item])->setMax(guino_data.value);
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER)
                                {
                                    ((ofxUIRotarySlider *)guino_items[guino_data.item])->setMax(guino_data.value);
                                    
                                }
                                
                                
                                break;
                            case guino_setMin:
                                if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_SLIDER_H)
                                {
                                    ((ofxUISlider *)guino_items[guino_data.item])->setMin(guino_data.value);
                                    
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_MOVINGGRAPH)
                                {
                                    ((ofxUIMovingGraph *)guino_items[guino_data.item])->setMin(guino_data.value);
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_WAVEFORM)
                                {
                                    ((ofxUIWaveform *)guino_items[guino_data.item])->setMin(guino_data.value);
                                    
                                }
                                else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER)
                                {
                                    ((ofxUIRotarySlider *)guino_items[guino_data.item])->setMin(guino_data.value);
                                    
                                }
                                
                                break;
                            case guino_iamhere:
                                guinoInit();
                                
                                break;
                            case guino_setValue:
                                if(guino_items.size() > guino_data.item)
                                {
                                    if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_SLIDER_H)
                                    {
                                        ((ofxUISlider *)guino_items[guino_data.item])->setValue(guino_data.value);
                                    }
                                    else if (guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_MOVINGGRAPH)
                                    {
                                        
                                        ((ofxUIMovingGraph *)guino_items[guino_data.item])->addPoint(guino_data.value);
                                    }
                                    else if (guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_LABELTOGGLE)
                                    {
                                        ((ofxUILabelToggle *)guino_items[guino_data.item])->setValue(!(guino_data.value==0));
                                        
                                    }
                                    else if (guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_WAVEFORM)
                                    {
                                        
                                        ((ofxUIWaveform *)guino_items[guino_data.item])->addPoint(guino_data.value);
                                    }
                                    else if (guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER)
                                    {
                                        
                                        ((ofxUIRotarySlider *)guino_items[guino_data.item])->setValue(guino_data.value);
                                    }
                                    
                                    
                                }
                                
                                break;
                            case guino_addChar:
                                if(guino_items.size() > guino_data.item)
                                {  // crappy hack to compensate for gui
                                    string _name =  guino_items[guino_data.item]->getName()+ ofToString((char)guino_data.value);
                                    ((ofxUIWidgetWithLabel *)guino_items[guino_data.item])->setName(_name );
                                    if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_SLIDER_H ||
                                       guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER
                                       )
                                        
                                        
                                        ((ofxUIWidgetWithLabel *)guino_items[guino_data.item])->getLabelWidget()->setLabel(_name);
                                    
                                    else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_LABEL)
                                    {
                                        ((ofxUILabel *)guino_items[guino_data.item])->setLabel(_name);
                                    }
                                    else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_LABELBUTTON)
                                    {
                                        ((ofxUILabelButton *) guino_items[guino_data.item])->setLabelText(_name);
                                    }
                                    else if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_LABELTOGGLE)
                                    {
                                        ((ofxUILabelToggle *) guino_items[guino_data.item])->setLabelText(_name);
                                    }
                                }
                                break;
                            case guino_addToggle:
                            {
                                ofxUIToggle * toggle =  gui->addLabelToggle( "", false, length-guiMargin,25);
                                
                                guino_items.push_back(toggle);
                                gui->addWidget(toggle);
                                toggle->setID(guino_data.item);
                                toggle->setDrawOutline(true);
                                toggle->setColorOutline(ofxUIColor::black);
                                toggle->setColorOutlineHighlight(ofxUIColor::black);
                                toggle->setValue(guino_data.value);
                                
                            }
                                break;
                                
                            case guino_addButton:
                            {
                                ofxUILabelButton * button = new ofxUILabelButton("", false, length-guiMargin,25);
                                guino_items.push_back(button);
                                gui->addWidgetDown(button);
                                button->setID(guino_data.item);
                                button->setDrawOutline(true);
                                button->setColorOutline(ofxUIColor::black);
                                button->setColorOutlineHighlight(ofxUIColor::red);
                                button->setColorFill(ofxUIColor::black);
                                button->setValue(guino_data.value);
                            }
                                
                                break;
                                
                            case guino_addMovingGraph:
                                
                            {
                                vector<float> buffer;
                                for(int i = 0; i < 256; i++)
                                {
                                    buffer.push_back(0.0);
                                }
                                
                                ofxUIMovingGraph * mg = new ofxUIMovingGraph((length-guiMargin) * ((float)guino_data.value)/10.0f, 120 * ((float)guino_data.value)/10.0f, buffer, 256, 0, 1000, "MOVING GRAPH");
                                gui->addWidgetDown(mg);
                                guino_items.push_back(mg);
                                mg->setID(guino_data.item);
                                mg->setDrawOutline(true);
                                mg->setColorOutline(ofxUIColor::black);
                                mg->setColorOutlineHighlight(ofxUIColor::black);
                                //  mg->addPoint(guino_data.value);
                            }
                                
                                break;
                            case guino_addLabel:
                            {
                                ofxUILabel* label = new ofxUILabel("", guino_data.value);
                                
                                
                                guino_items.push_back(label);
                                gui->addWidgetDown(label);
                                label->setID(guino_data.item);
                                
                                
                            }
                                break;
                            case guino_addSpacer:
                            {
                                ofxUISpacer * spacer =  gui->addSpacer(length-guiMargin, guino_data.value);
                                guino_items.push_back(spacer);
                                spacer->setID(guino_data.item);
                            }
                                break;
                           /* case guino_addColumn:
                            {
                                addColumn();
                            }
                                break;
                            */
                            case guino_addWaveform:
                            {
                                buffer = new float[2000];
                                for(int i = 0; i < 256; i++) { buffer[i] = ofNoise(i/100.0); }
                                
                                ofxUIWaveform * wave = new ofxUIWaveform((length-guiMargin) * ((float)guino_data.value)/10.0f, 120 * ((float)guino_data.value)/10.0f, buffer, 256, 0.0, 1.0, "WAVEFORM");
                                gui->addWidget(wave);
                                
                                wave->setDrawOutline(true);
                                wave->setColorOutline(ofxUIColor::black);
                                wave->setColorOutlineHighlight(ofxUIColor::black);

                                gui->addWidgetDown(wave);
                                guino_items.push_back(wave);
                                wave->setID(guino_data.item);
                            }
                                
                                
                                break;
                                
                            case guino_setFixedGraphBuffer:
                            {
                                if (guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_WAVEFORM)
                                {
                                    
                                    ((ofxUIWaveform *)guino_items[guino_data.item])->setBufferSize(guino_data.value);
                                }
                            }
                                break;
                            case guino_clearLabel:
                            {
                                ((ofxUIWidgetWithLabel *)guino_items[guino_data.item])->setName("");
                                if(guino_items[guino_data.item]->getKind() == OFX_UI_WIDGET_LABEL)
                                {
                                    ((ofxUILabel *)guino_items[guino_data.item])->setLabel("");
                                }
                            }
                                break;
                            case guino_addRotarySlider:
                            {
                                ofxUIRotarySlider * rotary = new ofxUIRotarySlider(guiSize*4, 0, 100, 50, "");
                                
                                if(guino_items[guino_items.size()-1]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER)
                                {
                                    gui->addWidgetRight(rotary);
                                }
                                else
                                {
                                    gui->addWidgetDown(rotary);
                                }
                                rotary->setDrawOutline(true);
                                rotary->setColorOutline(ofxUIColor::black);
                                rotary->setColorOutlineHighlight(ofxUIColor::black);

                                rotary->setValue(guino_data.value);
                                
                                guino_items.push_back(rotary);
                                rotary->setID(guino_data.item);
                            }
                                break;
                            case guino_xypad:
                                /* gui1->addWidgetDown(new ofxUI2DPad(length-guiMargin,80, ofPoint((length-guiMargin)*.5,80*.5), "PAD"));
                                 
                                 ofxUIRotarySlider * rotary = new ofxUIRotarySlider(guiSize*4, 0, 100, 50, "");
                                 
                                 if(guino_items[guino_items.size()-1]->getKind() == OFX_UI_WIDGET_ROTARYSLIDER)
                                 {
                                 gui->addWidgetRight(rotary);
                                 }
                                 else
                                 {
                                 gui->addWidgetDown(rotary);
                                 }
                                 
                                 guino_items.push_back(rotary);
                                 rotary->setID(guino_data.item);*/
                                break;
                            case guino_setColor:
                                
                            {
                                if(guino_data.item == 0)
                                {
                                    red = guino_data.value;
                                }
                                else if(guino_data.item == 1)
                                {
                                    green = guino_data.value;
                                }
                                else if(guino_data.item == 2)
                                {
                                    blue = guino_data.value;
                                }
                            }
                                break;
                        }
                        guino_data.cmd = guino_executed;
                        // add slider here
                        
                    }
                    
                }
                
                break;
            case CBPeripheralStateConnecting:
                connected = false;
                break;
            case CBPeripheralStateDisconnected:
                connected = false;
                guinoClear();
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
    ofPushMatrix();
    ofTranslate(bounds.getTopLeft());
    ofSetColor(red, green, blue, 255);
    ofRect(0,-3,bounds.width,3);
    if(connected) {
        ofSetColor(255);
    }else{
        ofSetColor(255,64);
    }
    ofRect(0,0,bounds.width,bounds.height);
    ofSetColor(red, green, blue, 255);
    //ofEllipse(0, bounds.width, 10, 10);
    ofSetColor(0);
    ofPopMatrix();
}

void ledSynth::setBounds(ofRectangle newBounds){
    bounds = newBounds;
    gui->setPosition(bounds.x, bounds.y);
}

void ledSynth::receivedData(NSData *data )
{
    //cout << "rec " << (char *)[data bytes] << endl;
    for (int i = 0; i < [data length]; i++) {
        inputQueue.push(*(((char *)[data bytes])+i));
    }
}

void ledSynth::guinoClear()
{
    
    guino_items.clear();

    ofRemoveListener(gui->newGUIEvent, this,&ledSynth::guiEvent);
    gui->clearEmbeddedWidgets();
            
    delete gui;
}

void ledSynth::guinoInit()
{
    
    guinoClear();
    setGUI();
    
    guino_data.cmd = guino_init;
    
    ET.sendData();
    cout << "sent init";
}

void ledSynth::guiEvent(ofxUIEventArgs &e)
{
    string name = e.widget->getName();
    int kind = e.widget->getKind();
    
    if(connected)
    {
        if(e.widget->getID() >=0)
        {
            if(kind == OFX_UI_WIDGET_SLIDER_H)
            {
                guino_data.value = (int16_t)((ofxUISlider *)guino_items[e.widget->getID()])->getScaledValue();
                guino_data.item = e.widget->getID();
                guino_data.cmd = guino_setValue;
                ET.sendData();
            }
            else if(kind == OFX_UI_WIDGET_LABELBUTTON)
            {
                guino_data.item = e.widget->getID();
                guino_data.cmd = guino_buttonPressed;
                guino_data.value = (int16_t)((ofxUILabelButton *)guino_items[e.widget->getID()])->getValue();
                ET.sendData();
                
            }
            else if(kind == OFX_UI_WIDGET_LABELTOGGLE)
            {
                guino_data.item = e.widget->getID();
                guino_data.cmd = guino_setValue;
                guino_data.value = (int16_t)((ofxUIToggle *)guino_items[e.widget->getID()])->getValue();
                ET.sendData();
                
            }
            else if( kind  == OFX_UI_WIDGET_ROTARYSLIDER)
            {
                guino_data.value = (int16_t)((ofxUIRotarySlider *)guino_items[e.widget->getID()])->getScaledValue();
                guino_data.item = e.widget->getID();
                guino_data.cmd = guino_setValue;
                ET.sendData();
                
            }
            
            
        }
    }
    
}

void ledSynth::setGUI()
{
    red = 0; blue = 0; green = 0;
    
    gui = new ofxUICanvas(bounds.getX(), bounds.getY(), bounds.getWidth(), bounds.getHeight());
    gui->setColorBack(ofxUIColor::white);
    gui->setColorFill(ofxUIColor::black);
    gui->setColorOutline(ofxUIColor::black);
    gui->setColorFillHighlight(ofxUIColor::red);
    gui->setWidgetSpacing(guiMargin);
    gui->setDrawOutline(false);
    gui->setFont("GUI/Avenir.ttc");
    //gui->setFont("GUI/HelveticaNeueDeskInterface.ttc");
    ofAddListener(gui->newGUIEvent,this,&ledSynth::guiEvent);
    
}