
FUNCTION memSwitch : memSwitchStatus_e
	VAR_INPUT
		pIn : UDINT;
		size : UDINT;
		pOut : UDINT;
		maxsize : UDINT;
		type : memSwitchType_e := memSwitchType_4;
	END_VAR
	VAR
		rep : UDINT;
		i : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK rpcGetPort
	VAR_INPUT
		enable : BOOL;
		pIp : UDINT;
		rpcPort : UINT := 111;
	END_VAR
	VAR_OUTPUT
		port : UINT;
		status : rpcStatus_e;
	END_VAR
	VAR
		rpcConnectState : rpcConnectionState_e := rpcConnectionState_Wait;
		rpcConnErrorState : rpcConnectionState_e;
		rpcErrorCode : UINT;
		tcpOpenRpc : TcpOpen;
		tcpCloseRpc : TcpClose;
		tcpClilentRcp : TcpClient;
		tcpSendDataRcp : TcpSend;
		tcpRecvDataRcp : TcpRecv;
		rpcCallHeader : rpcCallHeaderGetPort_t;
		rpcReplyHeader : rpcReplyHeaderGetPort_t;
		rpcReplyHeaderLength : UDINT;
		tcpDataTransferBuffer : ARRAY[0..99] OF UDINT;
		tcpDataTransferRecvBuffer : ARRAY[0..99] OF UDINT;
		conn_RE : r_trig;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK rpcGenericConnect
	VAR_INPUT
		enable : BOOL; (*Enable connection*)
		pIp : UDINT; (*Pointer to IP address*)
		rpcPort : UINT; (*Connection port*)
	END_VAR
	VAR_OUTPUT
		status : rpcStatus_e; (*Status of connection*)
		ident : UDINT; (*Socket ident*)
	END_VAR
	VAR
		conn_RE : r_trig;
		tcpOpenRpc : TcpOpen;
		tcpCloseRpc : TcpClose;
		tcpClilentRcp : TcpClient;
		rpcConnectState : rpcConnectionState_e := rpcConnectionState_Wait;
		rpcConnErrorState : rpcConnectionState_e; (*Last error section for debug*)
		rpcErrorCode : UINT; (*Last error number for debug*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK rpcDataExchange
	VAR_INPUT
		enable : BOOL;
		ident : UDINT;
		prpcTxData : UDINT;
		rpcTxDataLength : UDINT;
		prpcRxData : UDINT;
		rpcRxDataMax : UDINT;
	END_VAR
	VAR_OUTPUT
		rpcRxDataLength : UDINT;
		status : rpcDataExchangeStatus_e := rpcDataExchangeStatus_NotEnabled; (*Status of connection*)
	END_VAR
	VAR_IN_OUT
		rpcCallHeader : rpcCallHeader_t;
		rpcReplyHeader : rpcReplyHeader_t;
	END_VAR
	VAR
		tcpTxDataSize : UDINT;
		conn_RE : r_trig;
		tcpSendDataRcp : TcpSend;
		tcpRecvDataRcp : TcpRecv;
		tcpDataTxBuffer : ARRAY[0..199] OF UDINT;
		tcpDataRxBuffer : ARRAY[0..199] OF UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK vxi11
	VAR_INPUT
		enable : BOOL; (*Enable connection*)
		pIp : UDINT; (*Pointer to IP address*)
		pDevName : UDINT; (*Pointer to device name in creation of link*)
		enableUser : BOOL;
		userReqType : vxiReqType_e := vxiReqType_WR;
		pDataTx : UDINT := 0; (*Pointer to tx data request - string*)
		pDataRx : UDINT := 0; (*Pointer to rx data - string*)
		maxRx : UDINT := 0; (*Maximum length of rx string*)
	END_VAR
	VAR_OUTPUT
		status : vxiStatus_e; (*Status of connection*)
		userStatus : vxiUserStatus_e;
	END_VAR
	VAR
		vxiIdent : UDINT;
		linkID : UDINT;
		enableDataExchange : BOOL;
		rpcDE_0 : rpcDataExchange;
		rpcXviPort : UINT;
		vxiConnect : BOOL;
		conn_RE : r_trig;
		userEnTr : r_trig;
		rpcGP : rpcGetPort;
		rpcGenCon : rpcGenericConnect;
		vxiPort : UINT;
		rpcDataTxBuffer : ARRAY[0..199] OF UDINT;
		rpcDataRxBuffer : ARRAY[0..199] OF UDINT;
		rpcCallHeader : rpcCallHeader_t;
		rpcReplyHeader : rpcReplyHeader_t;
		vxiCreateLinkCall : vxiCreateLinkCall_t;
		vxiCreateLinkReply : vxiCreateLinkReply_t;
		vxiWriteCall : vxiWriteCall_t;
		vxiWriteReply : vxiWriteReply_t;
		vxiReadCall : vxiReadCall_t;
		vxiReadReply : vxiReadReply_t;
		vxiDestroyLinkErrCode : vxiErrorCode_e;
		brsMemCpyNextAddr : UDINT;
		nullChar : USINT := 0;
	END_VAR
END_FUNCTION_BLOCK
