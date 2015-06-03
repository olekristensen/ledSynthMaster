//
//  EasyTransfer.cpp
//  ledSynthMaster
//
//  Created by ole kristensen on 29/05/15.
//
//

#include "EasyTransfer.h"
#include "ledSynth.h"

//Captures address and size of struct
void EasyTransfer::begin(uint8_t * ptr, uint8_t length, ledSynth* ledSynth){
    address = ptr;
    size = length;
    _ledSynth = ledSynth;
    
    //dynamic creation of rx parsing buffer in RAM
    rx_buffer = (uint8_t*) malloc(size);
    rx_array_inx = 0;
    rx_len = 0;
}

//Sends out struct in binary, with header, length info and checksum
void EasyTransfer::sendData(){
    uint8_t CS = size;
    
    //temp storage place
    uint8_t temp_buffer[size+4];
    
    temp_buffer[0] = 0x06;
    temp_buffer[1] = 0x85;
    temp_buffer[2] = size;
    
    for(int i = 0; i<size; i++){
        CS^=*(address+i);
        temp_buffer[i+3] = (*(address+i));
    }
    temp_buffer[size+3] = CS;
    ((ofxRFduino*)_ledSynth)->send((unsigned char *)temp_buffer, size+4);
    
}

bool EasyTransfer::receiveData(){
    
    //start off by looking for the header bytes. If they were already found in a previous call, skip it.
    if(rx_len == 0){
        //this size check may be redundant due to the size check below, but for now I'll leave it the way it is.
        if(_ledSynth->inputQueue.size() >= 3){
            
            //this will block until a 0x06 is found or buffer size becomes less then 3.
            
            while( (uint8_t)_ledSynth->inputQueue.front() != 0x06) {
                _ledSynth->inputQueue.pop();
                cout << "trashing," << endl;
                //This will trash any preamble junk in the serial buffer
                //but we need to make sure there is enough in the buffer to process while we trash the rest
                //if the buffer becomes too empty, we will escape and try again on the next call
                if(_ledSynth->inputQueue.size() < 3)
                    return false;
                
            }
            //cout << "found 0x06" << endl;
            _ledSynth->inputQueue.pop();
            if ((uint8_t)_ledSynth->inputQueue.front() == 0x85){
                //cout << "found 0x85" << endl;
                _ledSynth->inputQueue.pop();
                rx_len = (uint8_t)_ledSynth->inputQueue.front();
                //cout << "size: " << int(rx_len) << endl;
                _ledSynth->inputQueue.pop();
                //make sure the binary structs on both Arduinos are the same size.
                if(rx_len != size){
                    rx_len = 0;
                    cout << "size mismatch: size is " << int(size) << " but received " << int(rx_len) << endl;
                    return false;
                    
                }
            }
            //_ledSynth->inputQueue.pop();
        }
    }
    
    //we get here if we already found the header bytes, the struct size matched what we know, and now we are byte aligned.
    if(rx_len != 0){
        while(_ledSynth->inputQueue.size() > 0 && rx_array_inx <= rx_len){
            rx_buffer[rx_array_inx++] = _ledSynth->inputQueue.front();
            _ledSynth->inputQueue.pop();
        }
        
        if(rx_len == (rx_array_inx-1)){
            //seem to have got whole message
            //last uint8_t is CS
            calc_CS = rx_len;
            for (int i = 0; i<rx_len; i++){
                calc_CS^=rx_buffer[i];
            }
            
            if(calc_CS == rx_buffer[rx_array_inx-1]){//CS good
                memcpy(address,rx_buffer,size);
                rx_len = 0;
                rx_array_inx = 0;
                
                return true;
            }
            
            else{
                //failed checksum, need to clear this out anyway
                cout << "checksum failed"  << endl;
                rx_len = 0;
                rx_array_inx = 0;
                return false;
                
            }
            
        }
    }
    return false;
}