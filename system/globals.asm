; Night Kernel
; Copyright 2015 - 2019 by Mercury 0x0D
; globals.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.





section .data

; a define for use by Xenops, the version-updating tool with the most awesome name ever :D
%define BUILD 13

; vars, konstants, 'n' such
%define true									1
%define false									0

; for configbits settings - great idea, Antony!
%define kCBDebugMode							1
%define kCBVerbose								2
%define kCBLines50								4
%define kCBVMEnable								8



kKernelStack									dd 8192
kDriverSignature$								db 'N', 0x01, 'g', 0x09, 'h', 0x09, 't', 0x05, 'D', 0x02, 'r', 0x00, 'v', 0x01, 'r', 0x05





; strucTures
tSystem:
	.configBitsHint$							db 'ConfigBits'
	.configBits									dd 00000000000000000000000000000111b
	.copyright$									db 'Night Kernel, Copyright 2015 - 2019', 0x00
	.versionMajor								db 0x00
	.versionMinor								db 0x1C
	.versionBuild								dw BUILD
	.ticksSinceBoot								dd 0x00000000
	.currentTask								dd 0x00000000
	.currentTaskSlotAddress						dd 0x00000000
	.taskingEnable								db 0x00
	.taskStackSize								dd 1024		; a 1 KiB stack is almost guaranteed to be too small in the future
	.taskKernelStackSize						dd 1024
	.multicoreAvailable							db 0x00
	.CPUIDVendor$								times 16 db 0x00
	.CPUIDBrand$								times 64 db 0x00
	.CPUIDLargestBasicQuery						dd 0x00000000
	.CPUIDLargestExtendedQuery					dd 0x00000000
	.APMVersionMajor							db 0x00
	.APMVersionMinor							db 0x00
	.APMFeatures								dw 0x0000
	.mouseButtonCount							db 0x00
	.mouseButtons								db 0x00
	.mousePacketByteSize						db 0x00
	.mousePacketByteCount						db 0x00
	.mousePacketByte0							db 0x00
	.mousePacketByte1							db 0x00
	.mousePacketByte2							db 0x00
	.mousePacketByte3							db 0x00
	.mouseWheelPresent							db 0x00
	.mouseX										dw 0x0000
	.mouseXLimit								dw 0x0000
	.mouseY										dw 0x0000
	.mouseYLimit								dw 0x0000
	.mouseZ										dw 0x0000

section .bss
	.listDrives									resd 1
	.listMemory									resd 1
	.listPartitions								resd 1
	.listPCIDevices								resd 1
	.listTasks									resd 1
	.memoryInstalledBytes						resd 1
	.memoryInitialAvailableBytes				resd 1
	.memoryListReservedSpace					resd 1
	.PCIDeviceCount								resd 1
	.PCIVersion									resd 1
	.PCICapabilities							resd 1
	.PS2ControllerConfig						resb 1
	.PS2ControllerPort1Status					resb 1
	.PS2ControllerPort2Status					resb 1
	.PS2ControllerDeviceID1						resw 1
	.PS2ControllerDeviceID2						resw 1
	.RTCUpdateHandlerAddress					resd 1
	.RTCStatusRegisterB							resb 1
	.hours										resb 1
	.minutes									resb 1
	.seconds									resb 1
	.year										resb 1
	.month										resb 1
	.day										resb 1





; tDriveInfo, for the drives list (120 bytes)
%define tDriveInfo.ATABasePort					(esi + 00)
%define tDriveInfo.ATADeviceNumber				(esi + 04)
%define tDriveInfo.deviceFlags					(esi + 08)
%define tDriveInfo.cacheAddress					(esi + 12)
%define tDriveInfo.readSector					(esi + 16)
%define tDriveInfo.writeSector					(esi + 20)
%define tDriveInfo.model						(esi + 24)		; model is 64 bytes
%define tDriveInfo.serial						(esi + 88)		; serial is 32 bytes





; tPartitionInfo, for the partitions list (80 bytes)
%define tPartitionInfo.ATAbasePort				(esi + 00)
%define tPartitionInfo.ATAdevice				(esi + 04)
%define tPartitionInfo.attributes				(esi + 08)
%define tPartitionInfo.startingCHS				(esi + 12)
%define tPartitionInfo.endingCHS				(esi + 16)
%define tPartitionInfo.systemID					(esi + 20)
%define tPartitionInfo.startingLBA				(esi + 24)
%define tPartitionInfo.sectorCount				(esi + 28)
%define tPartitionInfo.driveListNumber			(esi + 32)
%define tPartitionInfo.readSector				(esi + 36)
%define tPartitionInfo.writeSector				(esi + 40)
%define tPartitionInfo.fileLoad					(esi + 44)
%define tPartitionInfo.fileSave					(esi + 48)





; tTaskInfo struct, used to... *GASP* manage tasks (96 bytes)
%define tTaskInfo.pageDirAddress				(esi + 00)
%define tTaskInfo.entryPoint					(esi + 04)
%define tTaskInfo.esp							(esi + 08)
%define tTaskInfo.esp0							(esi + 12)
%define tTaskInfo.stackAddress					(esi + 16)
%define tTaskInfo.kernelStackAddress			(esi + 20)
%define tTaskInfo.priority						(esi + 24)
%define tTaskInfo.turnsRemaining				(esi + 25)
%define tTaskInfo.unused						(esi + 26)
%define tTaskInfo.switchInLow					(esi + 28)
%define tTaskInfo.switchInHigh					(esi + 32)
%define tTaskInfo.cycleCountLow					(esi + 36)
%define tTaskInfo.cycleCountHigh				(esi + 40)
%define tTaskInfo.spawnedBy						(esi + 44)
%define tTaskInfo.taskFlags						(esi + 48)
%define tTaskInfo.name							(esi + 64)		; name field is 16 bytes (for now, may need to expand)



; random infos follow...

; Event Codes (needs addressed)
; Note - Event codes 80 - FF are reserved for software and interprocess communication
; 00				Null (nothing is waiting in the queue)
; 01				Key down
; 02				Key up
; 03				Mouse move
; 04				Mouse button down
; 05				Mouse button up
; 06				Mouse wheel move
; 20				Serial input received
; 40				Application is losing focus
; 41				Application is gaining focus

; Maximum kernel size loadable by FreeDOS loader: 137285 bytes. Yes, I tested it.
