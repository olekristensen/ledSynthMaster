#include "ofMain.h"
#include "ofApp.h"
#include "ofAppGLFWWindow.h"

extern "C"{
    size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
    {
        return fwrite(a, b, c, d);
    }
    char* strerror$UNIX2003( int errnum )
    {
        return strerror(errnum);
    }
    time_t mktime$UNIX2003(struct tm * a)
    {
        return mktime(a);
    }
    double strtod$UNIX2003(const char * a, char ** b) {
        return strtod(a, b);
    }
}


//========================================================================
int main( ){
    
    ofGLFWWindowSettings settings;
    settings.width = 1065;
    settings.height = 833;
    settings.setPosition(ofVec2f(300,0));
    settings.resizable = true;
    settings.numSamples = 8;
    settings.setGLVersion(4, 1);
    shared_ptr<ofAppBaseWindow> mainWindow = ofCreateWindow(settings);
    
    shared_ptr<ofApp> mainApp(new ofApp);
    
    ofRunApp(mainWindow, mainApp);
    ofRunMainLoop();

}
