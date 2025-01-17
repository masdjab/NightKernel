; Night Kernel
; Copyright 2015 - 2019 by Mercury 0x0D
; CMOS.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.





bits 32





section .text
CMOSRead:
	; Reads the value of a CMOS register while maintaining proper setting of the NMI bit
	;
	;  input:
	;	Register number (8 bits)
	;
	;  output:
	;	EAX - Register value (8 bits)

	push ebp
	mov ebp, esp


	; send register number
	mov dx, 0x70
	mov eax, [ebp + 8]
	or al, 10000000b
	out dx, al

	; read the register 
	mov dx, 0x71
	in al, dx


	mov esp, ebp
	pop ebp
ret 4





section .text
CMOSWrite:
	; Writes the value of a CMOS register while maintaining proper setting of the NMI bit
	;
	;  input:
	;	Register number (8 bits)
	;	Value to write (8 bits)
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp


	; send register number
	mov dx, 0x70
	mov eax, [ebp + 8]
	or al, 10000000b
	out dx, al

	; write the register 
	mov dx, 0x71
	mov eax, [ebp + 12]
	out dx, al


	mov esp, ebp
	pop ebp
ret 8
