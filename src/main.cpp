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

    // say that we're going to *use* the fancy new renderer
    ofSetCurrentRenderer(ofGLProgrammableRenderer::TYPE);
    
    ofAppGLFWWindow window;
    window.setNumSamples(16);
    ofSetupOpenGL(&window, 1280,800, OF_WINDOW);

	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp( new ofApp());

}
