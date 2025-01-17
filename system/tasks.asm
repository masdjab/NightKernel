; Night Kernel
; Copyright 2015 - 2019 by Mercury 0x0D
; tasks.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.

; Special thanks to Brendan over at the OSDev forums for his posts (https://forum.osdev.org/viewtopic.php?f=1&t=10883)
; which beautifully explain the intricacies of software task switching!





bits 32





section .text
TaskInit:
	; Initializes the Task Manager routines
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	; the task list will be 256 entries of 96 bytes each (the size of a single tTaskInfo element)
	; 256 * 96 + 16 = 24592
	; allocate memory for the list
	push 24592
	push dword 1
	call MemAllocate
	mov [tSystem.listTasks], eax

	; set up the list header
	push 96
	push 256
	push eax
	call LMListInit

	; Use up slots 0 and 1 so that they won't get assigned to tasks. Why do this? It all goes back to the fact that a task number
	; of zero tells the Memory Manager that the memory block is empty, and task number 1 is the kernel itself.
	push 0
	push dword [tSystem.listTasks]
	call LMElementAddressGet
	mov [esi], dword 0xFFFFFFFF

	push 1
	push dword [tSystem.listTasks]
	call LMElementAddressGet
	mov [esi], dword 0xFFFFFFFF

	; tell the CPU where the TSS is
	mov ax, 0x002B
	ltr ax


	mov esp, ebp
	pop ebp
ret





section .text
TaskKill:
	; Kills the specified task
	;
	;  input:
	;	Task number
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	; See if we're trying to kill task 1 and exit if so. Killing task 1 isn't so bad per se, since it isn't technically used for anything,
	; but doing so would free all memory which was marked as in use by task 1. Since task 1 is the number used by the kernel itself,
	; spontaneously releasing all of its memory is a Certified Very Bad Thing.
	cmp dword [ebp + 8], 1
	je .Done

	; preserve multitasking state
	mov al, byte [tSystem.taskingEnable]
	push eax

	; disable multitasking; we don't want the task to attempt to run while being killed!
	mov byte [tSystem.taskingEnable], 0

	; get the slot address of the task specified
	push dword [ebp + 8]
	push dword [tSystem.listTasks]
	call LMElementAddressGet

	; zero out this task's memory slot
	push 0x00000000
	push dword 96
	push esi
	call MemFill

	; and finally, we check to see if this task was the one that's currently running
	; if it is, we also need to clear out the currently running task info
	mov eax, dword [ebp + 8]
	cmp al, byte [tSystem.currentTask]
	jne .SkipClearing
		mov dword [tSystem.currentTask], 0
		mov dword [tSystem.currentTaskSlotAddress], 0
	.SkipClearing:

	; release all memory blocks in use by this task
	push dword [ebp + 8]
	call TaskMemDisposeAll

	; put multitasking back as it was
	pop eax
	mov byte [tSystem.taskingEnable], al

	.Done:
	mov esp, ebp
	pop ebp
ret 4





section .text
TaskMemDisposeAll:
	; Disposes of all memory allocated by the task number specified
	;
	;  input:
	;	Task number
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 4
	%define slotCounter							dword [ebp - 4]


	push dword [tSystem.listMemory]
	call LM_Internal_ElementCountGet

	; set up a loop to step through every element of the memory list
	.DisposeLoop:
		; save the loop counter
		mov slotCounter, ecx

		push slotCounter
		push dword [tSystem.listMemory]
		call LM_Internal_ElementAddressGet

		mov eax, dword [ebp + 8]
		cmp dword [tMemInfo.task], eax
		jne .SkipDispose
			; if we get here, disposing is needed
			push dword [tMemInfo.address]
			call MemDispose
		.SkipDispose:

	mov ecx, slotCounter
	loop .DisposeLoop


	mov esp, ebp
	pop ebp
ret 4





section .text
TaskNameSet:
	; Sets the name field of the specified task
	;
	;  input:
	;	Task number
	;	Pointer to name string
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 8
	%define strLength							dword [ebp - 4]
	%define taskSlotAddress						dword [ebp - 8]


	; make sure the task number is valid and get its slot address
	mov eax, dword [ebp + 8]
	and eax, 0x000000FF
	push eax
	push dword [tSystem.listTasks]
	call LM_Internal_ElementAddressGet
	mov taskSlotAddress, esi

	; get and save the length of the string specified
	push dword [ebp + 12]
	call StringLength
	mov strLength, eax

	; handle long name strings (only copy the first 31 chars)
	cmp strLength, 31
	jbe .SkipLengthAdjust
		mov strLength, 31
	.SkipLengthAdjust:

	; do the copy!
	push strLength
	mov esi, taskSlotAddress
	add esi, 64
	push esi
	push dword [ebp + 12]
	call MemCopy


	mov esp, ebp
	pop ebp
ret 8





section .text
TaskNew:
	; Sets up a new task for running
	;
	;  input:
	;	Entry point of new task
	;	EFlags register for this task
	;
	;  output:
	;	EAX - Task number

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 16
	%define taskListSlot						dword [ebp - 4]
	%define taskListSlotAddress					dword [ebp - 8]
	%define codeSegment							dword [ebp - 12]
	%define dataSegment							dword [ebp - 16]


	; populate variables
	mov codeSegment, 0x1B
	mov dataSegment, 0x23

	; get first free slot in the task list
	push dword [tSystem.listTasks]
	call LMSlotFindFirstFree
	mov taskListSlot, eax

	; get the starting address of that specific slot into esi
	push eax
	push dword [tSystem.listTasks]
	call LMElementAddressGet
	mov taskListSlotAddress, esi

	; set entry point (starting EIP)
	mov eax, dword [ebp + 8]
	mov [tTaskInfo.entryPoint], eax

	; store the current task, to keep track of who spawns who
	mov eax, [tSystem.currentTask]
	mov [tTaskInfo.spawnedBy], eax


	; set up paging for this task's memory space


	; allocate some memory for this task's stack
	; Intel *strongly* recommends aligning a 32-bit stack on a 32-bit boundary, so we allocate aligned to 4 bytes
	push dword 4
	push dword [tSystem.taskStackSize]
	push taskListSlot
	call MemAllocateAligned
	mov esi, taskListSlotAddress
	mov [tTaskInfo.stackAddress], eax

	; adjust this stack address to point to the other end of the stack, as the CPU will expect
	add eax, dword [tSystem.taskStackSize]
	mov [tTaskInfo.esp], eax

	; allocate some memory for this task's kernel stack
	; the task number is this task's slot number
	push dword 4
	push dword [tSystem.taskKernelStackSize]
	push taskListSlot
	call MemAllocateAligned
	mov esi, taskListSlotAddress
	mov [tTaskInfo.kernelStackAddress], eax

	; adjust the stack address to point to the other end of the stack, as we did with the other stack a moment ago
	; except this time, we don't save it just yet since we will be writing to that stack now
	add eax, dword [tSystem.taskKernelStackSize]

	; save our current stack pointer first before building this task's stack
	mov edx, esp

	; set the new stack address
	mov esp, eax

	; if this is a v86 task, we need to push the segment registers here
	mov eax, [ebp + 12]
	and eax, 00000000000000100000000000000000b
	cmp eax, 00000000000000100000000000000000b
	jne .NotV86
		; the V86 flag was set, so push some extra values (GS, FS, DS, ES)
		push dword 0x0000
		push dword 0x0000
		push dword 0x0000
		push dword 0x0000
		mov codeSegment, 0x00
		mov dataSegment, 0x00
		bts dword [tTaskInfo.taskFlags], 2
	.NotV86:

	; push the data segment for SS and user stack address
	push dataSegment
	push dword [tTaskInfo.esp]

	; force certain bits of the passed EFLAGS register for this task:
	; Bit 1			Reserved			Always set
	; Bit 9			Interrupt Flag		Enabled
	; Bits 11-12	IOPL				3
	mov eax, [ebp + 12]
	or eax, dword 00000000000000000011001000000010b
	push eax

	; push the cs register this task will use (0x18 + lower two bits set to indicate RPL 3 = 0x1B)
	push codeSegment

	; push the eip register this task will use
	push dword [ebp + 8]

	; push nulls for EAX, EBX, ECX, EDX, ESI, EDI, and EBP
	push 0x00000000
	push 0x00000000
	push 0x00000000
	push 0x00000000
	push 0x00000000
	push 0x00000000
	push 0x00000000

	; now save the current esp for this task
	mov [tTaskInfo.esp0], esp

	; restore our original stack
	mov esp, edx

	; return the task number
	mov eax, taskListSlot


	mov esp, ebp
	pop ebp
ret 8





section .text
TaskSwitch:
	; Performs a context switch to the next task
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a


	; see if tasking is disabled, skip context switching if so
	cmp byte [tSystem.taskingEnable], 0
	je .SkipTaskSwitch


	; if currentTask is 0, that means the first task switch hasn't yet happened or the task that was running got killed
	; in either case, we do not need to save task info
	cmp dword [tSystem.currentTask], 0
	je .SkipSaveState

		; ok, since we got here, we may need to task switch - let's take a look at this task's priority
		push esi
		mov esi, dword [tSystem.currentTaskSlotAddress]
		cmp byte [tTaskInfo.turnsRemaining], 0
		pop esi
		je .SkipPriorityAdjust
			; do the priority maths
			push esi
			mov esi, dword [tSystem.currentTaskSlotAddress]
			dec byte [tTaskInfo.turnsRemaining]
			pop esi

			; reset DS
			push 0x23
			pop ds

			jmp .SkipTaskSwitch
		.SkipPriorityAdjust:


		; once we get here, we know we're definitely switching tasks; save the registers of this task to its stack
		push eax
		push ebx
		push ecx
		push edx
		push esi
		push edi
		push ebp

		; load up the pointer to this task's list slot
		mov esi, dword [tSystem.currentTaskSlotAddress]

		; calculate and save the total cycle count this task used while it held the reins
		rdtsc
		mov ebx, dword [tTaskInfo.switchInLow]
		mov ecx, dword [tTaskInfo.switchInHigh]
		sub eax, ebx
		sbb edx, ecx
		mov dword [tTaskInfo.cycleCountLow], eax
		mov dword [tTaskInfo.cycleCountHigh], edx

		; save the kernel stack pointer
		mov [tTaskInfo.esp0], esp

		; reload the priority value
		mov al, byte [tTaskInfo.priority]
		mov byte [tTaskInfo.turnsRemaining], al


	.SkipSaveState:
	; Set up a loop to determine the next task to which we should switch. We simply step through every task's ESP
	; value until we get one that's non-zero, then use it.
	mov ebx, dword [tSystem.currentTask]
	mov edi, dword [tSystem.listTasks]
	.findNextTaskLoop:
		; increment the task number using the low byte only to make sure we stay under 255
		inc bl

		; calculate the address of this task's slot in the Task List
		; start with the size of a single tTaskInfo element in EAX
		mov eax, 96
		mul ebx
		lea esi, [eax + edi + 16]

		; see if we have a kernel stack pointer that's not zero
		cmp dword [tTaskInfo.esp0], 0
		je .findNextTaskLoop

		; see if the task is suspended
		bt dword [tTaskInfo.taskFlags], 1
	jc .findNextTaskLoop

	; by the time we get here, we know what task to execute next

	; update the system globals for this task
	mov dword [tSystem.currentTaskSlotAddress], esi
	mov dword [tSystem.currentTask], ebx
	
	; record the 64-bit TSC
	rdtsc
	mov dword [tTaskInfo.switchInLow], eax
	mov dword [tTaskInfo.switchInHigh], edx

	; switch to the kernel stack of the new task
	mov ecx, dword [tTaskInfo.esp0]
	mov esp, ecx

	; adjust ECX to point to the base of the stack for future use
	bt dword [tTaskInfo.taskFlags], 2
	jnc .NotV86
		add ecx, 16
	.NotV86:
	add ecx, 48
	mov dword [tss.esp0], ecx

	; If this is not a V86 Task, reset the segment registers.
	; If it is, we do nothing since the CPU will automatically pop them off the stack.
	bt dword [tTaskInfo.taskFlags], 2
	jc .LoadStateV86
		mov ax, 0x23
		mov ds, ax
		mov es, ax 
		mov fs, ax 
		mov gs, ax
	.LoadStateV86:

	; pop all general purpose registers off the stack
	pop ebp
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax

	.SkipTaskSwitch:
iret





section .data
tss:
.back_link						dd 0x00000000
.esp0							dd 0x00000000
.ss0							dd 0x00000010
.esp1							dd 0x00000000
.ss1							dd 0x00000000
.esp2							dd 0x00000000
.ss2							dd 0x00000000
.cr3							dd 0x00000000
.eip							dd 0x00000000
.eflags							dd 0x00000000
.eax							dd 0x00000000
.ecx							dd 0x00000000
.edx							dd 0x00000000
.ebx							dd 0x00000000
.esp							dd 0x00000000
.ebp							dd 0x00000000
.esi							dd 0x00000000
.edi							dd 0x00000000
.es								dd 0x00000000
.cs								dd 0x00000000
.ss								dd 0x00000000
.ds								dd 0x00000000
.fs								dd 0x00000000
.gs								dd 0x00000000
.ldt							dd 0x00000000
.trap							dw 0x0000
.iomap_base						dw 0x0000
.end:





; privileged instructions
; CLTS				Clear Task Switch Flag in Control Register CR0
; HLT				Halt Processor
; INVD				Invalidate Cache without writeback
; INVLPG			Invalidate TLB Entry
; LGDT				Loads an address of a GDT into GDTR
; LLDT				Loads an address of a LDT into LDTR
; LMSW				Load a new Machine Status WORD
; LTR				Loads a Task Register into TR
; MOV				Control Register	Copy data and store in Control Registers
; MOV 				Debug Register	Copy data and store in debug registers
; RDMSR				Read Model Specific Registers (MSR)
; RDPMC				Read Performance Monitoring Counter
; RDTSC				Read time Stamp Counter
; WBINVD			Invalidate Cache with writeback
; WRMSR				Write Model Specific Registers (MSR)

; 0f 06                   clts
; 0f 08                   invd
; 0f 01 38                invlpg byte [eax]
; 0f 01 10                lgdt [eax]
; 0f 00 10                lldt [eax]
; 0f 01 30                lmsw [eax]
; 0f 00 18                ltr [eax]
; 0f 32                   rdmsr
; 0f 33                   rdpmc
; 0f 31                   rdtsc
; 0f 09                   wbinvd
; 0f 30                   wrmsr

; 0f 01 3b                invlpg byte [ebx]
; 0f 01 13                lgdt [ebx]
; 0f 00 13                lldt [ebx]
; 0f 01 33                lmsw [ebx]
