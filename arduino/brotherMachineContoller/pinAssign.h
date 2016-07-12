

// SHIELD
#ifdef shieldTypeOriginal
	#define enc1 27  //encoder 1
	#define enc2 26  //encoder 2
	#define enc3 25  //phase encoder
	#define LEnd 23  //endLineLeft 
	#define REnd 22  //endLineRight
	// String endType = "digital";
    #ifdef machineTypeKH930
    int solenoidsTemp[16] = {31,32,34,36,37,40,42,44,46,45,43,41,39,37,35,35};
  #endif
  #ifdef machineTypeKH970
    int solenoidsTemp[16] = {31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46};
  #endif
  #ifdef machineTypeCK35
    int solenoidsTemp[16] = {31,33,35,37,39,41,43,45,42,40,38,36,34,32,44,46};
  #endif
#endif
#ifdef shieldTypeKnitic
	#define enc1 2  //encoder 1
	#define enc2 3  //encoder 2
	#define enc3 4  //phase encoder
	#define LEnd A0  //endLineLeft 
	#define REnd A1  //endLineRight
	// String endType = "analog";
 // MACHINE  
  #ifdef machineTypeKH930
    int solenoidsTemp[16] = {22,23,25,27,29,31,33,35,37,36,34,32,30,28,26,24};
  #endif
  #ifdef machineTypeKH970
    int solenoidsTemp[16] = {22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37};
  #endif
  #ifdef machineTypeCK35
    int solenoidsTemp[16] = {22,24,26,28,30,32,34,36,33,31,29,27,25,23,35,37};
  #endif
#endif

#define LED 13
