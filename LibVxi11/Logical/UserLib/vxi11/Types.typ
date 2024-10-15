
TYPE
	memSwitchType_e : 
		(
		memSwitchType_4, (*Change endianity for 4 bytes*)
		memSwitchType_2, (*Change endianity for 2 bytes*)
		memSwitchType_W (*Switch words*)
		);
	memSwitchStatus_e : 
		(
		memSwitchStatus_OK := 0,
		memSwitchStatus_Error := 1,
		memSwitchStatus_NonDiv := 2
		);
END_TYPE

(*RPC Header*)

TYPE
	rpcCallHeaderGetPort_t : 	STRUCT 
		FragmentHeader : UDINT := 16#80000038; (*Pevnì daná délka + poslední segment*)
		XID : UDINT;
		Call : rpcMsgType_e := rpcMsgType_Call;
		RPCVersion : UDINT := 2;
		Program : rpcProgram_e := rpcProgram_Portmap;
		ProgVersion : UDINT := 2;
		Procedure : rpcProcedure_e := rpcProcedure_GetPort;
		Credentials : rpcAuth_t;
		Verifier : rpcAuth_t;
		VxiProgram : rpcProgram_e := rpcProgram_vxi11Core;
		VxiProgVersion : UDINT := 1;
		VxiProtocol : UDINT := 6; (*TCP*)
		VxiPort : UDINT := 0;
	END_STRUCT;
	rpcReplyHeaderGetPort_t : 	STRUCT 
		FragmentHeader : UDINT;
		XID : UDINT;
		MsgType : rpcMsgType_e;
		ReplyState : rpcMsgState_e;
		Verifier : rpcAuth_t;
		AcceptState : rpcExecute_e;
		Port : UDINT;
	END_STRUCT;
	rpcCallHeader_t : 	STRUCT 
		FragmentHeader : UDINT; (*Pevnì daná délka + poslední segment*)
		XID : UDINT;
		Call : rpcMsgType_e;
		RPCVersion : UDINT := 2;
		Program : rpcProgram_e;
		ProgVersion : UDINT := 1;
		Procedure : rpcProcedure_e;
		Credentials : rpcAuth_t;
		Verifier : rpcAuth_t;
	END_STRUCT;
	rpcReplyHeader_t : 	STRUCT 
		FragmentHeader : UDINT;
		XID : UDINT;
		MsgType : rpcMsgType_e;
		ReplyState : rpcMsgState_e;
		Verifier : rpcAuth_t;
		AcceptState : rpcExecute_e;
	END_STRUCT;
	rpcAuth_t : 	STRUCT 
		Flavor : rpcAuth_e := rpcAuth_Null;
		Length : UDINT;
	END_STRUCT;
END_TYPE

(*Enums*)

TYPE
	rpcMsgType_e : 
		(
		rpcMsgType_Call := 0,
		rpcMsgType_Reply := 1
		);
	rpcMsgState_e : 
		(
		rpcMsgState_Accepted := 0,
		rpcMsgState_Denied := 1
		);
	rpcAuth_e : 
		(
		rpcAuth_Null := 0,
		rpcAuth_Unix := 1,
		rpcAuth_Short := 2,
		rpcAuth_Des := 3
		);
	rpcExecute_e : 
		(
		rpcExecute_Success := 0, (*RPC executed successfully*)
		rpcExecute_ErrProgExport := 1, (*remote hasn't exported program*)
		rpcExecute_ErrVersion := 2, (*remote can't support version*)
		rpcExecute_ErrProcedure := 3, (*program can't support procedure*)
		rpcExecute_ErrDecode := 4 (*procedure can't decode params*)
		);
	rpcStatus_e : 
		(
		rpcStatus_OK,
		rpcStatus_Error,
		rpcStatus_NotEnabled,
		rpcStatus_Busy,
		rpcStatus_NotConnected
		);
	rpcProcedure_e : 
		(
		rpcProcedure_GetPort := 3,
		rpcProcedure_CreateLink := 10,
		rpcProcedure_DeviceWrite := 11,
		rpcProcedure_DeviceRead := 12,
		rpcProcedure_ReadSTB := 13,
		rpcProcedure_Trigger := 14,
		rpcProcedure_Clear := 15,
		rpcProcedure_Remote := 16,
		rpcProcedure_Local := 17,
		rpcProcedure_Lock := 18,
		rpcProcedure_Unlock := 19,
		rpcProcedure_EnableSRQ := 20,
		rpcProcedure_DoCMD := 22,
		rpcProcedure_DestroyLink := 23,
		rpcProcedure_CreateIntrChan := 25,
		rpcProcedure_DestroyIntrChan := 26
		);
	rpcProgram_e : 
		(
		rpcProgram_Portmap := 100000,
		rpcProgram_vxi11Core := 395183
		);
	rpcDataExchangeStatus_e : 
		(
		rpcDataExchangeStatus_NotEnabled,
		rpcDataExchangeStatus_Prepare,
		rpcDataExchangeStatus_Send,
		rpcDataExchangeStatus_Recv,
		rpcDataExchangeStatus_OK,
		rpcDataExchangeStatus_Error
		);
END_TYPE

(*vxi11*)

TYPE
	vxiStatus_e : 
		(
		vxiStatus_NotEnabled,
		vxiStatus_GetPort,
		vxiStatus_CreateConn,
		vxiStatus_CreateLinkDP,
		vxiStatus_CreateLinkDE,
		vxiStatus_CreateLinkDA,
		vxiStatus_User_Wait,
		vxiStatus_User_WriteDP,
		vxiStatus_User_WriteDE,
		vxiStatus_User_WriteDA,
		vxiStatus_User_ReadDP,
		vxiStatus_User_ReadDE,
		vxiStatus_User_ReadDA,
		vxiStatus_DestroyLinkDP,
		vxiStatus_DestroyLinkDE,
		vxiStatus_DestroyLinkDA,
		vxiStatus_Disconnecting,
		vxiStatus_Error
		);
	vxiReqType_e : 
		(
		vxiReqType_WO, (*Write to device only*)
		vxiReqType_RO, (*Read from device only*)
		vxiReqType_WR (*Write to device and read back*)
		);
END_TYPE

(*Data exchange - Create link*)

TYPE
	vxiCreateLinkCall_t : 	STRUCT 
		ClientID : UDINT;
		LockDevice : UDINT := 0;
		LockTimeout : UDINT := 0;
		DevNameLen : UDINT;
	END_STRUCT;
	vxiCreateLinkReply_t : 	STRUCT 
		ErrorCode : vxiErrorCode_e;
		LinkID : UDINT;
		AbortPort : UDINT;
		MaxRecvSize : UDINT;
	END_STRUCT;
END_TYPE

(*User section*)

TYPE
	vxiWriteCall_t : 	STRUCT 
		LinkID : UDINT;
		IoTimeout : UDINT;
		LockTimeout : UDINT;
		Flags : UDINT;
		DataLength : UDINT;
	END_STRUCT;
	vxiWriteReply_t : 	STRUCT 
		ErrorCode : vxiErrorCode_e;
		Size : UDINT;
	END_STRUCT;
	vxiReadCall_t : 	STRUCT 
		LinkID : UDINT;
		Size : UDINT := 255;
		IoTimeout : UDINT := 8000;
		LockTimeout : UDINT := 0;
		Flags : UDINT := 0;
		TerminationCharacter : UDINT := 16#0A;
	END_STRUCT;
	vxiReadReply_t : 	STRUCT 
		ErrorCode : vxiErrorCode_e;
		Reason : UDINT;
		DataLength : UDINT;
	END_STRUCT;
	vxiErrorCode_e : 
		(
		vxiErrorCode_OK := 0, (*ERR_NO_ERROR *)
		vxiErrorCode_SyntaxError := 1, (*ERR_SYNTAX_ERROR *)
		vxiErrorCode_DeviceNotAccessible := 3, (*ERR_DEVICE_NOT_ACCESSIBLE *)
		vxiErrorCode_InvalidLinkIdent := 4, (*ERR_INVALID_LINK_IDENTIFIER *)
		vxiErrorCode_ParameterErr := 5, (*ERR_PARAMETER_ERROR *)
		vxiErrorCode_ChannelNotEstab := 6, (*ERR_CHANNEL_NOT_ESTABLISHED *)
		vxiErrorCode_OperationNotSup := 8, (*ERR_OPERATION_NOT_SUPPORTED *)
		vxiErrorCode_OutOfResources := 9, (*ERR_OUT_OF_RESOURCES *)
		vxiErrorCode_DevLocked := 11, (*ERR_DEVICE_LOCKED_BY_ANOTHER_LINK *)
		vxiErrorCode_NoLOckHeld := 12, (*ERR_NO_LOCK_HELD_BY_THIS_LINK *)
		vxiErrorCode_IoTimeout := 15, (*ERR_IO_TIMEOUT *)
		vxiErrorCode_IoError := 17, (*ERR_IO_ERROR *)
		vxiErrorCode_InvalidAddress := 21, (*ERR_INVALID_ADDRESS *)
		vxiErrorCode_Abort := 23, (*ERR_ABORT *)
		vxiErrorCode_ChannelAlreadyEstab := 29, (*ERR_CHANNEL_ALREADY_ESTABLISHED *)
		New_Member2,
		New_Member1,
		New_Member
		);
	vxiUserStatus_e : 
		(
		vxiUserStatus_OK := 0,
		vxiUserStatus_Busy := 1,
		vxiUserStatus_Error,
		vxiUserStatus_NotEnabled,
		vxiUserStatus_LowBuffer
		);
END_TYPE

(*Automats*)

TYPE
	rpcConnectionState_e : 
		(
		rpcConnectionState_Wait, (*Wait for enable*)
		rpcConnectionState_OpenSocket, (*Create socket*)
		rpcConnectionState_Connect, (*Connect to client*)
		rpcConnectionState_SendGetPort, (*Send request to server*)
		rpcConnectionState_RecvGetPort, (*Read reply from server*)
		rpcConnectionState_User, (*Connected state for user program*)
		rpcConnectionState_CloseSocket (*Close connection and socket - aftrer enable = false or connection problem*)
		);
END_TYPE
