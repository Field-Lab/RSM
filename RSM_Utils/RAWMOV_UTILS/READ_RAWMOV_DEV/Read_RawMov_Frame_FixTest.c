#include "io64.h"
#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define NDIMS 2



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])    
{

	FILE *fp;
	char *filename;
    //mwSize i, nf;  // need to pass in nelements
	size_t elements_read; 
    unsigned char *read_vector;
    int width, height, header_len, frame_num, buflen, status;
//    unsigned long long n;
//    int fh;
    int64_T offset;
    int x;

    
    // input protection
	if( nrhs != 5 ) {
		mexErrMsgTxt("Need exactly five inputs ... (filename, width, height, header_len, current_frame_num)");
	}
	if( nlhs > 5 ) {
		mexErrMsgTxt("Too many outputs.");
	}
	if( !mxIsChar(prhs[0]) ) {
		mexErrMsgTxt("Argument must be base filename string.");
	}

    /* Get the length of the input string. */
    buflen = (mxGetNumberOfElements(prhs[0]) + 1); // (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* Allocate memory for input and output strings. */
    filename = mxCalloc(buflen, sizeof(char));

    
    //associate pointers
   // sp = mxGetData(prhs[0]);
    status = mxGetString(prhs[0], filename, buflen);
    
    // Retrieve input scalar size values
    width = mxGetScalar(prhs[1]);
    height = mxGetScalar(prhs[2]);
    header_len = mxGetScalar(prhs[3]);
    frame_num = mxGetScalar(prhs[4]);
    
    const mwSize arraysize[]={(width*height*3), 1};
    
    // Setup the filename
//	nf = mxGetNumberOfElements(prhs[0]);
    
//    mexPrintf("%d \n",nf);
    
    
//	filename = mxMalloc(nf+7);
    // filename = mxMalloc(nf);
    
    // filename setup and inspection
//    for( i=0; i<(nf-1); i++ ) {
//		filename[i] = *sp++;
		//if( filename[i] == 0 ) {
	//		mexErrMsgTxt("Null (0) character detected in filename");
	//	}
//	}

//    mexPrintf(filename);

    //mexPrintf("Opening Real File: %s\n",filename);
	fp = fopen(filename, "r");    // rb since we know it isnt a text file. read binary
	
    if( !fp ) {
		mexErrMsgTxt("File will not open.");
	}
    
    
    // fseek goes here
    //fseek(fp, (header_len * sizeof( char )), 0);
    //fseek(fp, (header_len * sizeof( unsigned char )), 0);
    //fseek(fp, (((frame_num * arraysize[0]) + header_len) * sizeof(unsigned char)), 0);
    
    // http://www.gridlabd.org/documents/doxygen/1.1/mexfio64_8c-source.html
    offset = (int64_T)((((int64_T)frame_num * (int64_T)arraysize[0]) + (int64_T)header_len) * (int64_T)sizeof(unsigned char));
    x = setFilePos( fp, (fpos_T*) &offset);
    
    // Create a space to put the date
    
    plhs[0] = mxCreateNumericArray( NDIMS, arraysize, mxUINT8_CLASS, mxREAL );  // will need to change format
    
    
    // Associate the pointer
	read_vector = (unsigned char *)mxGetData( plhs[0] );

    
    // Actual fread including check on number of elements read
//array size nelements
    elements_read = fread( read_vector, sizeof(unsigned char), arraysize[0], fp );
    
    fclose(fp);
    
    return;
    
}