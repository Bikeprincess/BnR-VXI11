# VXI11-brplc

Simply VXI11 communication library fo B&amp;R PLC in AS6

## Use

Create cyclic task, which will call FB `vxi11`. This block do all. After `enable := TRUE` the block create connection to device.

If the `status = vxiStatus_User_Wait` you can send the commands. Fill the `pDataTx` with pointer to string command, set `pDataRx` to receiv buffer, set command type and set `enableUser` to `TRUE`. In `userStatus` you can read status of this request.

When you want to send another request, reset and set `enableUser` - it's react only to edge.