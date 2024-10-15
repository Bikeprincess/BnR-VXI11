FUNCTION_BLOCK rpcGenericConnect
	conn_RE(CLK := enable);
	
	CASE rpcConnectState OF
		rpcConnectionState_Wait://
			IF conn_RE.Q THEN
				status := rpcStatus_Busy;
				rpcConnectState := rpcConnectionState_OpenSocket;
			END_IF;
			IF enable = FALSE THEN
				status := rpcStatus_NotEnabled;
				ident := 0;
			END_IF;
			
		rpcConnectionState_OpenSocket://
			tcpOpenRpc(enable := TRUE, pIfAddr := ADR("0"), port := 0);
			IF tcpOpenRpc.status <> ERR_FUB_BUSY THEN
				IF tcpOpenRpc.status = ERR_OK THEN
					rpcConnectState := rpcConnectionState_Connect;
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_Wait;
					rpcConnErrorState := rpcConnectionState_OpenSocket;
					rpcErrorCode := tcpOpenRpc.status;
				END_IF;
			END_IF;
			
		rpcConnectionState_Connect://
			tcpClilentRcp(enable := TRUE, ident := tcpOpenRpc.ident, pServer := pIp, portserv := rpcPort);
			IF tcpClilentRcp.status <> ERR_FUB_BUSY THEN
				IF tcpClilentRcp.status = ERR_OK THEN
					rpcConnectState := rpcConnectionState_User;
					ident := tcpOpenRpc.ident;
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_CloseSocket;
					rpcConnErrorState := rpcConnectionState_Connect;
					rpcErrorCode := tcpClilentRcp.status;
				END_IF;
			END_IF;
			
		
			
		rpcConnectionState_User://
			
			status := rpcStatus_OK;
			IF enable = FALSE THEN
				rpcConnectState := rpcConnectionState_CloseSocket;
			END_IF;
					
		rpcConnectionState_CloseSocket://
			tcpCloseRpc(enable := TRUE, ident := tcpOpenRpc.ident, how := 0);
			IF tcpCloseRpc.status <> ERR_FUB_BUSY THEN
				IF tcpCloseRpc.status = ERR_OK THEN
					rpcConnectState := rpcConnectionState_Wait;
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_Wait;
					rpcConnErrorState := rpcConnectionState_CloseSocket;
					rpcErrorCode := tcpCloseRpc.status;
				END_IF;
			END_IF;
			
		ELSE rpcConnectState := rpcConnectionState_Wait;		
	END_CASE;
END_FUNCTION_BLOCK



//Generic data exchange for RPC
FUNCTION_BLOCK rpcDataExchange 
	conn_RE(CLK := enable);
	
	CASE status OF
		rpcDataExchangeStatus_NotEnabled://
			IF conn_RE.Q THEN
				status := rpcDataExchangeStatus_Prepare;
			END_IF;
			
		rpcDataExchangeStatus_Prepare:
			tcpTxDataSize := SIZEOF(rpcCallHeader) + rpcTxDataLength;
			IF tcpTxDataSize > SIZEOF(tcpDataTxBuffer) THEN
				status := rpcDataExchangeStatus_Error;
			END_IF;
			
			IF (tcpTxDataSize MOD 4) > 0 THEN
				tcpTxDataSize := ((tcpTxDataSize / 4) + 1) * 4;
			END_IF;
			rpcCallHeader.FragmentHeader := 16#80000000 + (tcpTxDataSize - 4);//Last segment always
			
			memSwitch(pIn := ADR(rpcCallHeader), size := SIZEOF(rpcCallHeader), pOut := ADR(tcpDataTxBuffer), maxsize := SIZEOF(tcpDataTxBuffer), type := memSwitchType_4);
			brsmemcpy(ADR(tcpDataTxBuffer) + SIZEOF(rpcCallHeader), prpcTxData, rpcTxDataLength);
			
			status := rpcDataExchangeStatus_Send;
			
		rpcDataExchangeStatus_Send:
			tcpSendDataRcp(enable := TRUE, ident := ident, pData := ADR(tcpDataTxBuffer), datalen := tcpTxDataSize);
			IF tcpSendDataRcp.status <> ERR_FUB_BUSY THEN
				IF tcpSendDataRcp.status = ERR_OK THEN
					status := rpcDataExchangeStatus_Recv;
				ELSE
					status := rpcDataExchangeStatus_Error;
				END_IF;
			END_IF;
			
		rpcDataExchangeStatus_Recv:
			tcpRecvDataRcp(enable := TRUE, ident := ident, pData := ADR(tcpDataRxBuffer), datamax := SIZEOF(tcpDataRxBuffer));
			IF tcpRecvDataRcp.status <> ERR_FUB_BUSY THEN
				IF tcpRecvDataRcp.status = ERR_OK THEN
					rpcRxDataLength := tcpRecvDataRcp.recvlen - SIZEOF(rpcReplyHeader);
					IF rpcRxDataLength > rpcRxDataMax THEN
						status := rpcDataExchangeStatus_Error;
					END_IF;
					memSwitch(ADR(tcpDataRxBuffer), SIZEOF(rpcReplyHeader), ADR(rpcReplyHeader), SIZEOF(rpcReplyHeader), memSwitchType_4);
					brsmemcpy(prpcRxData, ADR(tcpDataRxBuffer) + SIZEOF(rpcReplyHeader), rpcTxDataLength);
					status := rpcDataExchangeStatus_OK;
				ELSIF tcpRecvDataRcp.status = tcpERR_NO_DATA THEN
					
				ELSE
					status := rpcDataExchangeStatus_Error;
				END_IF;
			END_IF;
			
		rpcDataExchangeStatus_OK:
			IF NOT enable THEN
				status := rpcDataExchangeStatus_NotEnabled;
			END_IF;
			
		rpcDataExchangeStatus_Error:
			IF NOT enable THEN
				status := rpcDataExchangeStatus_NotEnabled;
			END_IF;
			
		ELSE status := rpcDataExchangeStatus_Error;
	END_CASE;
END_FUNCTION_BLOCK
