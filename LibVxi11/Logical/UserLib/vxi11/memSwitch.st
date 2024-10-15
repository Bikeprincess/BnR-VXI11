FUNCTION memSwitch
	IF size > maxsize THEN
		memSwitch := memSwitchStatus_Error;
	END_IF;
	
	CASE type OF
		memSwitchType_4:
			//Endianity switch for 4 bytes
			IF (size MOD 4) <> 0 THEN
				memSwitch := memSwitchStatus_NonDiv;
			END_IF;
			rep := (size / 4) - 1;
			FOR i := 0 TO rep BY 1 DO
				brsmemcpy(pOut + (i * 4) + 0, pIn + (i * 4) + 3, 1);
				brsmemcpy(pOut + (i * 4) + 1, pIn + (i * 4) + 2, 1);
				brsmemcpy(pOut + (i * 4) + 2, pIn + (i * 4) + 1, 1);
				brsmemcpy(pOut + (i * 4) + 3, pIn + (i * 4) + 0, 1);
			END_FOR;		
		memSwitchType_2:
		memSwitch := memSwitchStatus_Error;
			
		memSwitchType_W:
			//Words switch
			memSwitch := memSwitchStatus_Error;
		
		ELSE memSwitch := memSwitchStatus_Error;
	END_CASE;
	
	//	pIn
	//	size
	//	pOut
	//	maxsize
	//	type
	
	memSwitch := memSwitchStatus_OK;
	END_FUNCTION