; Night Kernel
; Copyright 2015 - 2019 by Mercury 0x0D
; strings.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.





; globals
section .data
kHexDigits										db '0123456789ABCDEF'





bits 16





section .text
ConvertByteToHexString16:
	; Translates the byte value specified to a hexadecimal number in a zero-padded 2 byte string in real mode
	;
	;  input:
	;	Numeric byte value
	;	String address
	;
	;  output:
	;	n/a

	push bp
	mov bp, sp

	mov si, [bp + 4]
	mov di, [bp + 6]

	; handle digit 1
	mov cx, 0x00F0
	and cx, si
	shr cx, 4
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al
	inc di

	mov si, [bp + 4]

	; handle digit 2
	mov cx, 0x000F
	and cx, si
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al

	mov sp, bp
	pop bp
ret 4





section .text
ConvertWordToHexString16:
	; Translates the word value specified to a hexadecimal number in a zero-padded 4 byte string in real mode
	;
	;  input:
	;	Numeric word value
	;	String address
	;
	;  output:
	;	n/a

	push bp
	mov bp, sp

	mov si, [bp + 4]
	mov di, [bp + 6]


	; handle digit 1
	mov cx, 0xF000
	and cx, si
	shr cx, 12
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al
	inc di

	mov si, [bp + 4]

	; handle digit 2
	mov cx, 0x0F00
	and cx, si
	shr cx, 8
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al
	inc di

	mov si, [bp + 4]

	; handle digit 3
	mov cx, 0x00F0
	and cx, si
	shr cx, 4
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al
	inc di
	
	mov si, [bp + 4]
	
	; handle digit 4
	mov cx, 0x000F
	and cx, si
	add cx, kHexDigits
	mov si, cx
	mov al, [si]
	mov byte[di], al
	inc di

	mov sp, bp
	pop bp
ret 4





bits 32





section .text
ConvertNumberBinaryToString:
	; Translates the value specified to a binary number in a zero-padded 32 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	; Note: No terminating null is put on the end of the string - do that yourself.
	;
	;  input:
	;	Numeric value
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov eax, [ebp + 8]
	mov esi, [ebp + 12]

	; clear the string to all zeroes
	pusha
	push 48
	push 32
	push esi
	call MemFill
	popa

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 31

	; set the divisor
	mov ebx, 2
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
		jmp .DecodeLoop												; else repeat
	.Exit:

	mov esp, ebp
	pop ebp
ret 8





section .text
ConvertNumberDecimalToString:
	; Translates the value specified to a decimal number in a zero-padded 10 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	; Note: No terminating null is put on the end of the string - do that yourself.
	;
	;  input:
	;	Numeric value
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov eax, [ebp + 8]
	mov esi, [ebp + 12]

	; clear the string to all zeroes
	pusha
	push 48
	push 10
	push esi
	call MemFill
	popa

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 9
	
	; set the divisor
	mov ebx, 10
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
		jmp .DecodeLoop												; else repeat
	.Exit:

	mov esp, ebp
	pop ebp
ret 8





section .text
ConvertNumberHexToString:
	; Translates the value specified to a hexadecimal number in a zero-padded 8 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	; Note: No terminating null is put on the end of the string - do that yourself.
	;
	;  input:
	;	Numeric value
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov esi, [ebp + 8]
	mov edi, [ebp + 12]

	mov ecx, 0xF0000000
	and ecx, esi
	shr ecx, 28
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x0F000000
	and ecx, esi
	shr ecx, 24
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x00F00000
	and ecx, esi
	shr ecx, 20
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x000F0000
	and ecx, esi
	shr ecx, 16
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x0000F000
	and ecx, esi
	shr ecx, 12
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x00000F00
	and ecx, esi
	shr ecx, 8
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x000000F0
	and ecx, esi
	shr ecx, 4
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov ecx, 0x0000000F
	and ecx, esi
	add ecx, kHexDigits
	mov al, [ecx]
	mov byte[edi], al
	inc edi

	mov esp, ebp
	pop ebp
ret 8





section .text
ConvertNumberOctalToString:
	; Translates the value specified to an octal number in a zero-padded 11 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	; Note: No terminating null is put on the end of the string - do that yourself.
	;
	;  input:
	;	Numeric value
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov eax, [ebp + 8]
	mov esi, [ebp + 12]

	; clear the string to all zeroes
	pusha
	push 48
	push 11
	push esi
	call MemFill
	popa

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 10
	
	; set the divisor
	mov ebx, 8
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
	jmp .DecodeLoop													; else repeat


	.Exit:
	mov esp, ebp
	pop ebp
ret 8





section .text
ConvertStringBinaryToNumber:
	; Returns the numeric value from the binary string specified
	;
	;  input:
	;	String address
	;
	;  output:
	;	EAX - Numeric value

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 12
	%define strLen								dword [ebp - 4]
	%define accumulator							dword [ebp - 8]
	%define magnitude							dword [ebp - 12]


	; get the string length
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; leave if the string is longer than 32 characters
	cmp strLen, 32
	jg .Error

	; leave if the string is zero characters
	cmp strLen, 0
	je .Error

	; init the vars
	mov accumulator, 0
	mov magnitude, 1

	; loop to process all the characters of the string
	mov ecx, strLen
	.DecodeLoop:

		; get the last character of the string
		mov esi, dword [ebp + 8]
		add esi, ecx
		dec esi
		mov eax, 0x00000000
		mov al, byte [esi]


		; set BL appropriately if the character is 0 - 1
		cmp al, 48
		jb .Done

		cmp al, 49
		ja .Done

		mov bl, 48


		; calculate the actual value of the nibble we got
		sub al, bl

		; multiply the value by the current magnitude and add to the accumulator
		mov ebx, magnitude
		mov edx, 0x00000000
		mul ebx
		add accumulator, eax

		; multiply magnitude by the base of this numbering system
		shl magnitude, 1

	loop .DecodeLoop
	jmp .Done


	.Error:
	mov accumulator, 0


	.Done:
	mov eax, accumulator

	mov esp, ebp
	pop ebp
ret 4





section .text
ConvertStringDecimalToNumber:
	; Returns the numeric value from the decimal string specified
	;
	;  input:
	;	String address
	;
	;  output:
	;	EAX - Numeric value

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 12
	%define strLen								dword [ebp - 4]
	%define accumulator							dword [ebp - 8]
	%define magnitude							dword [ebp - 12]


	; get the string length
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; leave if the string is longer than 10 characters
	cmp strLen, 10
	jg .Error

	; leave if the string is zero characters
	cmp strLen, 0
	je .Error

	; init the vars
	mov accumulator, 0
	mov magnitude, 1

	; loop to process all the characters of the string
	mov ecx, strLen
	.DecodeLoop:

		; get the last character of the string
		mov esi, dword [ebp + 8]
		add esi, ecx
		dec esi
		mov eax, 0x00000000
		mov al, byte [esi]


		; set BL appropriately if the character is 0 - 9
		cmp al, 48
		jb .Done

		cmp al, 57
		ja .Done

		mov bl, 48


		; calculate the actual value of the nibble we got
		sub al, bl

		; multiply the value by the current magnitude and add to the accumulator
		mov ebx, magnitude
		mov edx, 0x00000000
		mul ebx
		add accumulator, eax

		; multiply magnitude by the base of this numbering system
		mov eax, magnitude
		shl magnitude, 3
		add magnitude, eax
		add magnitude, eax

	loop .DecodeLoop
	jmp .Done


	.Error:
	mov accumulator, 0


	.Done:
	mov eax, accumulator

	mov esp, ebp
	pop ebp
ret 4





section .text
ConvertStringHexToNumber:
	; Returns the numeric value from the hexadecimal string specified
	;
	;  input:
	;	String address
	;
	;  output:
	;	EAX - Numeric value

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 12
	%define strLen								dword [ebp - 4]
	%define accumulator							dword [ebp - 8]
	%define magnitude							dword [ebp - 12]


	; get the string length
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; leave if the string is longer than 8 characters
	cmp strLen, 8
	jg .Error

	; leave if the string is zero characters
	cmp strLen, 0
	je .Error

	; init the vars
	mov accumulator, 0
	mov magnitude, 1

	; loop to process all the characters of the string
	mov ecx, strLen
	.DecodeLoop:

		; get the last character of the string
		mov esi, dword [ebp + 8]
		add esi, ecx
		dec esi
		mov eax, 0x00000000
		mov al, byte [esi]


		; set BL appropriately if the character is 0 - 9
		cmp al, 48
		jb .UppercaseTest

		cmp al, 57
		ja .UppercaseTest

		mov bl, 48
		jmp .ProcessDigit


		.UppercaseTest:
		; set BL appropriately if the character is A - F
		cmp al, 65
		jb .LowercaseTest

		cmp al, 70
		ja .LowercaseTest

		mov bl, 55
		jmp .ProcessDigit


		.LowercaseTest:
		; set BL appropriately if the character is a - f
		cmp al, 97
		jb .Done

		cmp al, 102
		ja .Done

		mov bl, 87


		.ProcessDigit:
		; calculate the actual value of the nibble we got
		sub al, bl

		; multiply the value by the current magnitude and add to the accumulator
		mov ebx, magnitude
		mov edx, 0x00000000
		mul ebx
		add accumulator, eax

		; multiply magnitude by the base of this numbering system
		shl magnitude, 4

	loop .DecodeLoop
	jmp .Done


	.Error:
	mov accumulator, 0

	
	.Done:
	mov eax, accumulator

	mov esp, ebp
	pop ebp
ret 4





section .text
ConvertStringOctalToNumber:
	; Returns the numeric value from the octal string specified
	;
	;  input:
	;	String address
	;
	;  output:
	;	EAX - Numeric value

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 12
	%define strLen								dword [ebp - 4]
	%define accumulator							dword [ebp - 8]
	%define magnitude							dword [ebp - 12]


	; get the string length
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; leave if the string is longer than 11 characters
	cmp strLen, 11
	jg .Error

	; leave if the string is zero characters
	cmp strLen, 0
	je .Error

	; init the vars
	mov accumulator, 0
	mov magnitude, 1

	; loop to process all the characters of the string
	mov ecx, strLen
	.DecodeLoop:

		; get the last character of the string
		mov esi, dword [ebp + 8]
		add esi, ecx
		dec esi
		mov eax, 0x00000000
		mov al, byte [esi]


		; set BL appropriately if the character is 0 - 8
		cmp al, 48
		jb .Done

		cmp al, 56
		ja .Done

		mov bl, 48


		; calculate the actual value of the nibble we got
		sub al, bl

		; multiply the value by the current magnitude and add to the accumulator
		mov ebx, magnitude
		mov edx, 0x00000000
		mul ebx
		add accumulator, eax

		; multiply magnitude by the base of this numbering system
		shl magnitude, 3

	loop .DecodeLoop
	jmp .Done


	.Error:
	mov accumulator, 0

	
	.Done:
	mov eax, accumulator

	mov esp, ebp
	pop ebp
ret 4





section .text
StringCaseLower:
	; Converts a string to lower case
	;
	;  input:
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov ecx, [ebp + 8]

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, 65
		jb .NotInRange

		cmp al, 90
		ja .NotInRange

		; if we get here, it was in range, so we drop it to lower case
		add al, 32
		mov [ecx], al

		.NotInRange:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:

	mov esp, ebp
	pop ebp
ret 4





section .text
StringCaseUpper:
	; Converts a string to upper case
	;
	;  input:
	;	String address
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov ecx, [ebp + 8]

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, 97
		jb .NotInRange

		cmp al, 122
		ja .NotInRange

		; if we get here, it was in range, so we raise it to upper case
		sub al, 32
		mov [ecx], al

		.NotInRange:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:

	mov esp, ebp
	pop ebp
ret 4





section .text
StringCharAppend:
	; Appends a character onto the end of the string specified
	;
	;  input:
	;	String address
	;	ASCII code of character to add
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; get the length of the string passed
	push dword [ebp + 8]
	call StringLength
	mov edi, eax
	add edi, [ebp + 8]

	; write the ASCII character
	mov eax, [ebp + 12]
	stosb

	; write a null to terminate the string
	mov al, 0
	stosb

	mov esp, ebp
	pop ebp
ret 8





section .text
StringCharDelete:
	; Deletes the character at the location specified from the string
	;
	;  input:
	;	String address
	;	Character position to remove
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov ecx, [ebp + 8]
	mov edx, [ebp + 12]

	; test for null string for efficiency
	mov byte al, [ecx]
	cmp al, 0x00
	je .StringTrimDone

	; calculate source string position
	add ecx, edx

	; calculate the destination position
	mov edx, ecx
	dec edx

	.StringShiftLoop:
		; load a char from the source position
		mov al, [ecx]
		mov [edx], al

		; test if this is the end of the string
		cmp al, 0x00
		je .StringTrimDone

		; that wasn't the end, so we increment the pointers and do the next character
		inc edx
		inc ecx
	jmp .StringShiftLoop
	.StringTrimDone:

	mov esp, ebp
	pop ebp
ret 8





section .text
StringCharPrepend:
	; Prepends a character onto the beginning of the string specified
	;
	;  input:
	;	String address
	;	ASCII code of character to add
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	; get the length of the string passed
	push dword [ebp + 8]
	call StringLength
	mov ecx, eax
	
	; set up our string loop addresses
	mov esi, [ebp + 8]
	add esi, ecx
	mov edi, esi
	inc edi

	; loop to shift bytes down by the number of characters being inserted, plus one to allow for the null
	mov ecx, dword [ebp - 4]
	inc ecx
	pushf
	std
	.ShiftLoop:
		lodsb
		stosb
	loop .ShiftLoop
	popf

	; write the ASCII character
	mov eax, [ebp + 12]
	stosb


	mov esp, ebp
	pop ebp
ret 8





section .text
StringFill:
	; Fills the entire string specified with the character specified
	;
	;  input:
	;	String address
	;	Fill character
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	mov ecx, [ebp + 8]
	mov ebx, [ebp + 12]

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		mov [ecx], bl

		inc ecx
	jmp .StringLoop
	.StringLoopDone:


	mov esp, ebp
	pop ebp
ret 8





section .text
StringInsert:
	; Inserts a string into another string at the location specified
	;
	;  input:
	;	Address of main string
	;	Address of string to be inserted
	;	Position after which to insert the string
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 8
	%define mainLength							dword [ebp - 4]
	%define insertLength						dword [ebp - 8]


	; get the length of the main string
	push dword [ebp + 8]
	call StringLength
	mov mainLength, eax


	; check insert position; writing AT the end of the string is okay, PAST it is not
	mov ebx, dword [ebp + 16]

	cmp ebx, mainLength
	jbe .CheckOK
	; if we get here the insert position is invalid, so we exit
	jmp .Exit
	.CheckOK:

	; get the length of the insert string
	push dword [ebp + 12]
	call StringLength
	mov insertLength, eax


	; load up some registers for speed
	mov ecx, dword [ebp + 8]
	mov edx, dword [ebp + 12]
	mov ebx, dword [ebp + 16]


	; set up a value to use later to check if the loop is over
	mov edx, ecx
	add edx, ebx

	; calculate address of the first byte in the section of chars to be shifted down
	mov eax, mainLength
	add ecx, eax

	; calculate the address of the last byte of the resulting string
	mov edi, ecx
	add edi, [ebp - 8]

	.StringShiftLoop:
		; copy a byte from source to destination
		mov al, [ecx]
		mov [edi], al

		; test if we have reached the insert position
		cmp edx, edi
		je .StringTrimDone

		; that wasn't the end, so we increment the pointers and do the next character
		dec edi
		dec ecx
	jmp .StringShiftLoop

	; now that we've made room for it, we can proceed to write the insert string into the main string

	.StringTrimDone:
	; calculate the write address based on the location specified
	mov ecx, [ebp + 8]
	add ecx, ebx

	; get the address of the insert string
	mov edx, [ebp + 12]

	.StringWriteLoop:
		; get a byte from the insert string
		mov al, [edx]
		
		; see if it's null
		cmp al, 0x00
		
		; if so, jump out of the loop - we're done!
		je .Exit

		; if we get here, it's not the end yet
		mov [ecx], al

		; increment the pointers and start over
		inc edx
		inc ecx
	jmp .StringWriteLoop


	.Exit:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringLength:
	; Returns the length of the string specified
	;
	;  input:
	;	String starting address
	;
	;  output:
	;	EAX - String length

	push ebp
	mov ebp, esp


	mov edi, [ebp + 8]

	; set up the string scan
	mov ecx, 0xFFFFFFFF
	mov esi, edi
	mov al, 0
	repne scasb
	sub edi, esi
	dec edi

	; put the result into EAX and exit
	mov eax, edi


	mov esp, ebp
	pop ebp
ret 4





section .text
StringPadLeft:
	; Pads the left side of the string specified with the character specified until it is the length specified
	;
	;  input:
	;	String address
	;	Padding character
	;	Length to which the string will be extended
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 4
	%define strLen								dword [ebp - 4]


	; get the length of the string
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; exit if the string specified is already greater than the length given
	mov eax, dword [ebp + 16]
	mov ebx, strLen
	cmp ebx, eax
	jae .Exit

	; calculate number of characters we need to add into eax and save it for later
	sub eax, strLen
	push eax

	; calculate source and dest addresses
	mov esi, dword [ebp + 8]
	add esi, strLen
	mov edi, esi
	add edi, eax

	; loop to shift bytes down by the number of characters being inserted, plus one to allow for the null
	mov ecx, strLen
	inc ecx
	pushf
	std

	.ShiftLoop:
		lodsb
		stosb
	loop .ShiftLoop
	popf

	; MemFill the characters onto the beginning of the string
	pop eax
	push dword [ebp + 12]
	push eax
	push dword [ebp + 8]
	call MemFill


	.Exit:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringPadRight:
	; Pads the right side of the string specified with the character specified until it is the length specified
	;
	;  input:
	;	String address
	;	Padding character
	;	Length to which string will be extended
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	; allocate local variables
	sub esp, 4
	%define strLen								dword [ebp - 4]


	; get the length of the string
	push dword [ebp + 8]
	call StringLength
	mov strLen, eax

	; exit if the string specified is already greater than the length given
	mov eax, dword [ebp + 16]
	mov ebx, strLen
	cmp ebx, eax
	jae .Exit

	; calculate number of characters we need to add into eax
	sub eax, strLen

	; calculate write address and save for later
	mov ebx, dword [ebp + 8]
	add ebx, strLen
	push ebx

	; MemFill the characters onto the end of the string
	push dword [ebp + 12]
	push eax
	push ebx
	call MemFill

	; write the null terminator
	pop ebx
	add ebx, dword [ebp + 16]
	mov byte [ebx], 0


	.Exit:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringReplaceChars:
	; Replaces all occurrances of the specified character with another character specified
	;
	;  input:
	;	String address
	;	Character to be replaced
	;	Replacement character
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	mov ecx, [ebp + 8]
	mov ebx, [ebp + 12]
	mov edx, [ebp + 16]

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, bl
		jne .NoMatch

		; if we get here, it was in range, so replace it
		mov [ecx], dl

		.NoMatch:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:


	mov esp, ebp
	pop ebp
ret 12





section .text
StringReplaceCharsInRange:
	; Replaces any character within the range of ASCII codes specified with the specified character
	;
	;  input:
	;	String address
	;	Start of ASCII range
	;	End of ASCII range
	;	Replacement character
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	mov ecx, [ebp + 8]
	mov eax, [ebp + 12]
	mov ebx, [ebp + 16]
	mov edx, [ebp + 20]

	mov bh, al

	; see if the range numbers are backwards and swap them if necessary
	cmp bh, bl
	jl .StringLoop
	xchg bh, bl

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .Exit

		cmp al, bh
		jb .NotInRange

		cmp al, bl
		ja .NotInRange

		; if we get here, it was in range, so replace it
		mov [ecx], dl

		.NotInRange:
		inc ecx
	jmp .StringLoop


	.Exit:
	mov esp, ebp
	pop ebp
ret 16





section .text
StringSearchChar:
	; Returns the position in the string specified of the character code specified
	;
	;  input:
	;	Address of string to be scanned
	;	ASCII value of byte for which to search
	;
	;  output:
	;	EAX - Position of match, or zero if no match

	push ebp
	mov ebp, esp


	; allocate local variables
	sub esp, 4
	%define stringLen							dword [ebp - 4]


	; get length of the main string
	push dword [ebp + 8]
	call StringLength
	mov ecx, eax


	; exit if the string was null, save eax if not
	cmp ecx, 0
	je .Exit
	mov stringLen, ecx


	; load up for the search
	mov edi, dword [ebp + 8]
	mov eax, dword [ebp + 12]


	; use the (insert echo here) MAGIC OF ASSEMBLY to search for the byte
	repnz scasb


	; if the zero flag is set, a match was found
	; if it's clear, no match was found and ecx will already be 0, so we can simply exit
	jnz .Exit


	; a match was found, so update the position
	sub stringLen, ecx
	mov eax, stringLen


	.Exit:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringSearchCharList:
	; Returns the position in the string specified of the first match from a list of characters
	;
	;  input:
	;	Address of string to be scanned
	;	Address of character list string
	;
	;  output:
	;	EAX - Position of match, or zero if no match

	push ebp
	mov ebp, esp


	; allocate local variables
	sub esp, 12
	%define mainStrLen							dword [ebp - 4]
	%define listStrLen							dword [ebp - 8]
	%define returnValue							dword [ebp - 12]


	; init return value to an absurdly high number 
	mov returnValue, 0xFFFFFFFF

	; get length of the main string
	push dword [ebp + 8]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov mainStrLen, eax

	; get length of the list string
	push dword [ebp + 12]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov listStrLen, eax

	; this loop cycles through all characters of the list string
	mov ecx, listStrLen
	mov esi, [ebp + 12]
	.scanLoop:

		; get a byte from the list string
		mov al, [esi]

		; preserve ecx
		mov ebx, ecx

		; scan the main string for this character
		mov ecx, mainStrLen
		mov edi, [ebp + 8]
		repne scasb

		; if the zero flag is clear, there was a match
		jnz .NextIteration
		
			; subtract the starting address of the string from edi
			; this makes it now refer to the character within the string instead of the byte address
			sub edi, [ebp + 8]

			; compare to see if this value is lower (e.g. "nearer") than the last one
			mov eax, returnValue
			cmp edi, eax
			jnb .NextIteration

			; it was closer, so save this value
			mov returnValue, edi

		.NextIteration:
		; do the next pass through the loop
		mov ecx, ebx
		inc esi
	loop .scanLoop


	.Exit:
	; see if the return value is still 0xFFFFFFFF and make it zero if so
	cmp returnValue, 0xFFFFFFFF
	jne .NoAdjust
	mov returnValue, 0


	.NoAdjust:
	mov eax, returnValue


	mov esp, ebp
	pop ebp
ret 8





section .text
StringTokenBinary:
	; Finds the first occurrance of the ^ character and replaces it with a binary number, truncated to the length specified
	;
	;  input:
	;	String address
	;	Dword value to be added to the string
	;	Number trim value
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 41
	%define tokenPosition						dword [ebp - 4]
	%define bufferAddress						dword [ebp - 8]
	; 33 byte string buffer for number-to-string conversion output is at [ebp - 41]


	; get the length of the formatting string, exit if it's null
	push dword [ebp + 8]
	call StringLength
	cmp eax, 0
	je .Done


	; find the location of the first token character
	push dword 0x0000005E
	push dword [ebp + 8]
	call StringSearchChar
	mov tokenPosition, eax


	; if the token location is 0, then no token was found... so we exit
	cmp tokenPosition, 0
	je .Done


	; calculate the address of our string buffer
	mov eax, ebp
	sub eax, 41
	mov bufferAddress, eax


	; zero the string buffer
	push 0
	push 33
	push bufferAddress
	call MemFill


	; convert the number passed to a string
	push bufferAddress
	push dword [ebp + 12]
	call ConvertNumberBinaryToString


	; trim leading zeroes if necessary
	cmp dword [ebp + 16], 0
	jne .NoTrimLeading
		push dword 0x00000030
		push bufferAddress
		call StringTrimLeft

		; see if the string length is zero and add a single zero back if so
		mov eax, bufferAddress
		mov bl, [eax]
		cmp bl, 0
		jne .SkipAddZero
			mov eax, bufferAddress
			mov byte [eax], 0x30
			inc eax
			mov byte [eax], 0x00
		.SkipAddZero:
		jmp .NoTruncate
	.NoTrimLeading:


	; if the trim value is less than the maximum possible length of the string, then truncate as directed
	cmp dword [ebp + 16], 32
	jae .NoTruncate
		push dword [ebp + 16]
		push bufferAddress
		call StringTruncateLeft
	.NoTruncate:


	; delete the token itself
	push tokenPosition
	push dword [ebp + 8]
	call StringCharDelete


	; insert the string we created into the output string
	dec tokenPosition
	push tokenPosition
	push bufferAddress
	push dword [ebp + 8]
	call StringInsert


	.Done:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringTokenDecimal:
	; Finds the first occurrance of the ^ character and replaces it with a decimal number, truncated to the length specified
	;
	;  input:
	;	String address
	;	Dword value to be added to the string
	;	Number trim value
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 19
	%define tokenPosition						dword [ebp - 4]
	%define bufferAddress						dword [ebp - 8]
	; 11 byte string buffer for number-to-string conversion output is at [ebp - 19]


	; get the length of the formatting string, exit if it's null
	push dword [ebp + 8]
	call StringLength
	cmp eax, 0
	je .Done


	; find the location of the first token character
	push dword 0x0000005E
	push dword [ebp + 8]
	call StringSearchChar
	mov tokenPosition, eax


	; if the token location is 0, then no token was found... so we exit
	cmp tokenPosition, 0
	je .Done


	; calculate the address of our string buffer
	mov eax, ebp
	sub eax, 19
	mov bufferAddress, eax


	; zero the string buffer
	push 0
	push 11
	push bufferAddress
	call MemFill


	; convert the number passed to a string
	push bufferAddress
	push dword [ebp + 12]
	call ConvertNumberDecimalToString


	; trim leading zeroes if necessary
	cmp dword [ebp + 16], 0
	jne .NoTrimLeading
		push dword 0x00000030
		push bufferAddress
		call StringTrimLeft

		; see if the string length is zero and add a single zero back if so
		mov eax, bufferAddress
		mov bl, [eax]
		cmp bl, 0
		jne .SkipAddZero
			mov eax, bufferAddress
			mov byte [eax], 0x30
			inc eax
			mov byte [eax], 0x00
		.SkipAddZero:
		jmp .NoTruncate
	.NoTrimLeading:


	; if the trim value is less than the maximum possible length of the string, then truncate as directed
	cmp dword [ebp + 16], 10
	jae .NoTruncate
		push dword [ebp + 16]
		push bufferAddress
		call StringTruncateLeft
	.NoTruncate:


	; delete the token itself
	push tokenPosition
	push dword [ebp + 8]
	call StringCharDelete


	; insert the string we created into the output string
	dec tokenPosition
	push tokenPosition
	push bufferAddress
	push dword [ebp + 8]
	call StringInsert


	.Done:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringTokenHexadecimal:
	; Finds the first occurrance of the ^ character and replaces it with a hexadecimal number, truncated to the length specified
	;
	;  input:
	;	String address
	;	Dword value to be added to the string
	;	Number trim value
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 17
	%define tokenPosition						dword [ebp - 4]
	%define bufferAddress						dword [ebp - 8]
	; 9 byte string buffer for number-to-string conversion output is at [ebp - 17]


	; get the length of the formatting string, exit if it's null
	push dword [ebp + 8]
	call StringLength
	cmp eax, 0
	je .Done


	; find the location of the first token character
	push dword 0x0000005E
	push dword [ebp + 8]
	call StringSearchChar
	mov tokenPosition, eax


	; if the token location is 0, then no token was found... so we exit
	cmp tokenPosition, 0
	je .Done


	; calculate the address of our string buffer
	mov eax, ebp
	sub eax, 17
	mov bufferAddress, eax


	; zero the string buffer
	push 0
	push 9
	push bufferAddress
	call MemFill


	; convert the number passed to a string
	push bufferAddress
	push dword [ebp + 12]
	call ConvertNumberHexToString


	; trim leading zeroes if necessary
	cmp dword [ebp + 16], 0
	jne .NoTrimLeading
		push dword 0x00000030
		push bufferAddress
		call StringTrimLeft

		; see if the string length is zero and add a single zero back if so
		mov eax, bufferAddress
		mov bl, [eax]
		cmp bl, 0
		jne .SkipAddZero
			mov eax, bufferAddress
			mov byte [eax], 0x30
			inc eax
			mov byte [eax], 0x00
		.SkipAddZero:
		jmp .NoTruncate
	.NoTrimLeading:


	; if the trim value is less than the maximum possible length of the string, then truncate as directed
	cmp dword [ebp + 16], 16
	jae .NoTruncate
		push dword [ebp + 16]
		push bufferAddress
		call StringTruncateLeft
	.NoTruncate:


	; delete the token itself
	push tokenPosition
	push dword [ebp + 8]
	call StringCharDelete


	; insert the string we created into the output string
	dec tokenPosition
	push tokenPosition
	push bufferAddress
	push dword [ebp + 8]
	call StringInsert


	.Done:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringTokenOctal:
	; Finds the first occurrance of the ^ character and replaces it with an octal number, truncated to the length specified
	;
	;  input:
	;	String address
	;	DWord value to be added to the string
	;	Number trim value
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 20
	%define tokenPosition						dword [ebp - 4]
	%define bufferAddress						dword [ebp - 8]
	; 12 byte string buffer for number-to-string conversion output is at [ebp - 20]


	; get the length of the formatting string, exit if it's null
	push dword [ebp + 8]
	call StringLength
	cmp eax, 0
	je .Done


	; find the location of the first token character
	push dword 0x0000005E
	push dword [ebp + 8]
	call StringSearchChar
	mov tokenPosition, eax


	; if the token location is 0, then no token was found... so we exit
	cmp tokenPosition, 0
	je .Done


	; calculate the address of our string buffer
	mov eax, ebp
	sub eax, 20
	mov bufferAddress, eax


	; zero the string buffer
	push 0
	push 12
	push bufferAddress
	call MemFill


	; convert the number passed to a string
	push bufferAddress
	push dword [ebp + 12]
	call ConvertNumberOctalToString


	; trim leading zeroes if necessary
	cmp dword [ebp + 16], 0
	jne .NoTrimLeading
		push dword 0x00000030
		push bufferAddress
		call StringTrimLeft

		; see if the string length is zero and add a single zero back if so
		mov eax, bufferAddress
		mov bl, [eax]
		cmp bl, 0
		jne .SkipAddZero
			mov eax, bufferAddress
			mov byte [eax], 0x30
			inc eax
			mov byte [eax], 0x00
		.SkipAddZero:
		jmp .NoTruncate
	.NoTrimLeading:


	; if the trim value is less than the maximum possible length of the string, then truncate as directed
	cmp dword [ebp + 16], 11
	jae .NoTruncate
		push dword [ebp + 16]
		push bufferAddress
		call StringTruncateLeft
	.NoTruncate:


	; delete the token itself
	push tokenPosition
	push dword [ebp + 8]
	call StringCharDelete


	; insert the string we created into the output string
	dec tokenPosition
	push tokenPosition
	push bufferAddress
	push dword [ebp + 8]
	call StringInsert


	.Done:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringTokenString:
	; Finds the first occurrance of the ^ character and replaces it with the string specified, truncated to the length specified
	;
	;  input:
	;	String address
	;	Address of string to be added
	;	String trim value
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 4
	%define tokenPosition						dword [ebp - 4]


	; get the length of the formatting string, exit if it's null
	push dword [ebp + 8]
	call StringLength
	cmp eax, 0
	je .Done


	; find the location of the first token character
	push dword 0x0000005E
	push dword [ebp + 8]
	call StringSearchChar
	mov tokenPosition, eax


	; if the token location is 0, then no token was found... so we exit
	cmp tokenPosition, 0
	je .Done


	; if the trim value is less than the maximum possible length of the string, then truncate as directed
	cmp dword [ebp + 16], 0
	je .NoTruncate
		push dword [ebp + 16]
		push dword [ebp + 12]
		call StringTruncateLeft
	.NoTruncate:


	; delete the token itself
	push tokenPosition
	push dword [ebp + 8]
	call StringCharDelete


	; insert the string we created into the output string
	dec tokenPosition
	push tokenPosition
	push dword [ebp + 12]
	push dword [ebp + 8]
	call StringInsert


	.Done:
	mov esp, ebp
	pop ebp
ret 12





section .text
StringTrimLeft:
	; Trims any occurrances of the character specified off the left side of the string
	;
	;  input:
	;	String address
	;	ASCII code of the character to be trimmed
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	mov ecx, [ebp + 8]
	mov ebx, [ebp + 12]

	; save the string address for later
	mov edx, ecx

	; see from where we have to start shifting
	.StringLoop:
		mov byte al, [ecx]

		cmp al, bl
		jne .StartShifting

		; if this was the last byte of the string, then exit the loop
		cmp al, 0x00
		je .Done

		inc ecx
	jmp .StringLoop

	.StartShifting:
	; if we get here, the current character wasn't a match, so we can start shifting the characters

	; but first, a test... if ecx = edx then there's no shifting necessary and we can exit right away
	cmp ecx, edx
	je .Done

	.StringShiftLoop:
		; load a char from the source position
		mov al, [ecx]
		mov [edx], al

		; test if this is the end of the string
		cmp al, 0x00
		je .Done

		; that wasn't the end, so we increment the pointers and do the next character
		inc edx
		inc ecx
	jmp .StringShiftLoop


	.Done:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringTrimRight:
	; Trims any occurrances of the character specified off the right side of the string
	;
	;  input:
	;	string address
	;	ASCII code of the character to be trimmed
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp


	mov ecx, [ebp + 8]
	mov ebx, [ebp + 12]

	; get the length of the string and use it to adjust the starting pointer of the string
	push ecx
	call StringLength
	mov ecx, [ebp + 8]
	add ecx, eax
	dec ecx

	mov ebx, [ebp + 12]

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .Done

		cmp al, bl
		jne .Truncate
		dec ecx
	jmp .StringLoop

	.Truncate:
	; adjust the pointer to the position after the last char of the string and insert the null byte
	inc ecx
	mov byte [ecx], 0


	.Done:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringTruncateLeft:
	; Truncates the string to the length specified by trimming characters off the beginning
	;
	;  input:
	;	String address
	;	Length to which the string will be shortened
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 4
	%define strLength							dword [ebp - 4]


	; get the length of the string
	push dword [ebp + 8]
	call StringLength
	mov strLength, eax

	; exit if the string specified is shorter than the length given
	mov eax, dword [ebp + 12]
	mov ebx, strLength
	cmp eax, ebx
	jae .Exit

	; MemCopy the part of the string to be preserved
	; get the source address 
	mov esi, [ebp + 8]
	add esi, ebx
	sub esi, eax

	inc eax
	push eax
	push dword [ebp + 8]
	push esi
	call MemCopy


	.Exit:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringTruncateRight:
	; Truncates the string to the length specified by trimming characters off the end
	;
	;  input:
	;   String address
	;   Length to which the string will be shortened
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 4
	%define strLength							dword [ebp - 4]


	; get the length of the string
	push dword [ebp + 8]
	call StringLength
	mov strLength, eax

	; exit if the string specified is shorter than the length given
	mov eax, dword [ebp + 12]
	mov ebx, strLength
	cmp eax, ebx
	jae .Exit

	; add the new length of the string to it's starting address to get our write address
	mov edi, [ebp + 8]
	add edi, eax

	; and write a null to truncate the string
	mov eax, 0
	stosb


	.Exit:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringWordCount:
	; Counts the words in the string specified when viewed as a sentence separated by the byte specified
	;
	;  input:
	;	String address
	;	List of characters to be used as separators (cannot include nulls)
	;
	;  output:
	;	EAX - Word count

	push ebp
	mov ebp, esp


	; allocate local variables
	sub esp, 15
	%define mainStrLen							dword [ebp - 4]
	%define listStrLen							dword [ebp - 8]
	%define wordCount							dword [ebp - 12]
	%define lastType							byte [ebp - 13]
	%define currentByteTemp						word [ebp - 15]


	; get eax ready for writing to the return value in case we have to exit immediately
	mov eax, 0

	; get length of the main string
	push dword [ebp + 8]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov mainStrLen, eax

	; get length of the list string
	push dword [ebp + 12]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov listStrLen, eax

	; set up loop value
	mov ecx, mainStrLen

	; set up local variables here
	mov lastType, 0
	mov currentByteTemp, 0
	mov wordCount, 0
	mov esi, dword [ebp + 8]

	; loop to process the characters
	.WordLoop:
		; copy a byte from the string into al
		lodsb

		; save important stuff
		push esi
		push ecx

		; see if this byte is in the list of seperators
		push dword [ebp + 12]
		mov byte [ebp - 15], al
		mov eax, ebp
		sub eax, 15
		push eax
		call StringSearchCharList

		; restore important stuff
		pop ecx
		pop esi

		; see if a match was found
		cmp eax, 0
		je .NotASeperator
			; make a note that this character was a separator
			mov lastType, 2
			jmp .NextIteration

		.NotASeperator:

			; if the last character wasn't a separator, increment wordCount
			mov bl, lastType

			cmp bl, 1
			je .SkipIncrement
				inc wordCount
			.SkipIncrement:

			; make a note that this character was not a separator
			mov lastType, 1

		.NextIteration:

	loop .WordLoop

	; get eax ready for writing the return value
	mov eax, wordCount


	.Exit:
	mov esp, ebp
	pop ebp
ret 8





section .text
StringWordGet:
	; Returns the word specified from the string specified when separated by the byte specified
	;
	;  input:
	;	String address
	;	List of characters to be used as separators (cannot include nulls)
	;	Word number which to return
	;	Address of string to hold the word requested
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; allocate local variables
	sub esp, 15
	%define mainStrLen							dword [ebp - 4]
	%define listStrLen							dword [ebp - 8]
	%define wordCount							dword [ebp - 12]
	%define lastType							byte [ebp - 13]
	%define currentByteTemp						word [ebp - 15]


	; get eax ready for writing to the return value in case we have to exit immediately
	mov eax, 0

	; get length of the main string
	push dword [ebp + 8]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov mainStrLen, eax

	; get length of the list string
	push dword [ebp + 12]
	call StringLength

	; exit if the string was null, save eax if not
	cmp eax, 0
	je .Exit
	mov listStrLen, eax

	; set up our loop value
	mov ecx, mainStrLen

	; set up local variables here
	mov lastType, 0
	mov currentByteTemp, 0
	mov wordCount, 0
	mov esi, dword [ebp + 8]

	; clear out the temp word string
	mov edi, [ebp + 20]
	mov al, 0
	stosb

	; loop to process the characters
	.WordLoop:
		; copy a byte from the string into al
		lodsb

		; save important stuff
		push esi
		push eax
		push ecx

		; see if this byte is in the list of seperators
		push dword [ebp + 12]
		mov byte [ebp - 15], al
		mov eax, ebp
		sub eax, 15
		push eax
		call StringSearchCharList
		mov edx, eax

		; restore important stuff
		pop ecx
		pop eax
		pop esi

		; see if a match was found
		cmp edx, 0
		je .NotASeperator
			; see if we have the requested word and exit if so
			mov eax, [ebp + 16]
			mov ebx, wordCount
			cmp eax, ebx
			je .WordFound

			; clear out wordReturned$
			mov edi, [ebp + 20]
			mov al, 0
			stosb

			; make a note that this character was a separator
			mov lastType, 2
			jmp .NextIteration

		.NotASeperator:

			; if the last character wasn't a separator, increment wordCount
			mov bl, lastType

			cmp bl, 1
			je .SkipIncrement
				inc wordCount
			.SkipIncrement:

			; make a note that this character was not a separator
			mov lastType, 1

			; add this character to wordReturned$
			pusha
			push eax
			push dword [ebp + 20]
			call StringCharAppend
			popa


		.NextIteration:

	loop .WordLoop


	.WordFound:
	; get eax ready for writing the return value
	mov eax, wordCount


	.Exit:
	mov dword [ebp + 12], eax


	mov esp, ebp
	pop ebp
ret 16
