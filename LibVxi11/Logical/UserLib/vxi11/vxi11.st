FUNCTION_BLOCK vxi11
	rpcCallHeader.RPCVersion := 2;
	rpcCallHeader.Program := rpcProgram_vxi11Core;
	rpcCallHeader.ProgVersion := 1;
	
	
	conn_RE(CLK := enable);
	userEnTr(CLK := enableUser);
	enableDataExchange := FALSE;
	
	IF NOT enableUser THEN
		userStatus := vxiUserStatus_NotEnabled;
	END_IF;
	
	CASE status OF
		vxiStatus_NotEnabled://
			vxiConnect := FALSE;
			IF conn_RE.Q THEN
				status := vxiStatus_GetPort;
			ELSIF enable THEN
				status := vxiStatus_NotEnabled;				
			END_IF;
			
		vxiStatus_GetPort:
			IF rpcGP.status = rpcStatus_OK THEN
				vxiPort := rpcGP.port;
				status := vxiStatus_CreateConn;
			ELSIF rpcGP.status = rpcStatus_Error THEN
				status := vxiStatus_Error;
			END_IF;
			
		vxiStatus_CreateConn:
			vxiConnect := TRUE;
			IF rpcGenCon.status = rpcStatus_OK THEN
				status := vxiStatus_CreateLinkDP;
				vxiIdent := rpcGenCon.ident;
			ELSIF rpcGenCon.status = rpcStatus_Error THEN
				status := vxiStatus_Error;
			END_IF;

		vxiStatus_CreateLinkDP:
			rpcCallHeader.XID := rpcCallHeader.XID + 1;
			rpcCallHeader.Call := rpcMsgType_Call;
			rpcCallHeader.Procedure := rpcProcedure_CreateLink;			
			vxiCreateLinkCall.ClientID := 184483578;
			vxiCreateLinkCall.DevNameLen := brsstrlen(pDevName);
			memSwitch(pIn := ADR(vxiCreateLinkCall), size := SIZEOF(vxiCreateLinkCall), pOut := ADR(rpcDataTxBuffer), maxsize := SIZEOF(rpcDataTxBuffer), type := memSwitchType_4);
			brsmemcpy(ADR(rpcDataTxBuffer) + SIZEOF(vxiCreateLinkCall), pDevName, brsstrlen(pDevName));
			rpcDE_0.rpcTxDataLength := SIZEOF(vxiCreateLinkCall) + brsstrlen(pDevName);
			status := vxiStatus_CreateLinkDE;
			
		vxiStatus_CreateLinkDE:
			enableDataExchange := TRUE;		
			IF rpcDE_0.status = rpcDataExchangeStatus_OK THEN
				enableDataExchange := FALSE;	
				status := vxiStatus_CreateLinkDA;
			ELSIF rpcDE_0.status = rpcDataExchangeStatus_Error THEN
				status := vxiStatus_Error;
			END_IF;
			
			
		vxiStatus_CreateLinkDA:
			memSwitch(pIn := ADR(rpcDataRxBuffer), size := SIZEOF(vxiCreateLinkReply), pOut := ADR(vxiCreateLinkReply), maxsize := SIZEOF(vxiCreateLinkReply), type := memSwitchType_4);
			IF vxiCreateLinkReply.ErrorCode = 0 THEN
				linkID := vxiCreateLinkReply.LinkID;
				status := vxiStatus_User_Wait;
			ELSE
				status := vxiStatus_Error;
			END_IF;
			
			
//User section for data exchange
		vxiStatus_User_Wait:
			IF enable THEN
				IF userEnTr.Q THEN
					userStatus := vxiUserStatus_Busy;
					status := vxiStatus_User_WriteDP;
				END_IF;
			ELSE
				status := vxiStatus_DestroyLinkDP;
			END_IF;
			
		vxiStatus_User_WriteDP:
			IF userReqType = vxiReqType_RO THEN
				status := vxiStatus_User_ReadDP;
			ELSE				
				rpcCallHeader.XID := rpcCallHeader.XID + 1;
				rpcCallHeader.Call := rpcMsgType_Call;
				rpcCallHeader.Procedure := rpcProcedure_DeviceWrite;
				vxiWriteCall.DataLength := brsstrlen(pDataTx);
				vxiWriteCall.Flags := vxiFlag_Write_SetEOI;
				vxiWriteCall.IoTimeout := 8000;
				vxiWriteCall.LockTimeout := 0;
				vxiWriteCall.LinkID := linkID;
				memSwitch(pIn := ADR(vxiWriteCall), size := SIZEOF(vxiWriteCall), pOut := ADR(rpcDataTxBuffer), maxsize := SIZEOF(rpcDataTxBuffer), type := memSwitchType_4);
				brsmemcpy(ADR(rpcDataTxBuffer) + SIZEOF(vxiWriteCall), pDataTx, vxiWriteCall.DataLength);
				rpcDE_0.rpcTxDataLength := SIZEOF(vxiWriteCall) + vxiWriteCall.DataLength;
				status := vxiStatus_User_WriteDE;
			END_IF;
			
		vxiStatus_User_WriteDE:
			enableDataExchange := TRUE;		
			IF rpcDE_0.status = rpcDataExchangeStatus_OK THEN
				enableDataExchange := FALSE;	
				status := vxiStatus_User_WriteDA;
			ELSIF rpcDE_0.status = rpcDataExchangeStatus_Error THEN
				userStatus := vxiUserStatus_Error;
				status := vxiStatus_User_Wait;
			END_IF;
			
		vxiStatus_User_WriteDA:
			memSwitch(pIn := ADR(rpcDataRxBuffer), size := SIZEOF(vxiWriteReply), pOut := ADR(vxiWriteReply), maxsize := SIZEOF(vxiWriteReply), type := memSwitchType_4);
			IF vxiWriteReply.ErrorCode = vxiErrorCode_OK AND vxiWriteReply.Size = vxiWriteCall.DataLength THEN
				status := vxiStatus_User_ReadDP;
			ELSE
				userStatus := vxiUserStatus_Error;
				status := vxiStatus_User_Wait;
			END_IF;
			
			
		vxiStatus_User_ReadDP:
			IF userReqType = vxiReqType_WO THEN
				userStatus := vxiUserStatus_OK;
				status := vxiStatus_User_Wait;
			ELSE
				rpcCallHeader.XID := rpcCallHeader.XID + 1;
				rpcCallHeader.Call := rpcMsgType_Call;
				rpcCallHeader.Procedure := rpcProcedure_DeviceRead;
				vxiReadCall.LinkID := linkID;
				vxiReadCall.Size := 255;
				vxiReadCall.IoTimeout := 8000;
				vxiReadCall.LockTimeout := 0;
				vxiReadCall.TerminationCharacter := 10;//SINT_TO_UDINT('\n')
				memSwitch(pIn := ADR(vxiReadCall), size := SIZEOF(vxiReadCall), pOut := ADR(rpcDataTxBuffer), maxsize := SIZEOF(vxiReadCall), type := memSwitchType_4);
				rpcDE_0.rpcTxDataLength := SIZEOF(vxiReadCall);
				status := vxiStatus_User_ReadDE;
			END_IF;
			
		vxiStatus_User_ReadDE:
			enableDataExchange := TRUE;		
			IF rpcDE_0.status = rpcDataExchangeStatus_OK THEN
				enableDataExchange := FALSE;	
				status := vxiStatus_User_ReadDA;
			ELSIF rpcDE_0.status = rpcDataExchangeStatus_Error THEN
				userStatus := vxiUserStatus_Error;
				status := vxiStatus_User_Wait;
			END_IF;
			
		vxiStatus_User_ReadDA:
			memSwitch(pIn := ADR(rpcDataRxBuffer), size := SIZEOF(vxiReadReply), pOut := ADR(vxiReadReply), maxsize := SIZEOF(vxiReadReply), type := memSwitchType_4);
			IF vxiReadReply.ErrorCode = 0 AND vxiReadReply.DataLength > 0 AND vxiReadReply.DataLength < maxRx THEN
				brsMemCpyNextAddr := brsmemcpy(pDataRx, ADR(rpcDataRxBuffer) + SIZEOF(vxiReadReply), vxiReadReply.DataLength);
				brsmemcpy(brsMemCpyNextAddr, ADR(nullChar), 1);
				userStatus := vxiUserStatus_OK;
				status := vxiStatus_User_Wait;
			ELSE
				userStatus := vxiUserStatus_Error;
				status := vxiStatus_User_Wait;
			END_IF;
			
//End of user section			
						
			
//Destroy link
		vxiStatus_DestroyLinkDP:
			rpcCallHeader.XID := rpcCallHeader.XID + 1;
			rpcCallHeader.Call := rpcMsgType_Call;
			rpcCallHeader.Procedure := rpcProcedure_DestroyLink;
			memSwitch(pIn := ADR(linkID), size := SIZEOF(linkID), pOut := ADR(rpcDataTxBuffer), maxsize := SIZEOF(rpcDataTxBuffer), type := memSwitchType_4);
			rpcDE_0.rpcTxDataLength := SIZEOF(linkID);
			status := vxiStatus_DestroyLinkDE;
			
		vxiStatus_DestroyLinkDE:
			enableDataExchange := TRUE;		
			IF rpcDE_0.status = rpcDataExchangeStatus_OK THEN
				enableDataExchange := FALSE;
				status := vxiStatus_DestroyLinkDA;
			ELSIF rpcDE_0.status = rpcDataExchangeStatus_Error THEN
				status := vxiStatus_Error;
			END_IF;
			
		vxiStatus_DestroyLinkDA:
			memSwitch(pIn := ADR(rpcDataRxBuffer), size := SIZEOF(vxiDestroyLinkErrCode), pOut := ADR(vxiDestroyLinkErrCode), maxsize := SIZEOF(vxiDestroyLinkErrCode), type := memSwitchType_4);
			status := vxiStatus_Disconnecting;
			
//Disconnect
		vxiStatus_Disconnecting:
			vxiConnect := FALSE;
			IF rpcGenCon.status = rpcStatus_NotEnabled THEN
				status := vxiStatus_NotEnabled;
			END_IF;
		
		vxiStatus_Error:
			vxiConnect := FALSE;
			enableDataExchange := FALSE;	
			IF NOT enable THEN
				status := vxiStatus_NotEnabled;
			END_IF;
			
		ELSE status := vxiStatus_Error;		
	END_CASE;
	
	
	rpcGP(enable := status = vxiStatus_GetPort, pIp := pIp);
	rpcGenCon(enable := vxiConnect, pIp := pIp, rpcPort := vxiPort);
	rpcDE_0(enable := enableDataExchange, ident := vxiIdent, prpcTxData := ADR(rpcDataTxBuffer), prpcRxData := ADR(rpcDataRxBuffer), rpcRxDataMax := SIZEOF(rpcDataRxBuffer), rpcCallHeader := rpcCallHeader, rpcReplyHeader := rpcReplyHeader);
	
	
END_FUNCTION_BLOCK