PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	//Set parametres
	vxi_UT8805E.enable		:= vxiConn;
	vxi_UT8805E.enableUser	:= vxiUserSend;
	vxi_UT8805E.pIp			:= ADR(RemoteIP);
	vxi_UT8805E.pDevName	:= ADR(vxiDeviceName);
	vxi_UT8805E.userReqType := vxiReqType;
	vxi_UT8805E.pDataTx 	:= ADR(vxiRequest);
	vxi_UT8805E.pDataRx 	:= ADR(vxiResponse);
	vxi_UT8805E.maxRx 		:= SIZEOF(vxiResponse);
	//block call
	vxi_UT8805E();
	
	vxiUserSend := FALSE;
	
	IF numEnableConv THEN
		numEnableConv := FALSE;
		numValue := brsatof(ADR(vxiResponse));
	END_IF;
	
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM

