FUNCTION_BLOCK rpcGetPort
	conn_RE(CLK := enable);
	
	CASE rpcConnectState OF
		rpcConnectionState_Wait://
			IF conn_RE.Q THEN
				status := rpcStatus_Busy;
				rpcConnectState := rpcConnectionState_OpenSocket;
			END_IF;
			IF enable = FALSE THEN
				status := rpcStatus_NotEnabled;
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
					rpcConnectState := rpcConnectionState_SendGetPort;
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_CloseSocket;
					rpcConnErrorState := rpcConnectionState_Connect;
					rpcErrorCode := tcpClilentRcp.status;
				END_IF;
			END_IF;
			
		rpcConnectionState_SendGetPort://
			memSwitch(ADR(rpcCallHeader), SIZEOF(rpcCallHeader), ADR(tcpDataTransferBuffer), SIZEOF(tcpDataTransferBuffer), memSwitchType_4);
			tcpSendDataRcp(enable := TRUE, ident := tcpOpenRpc.ident, pData := ADR(tcpDataTransferBuffer), datalen := SIZEOF(rpcCallHeader));
			IF tcpSendDataRcp.status <> ERR_FUB_BUSY THEN
				IF tcpSendDataRcp.status = ERR_OK THEN
					rpcConnectState := rpcConnectionState_RecvGetPort;
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_CloseSocket;
					rpcConnErrorState := rpcConnectionState_SendGetPort;
					rpcErrorCode := tcpSendDataRcp.status;
				END_IF;
			END_IF;
			
		rpcConnectionState_RecvGetPort://
			tcpRecvDataRcp(enable := TRUE, ident := tcpOpenRpc.ident, pData := ADR(tcpDataTransferRecvBuffer), datamax := SIZEOF(tcpDataTransferRecvBuffer));
			IF tcpRecvDataRcp.status <> ERR_FUB_BUSY THEN
				IF tcpRecvDataRcp.status = ERR_OK THEN
					memSwitch(ADR(tcpDataTransferRecvBuffer), SIZEOF(rpcReplyHeader), ADR(rpcReplyHeader), SIZEOF(rpcReplyHeader), memSwitchType_4);
					rpcConnectState := rpcConnectionState_User;
				ELSIF tcpRecvDataRcp.status = tcpERR_NO_DATA THEN
				
				ELSE
					status := rpcStatus_Error;
					rpcConnectState := rpcConnectionState_CloseSocket;
					rpcConnErrorState := rpcConnectionState_RecvGetPort;
					rpcErrorCode := tcpRecvDataRcp.status;
				END_IF;
			END_IF;
			
		rpcConnectionState_User://
			port := UDINT_TO_UINT(rpcReplyHeader.Port);
			status := rpcStatus_OK;
			rpcConnectState := rpcConnectionState_CloseSocket;
		
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