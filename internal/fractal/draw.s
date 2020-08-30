DATA	fractal_scale+0(SB)/8, $70.0

// takes a 64bit pointer and 32bit integer register arguments
// 1:bitmap, 2:width, 3:x, 4:y
/*
%macro dyePixel 4
	MOVQ rax, 0
	MOVQ eax, %4
	mul %2
	add eax, %3
	shl eax, 2
	add rax, %1
	MOVQ r15d, [rax]
	ror r15d, 8
	add r15b, 0x01
	jnc %%notMaxVal
	MOVQ r15b, 0xff
%%notMaxVal:
	rol r15d, 8
	MOVQ [rax], r15d
%endmacro
*/

// takes a 64bit pointer and 32bit integer register arguments
// 1:[X,Y,nextX,nextY], 2:[a,b,c,d], 3:[?,?,e,f]
/*
%macro calc_XY 3
	shufps %1, %1, 93h	// rotate left
	shufps %2, %2, 93h	// rotate left
	movss xmm15, %1
	mulss xmm15, %2
	shufps %1, %1, 01001110b
	movss %1, xmm15		// nextX := a*X
	shufps %1, %1, 39h	// rotate right
	shufps %2, %2, 93h	// rotate left
	movss xmm15, %1
	mulss xmm15, %2
	shufps %1, %1, 93h	// rotate left
	addss	%1, xmm15	// nextX += b*Y
	shufps %3, %3, 39h	// rotate right
	addss	%1, %3		// nextX += e

	shufps %1, %1, 01001110b
	shufps %2, %2, 93h	// rotate left
	movss xmm15, %1
	mulss xmm15, %2
	shufps %1, %1, 39h	// rotate right
	movss %1, xmm15		// nextY := c*X
	shufps %1, %1, 01001110b
	shufps %2, %2, 93h	// rotate left
	movss xmm15, %1
	mulss xmm15, %2
	shufps %1, %1, 01001110b
	addss	%1, xmm15	// nextY += d*Y
	shufps %3, %3, 93h	// rotate left
	addss	%1, %3		// nextY += f
%endmacro
*/

// func drawPixelArray(pixelArray [][]color.RGBA, width, height, loopCount uint32, p1, p2, p3, p4 float32, ifsTable [4][6]float32
TEXT ·drawPixelArray(SB), $0
	MOVQ	$0,SI
	// arguments location
	// rdi			, RSI	, RDX		, RCX      	, XMM0	, XMM1	, XMM2	, XMM3	, R8
	// pixelArray	, width , height	, loopCount	, p1  	, p2	, p3	, p4	, ifsTable
	
	
	

	//MOVL r12, CX
	//MOVQ r10, r8		// temporarily move ifsTable to r10
	//MOVQ r8d, esi
	//MOVQ r9d, edx

// clear the bitmap - set RGBA to (0,0,0,255)
	MOVQ	pixelArray+0(FP), DI
	MOVL	$24, AX
	MULL	width+24(FP)		
	MOVQ	AX, R8	// width offset end in bytes
	MOVL	$4, AX	// 24 is byte size of a go slice
	MULL	height+28(FP)	
	MOVQ	AX, R9	// height offset end in bytes
	MOVQ	$0, R10	// column offset
bitmapClearColumn:
	MOVQ	$0, R11	// row	offset
	MOVQ	DI, CX
	ADDQ	R10, CX		// pointer to column which is a pointer to first pixel in row
	MOVQ	0(CX), CX	// current column
bitmapClearPixel:
	MOVQ	CX, AX
	ADDQ	R11, AX	// pixel
	MOVQ	$0xff000000, 0(AX)
	ADDQ	$4, R11	// 4 is bytes per pixel
	CMPQ	R11, R9	// compare row to array height
	JLT 	bitmapClearPixel
	NOP
	ADDQ	$24, R10
	CMPQ	R10, R8
	JLT		bitmapClearColumn
	
// Prepare propability values
	MOVSS	p1+36(FP), X0
	MOVSS	p2+40(FP), X1
	MOVSS 	p3+44(FP), X2
	MOVSS	p4+48(FP), X3
	// sum up the propability values
	ADDSS	X0, X1
	ADDSS	X1, X2
	ADDSS	X2, X3
	// pack the values into a single register
	UNPCKLPS	X1, X0
	UNPCKLPS	X2, X3
	MOVLHPS		X1, X0	// X0 := [p4, p3, p2, p1]

// Prepare function value registers
	MOVSS	ifsTable+(52+3*4)(FP), X1
	MOVSS	ifsTable+(52+2*4)(FP), X15
	UNPCKLPS	X15, X1
	MOVSS	ifsTable+(52+1*4)(FP), X15
	MOVSS	ifsTable+(52+0*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X1	// X1 := [a1, b1, c1, d1]

	MOVSS	ifsTable+(52+9*4)(FP), X2
	MOVSS	ifsTable+(52+8*4)(FP), X15
	UNPCKLPS	X15, X2
	MOVSS	ifsTable+(52+7*4)(FP), X15
	MOVSS	ifsTable+(52+6*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X2	// X2 := [a2, b2, c2, d2]

	MOVSS	ifsTable+(52+15*4)(FP), X3
	MOVSS	ifsTable+(52+14*4)(FP), X15
	UNPCKLPS	X15, X3
	MOVSS	ifsTable+(52+13*4)(FP), X15
	MOVSS	ifsTable+(52+12*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X3	// X3 := [a3, b3, c3, d3]

	MOVSS	ifsTable+(52+21*4)(FP), X4
	MOVSS	ifsTable+(52+20*4)(FP), X15
	UNPCKLPS	X15, X4
	MOVSS	ifsTable+(52+19*4)(FP), X15
	MOVSS	ifsTable+(52+18*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X4	// X4 := [a4, b4, c4, d4]

	MOVSS	ifsTable+(52+11*4)(FP), X5
	MOVSS	ifsTable+(52+10*4)(FP), X15
	UNPCKLPS	X15, X5
	MOVSS	ifsTable+(52+5*4)(FP), X15
	MOVSS	ifsTable+(52+4*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X5	// X5 := [e1, f1, e2, f2]

	MOVSS	ifsTable+(52+23*4)(FP), X6
	MOVSS	ifsTable+(52+22*4)(FP), X15
	UNPCKLPS	X15, X6
	MOVSS	ifsTable+(52+17*4)(FP), X15
	MOVSS	ifsTable+(52+16*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X6	// X6 := [e3, f3, e4, f4]

	RET
/*

	
	MOVL	width+24(FP), R8
	MOVL	height+28(FP), R9
	MOVQ	ifsTable[0]+52(FP), R10
	MOVL	loopCount+32(FP), R12

	// Create a semi-random seed using rdtsc
	rdtsc
	MOVQ r13d, eax

// Draw the fractal
	// xmm0 := [p4, p3, p2, p1]
	// xmm1 := [a1, b1, c1, d1]
	// xmm2 := [a2, b2, c2, d2]
	// xmm3 := [a3, b3, c3, d3]
	// xmm4 := [a4, b4, c4, d4]
	// xmm5 := [e1, f1, e2, f2]
	// xmm6 := [e3, f3, e4, f4]
	// xmm8 := [X, Y, nextX, nextY]
	// xmm9 := random number [0.001-1.000]
	// xmm12 := fractal_scale
	// r8d := int width
	// r9d := int height
	// r10d := int X to draw
	// r11d := int Y to draw
	// r12d := loopCount
	// r13w := RNG seed
	// rdi  := pBitmap
	xorps xmm8, xmm8
	shufps xmm8, xmm8, 0b	// X, Y, nextX, nextY := 0

	movss xmm12, [rel fractal_scale]

fractal_draw_loop:
	// Get x and y int
	shufps xmm8, xmm8, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm12
	cvtss2si r10d, xmm15
	shufps xmm8, xmm8, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm12
	cvtss2si r11d, xmm15
	shufps xmm8, xmm8, 01001110b	// restore from rotations
	add r10d, 250	// move fractal to the middle horizontally
	add r11d, 10	// move fractal up a bit
	// invert y
	sub r11d, r9d
	neg r11d
	// Check whether X is contained within image dimensions
	cmp r10d, r8d
	jge skip_dye
	cmp r10d, 0
	jl skip_dye
	// Check whether Y is contained within image dimensions
	cmp r11d, r9d
	jge skip_dye
	cmp r11d, 0
	jl skip_dye
	// dyePixel rdi, r8d, r10d, r11d
	// dye pixel: rdi:bitmap, r8d:width, r10d:x, r11d:y
	MOVQ rax, 0
	MOVQ eax, r11d
	mul r8d
	add eax, r10d
	shl eax, 2
	add rax, rdi
	MOVQ r15d, [rax]
	ror r15d, 8
	add r15b, 0x01
	jnc notMaxVal
	MOVQ r15b, 0xff
notMaxVal:
	rol r15d, 8
	MOVQ [rax], r15d
	//
skip_dye:
	// RNG using seed
	// For the curious: Uncomment the rdtsc// command and comment the rest of the section (up to xor edx, edx//)
	// This will show the effects of a very predictable rng that uses pure rdtsc in quick succesion
	//rdtsc					// [edx:eax] := pseudo random
	MOVQ eax, 25173
	mul r13d
	add eax, 13849
	MOVQ r13d, eax

	xor edx,edx
	MOVQ ecx, 1000	// accuracy of random number
	div ecx				// eax / ecx -> edx is random%1000
	MOVQ eax, edx	// eax := [0-999]
	add eax, 1		// eax := [1-1000]
	movd xmm9, eax
	movd xmm15, ecx
	divss xmm9, xmm15	// xmm9 := [0.001-1.000]
	// perform fractal function according to random
	ucomiss xmm9, xmm0
	ja check_f2
	shufps xmm5, xmm5, 01001110b	// double rotate ef
	//calc_XY xmm8, xmm1, xmm5
	//%macro calc_XY 3
	shufps xmm8, xmm8, 93h	// rotate left
	shufps xmm1, xmm1, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm1
	shufps xmm8, xmm8, 01001110b
	movss xmm8, xmm15		// nextX := a*X
	shufps xmm8, xmm8, 39h	// rotate right
	shufps xmm1, xmm1, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm1
	shufps xmm8, xmm8, 93h	// rotate left
	addss	xmm8, xmm15	// nextX += b*Y
	shufps xmm5, xmm5, 39h	// rotate right
	addss	xmm8, xmm5		// nextX += e

	shufps xmm8, xmm8, 01001110b
	shufps xmm1, xmm1, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm1
	shufps xmm8, xmm8, 39h	// rotate right
	movss xmm8, xmm15		// nextY := c*X
	shufps xmm8, xmm8, 01001110b
	shufps xmm1, xmm1, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm1
	shufps xmm8, xmm8, 01001110b
	addss	xmm8, xmm15	// nextY += d*Y
	shufps xmm5, xmm5, 93h	// rotate left
	addss	xmm8, xmm5		// nextY += f
	//%endmacro

	shufps xmm5, xmm5, 01001110b
	jmp done_calculating_f
check_f2:
	shufps xmm0, xmm0, 39h	// rotate p right
	ucomiss xmm9, xmm0
	ja check_f3
	shufps xmm0, xmm0, 93h
	// calc_XY xmm8, xmm2, xmm5
	//%macro calc_XY 3
	shufps xmm8, xmm8, 93h	// rotate left
	shufps xmm2, xmm2, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm2
	shufps xmm8, xmm8, 01001110b
	movss xmm8, xmm15		// nextX := a*X
	shufps xmm8, xmm8, 39h	// rotate right
	shufps xmm2, xmm2, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm2
	shufps xmm8, xmm8, 93h	// rotate left
	addss	xmm8, xmm15	// nextX += b*Y
	shufps xmm5, xmm5, 39h	// rotate right
	addss	xmm8, xmm5		// nextX += e

	shufps xmm8, xmm8, 01001110b
	shufps xmm2, xmm2, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm2
	shufps xmm8, xmm8, 39h	// rotate right
	movss xmm8, xmm15		// nextY := c*X
	shufps xmm8, xmm8, 01001110b
	shufps xmm2, xmm2, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm2
	shufps xmm8, xmm8, 01001110b
	addss	xmm8, xmm15	// nextY += d*Y
	shufps xmm5, xmm5, 93h	// rotate left
	addss	xmm8, xmm5		// nextY += f
	//%endmacro
	jmp done_calculating_f
check_f3:
	shufps xmm0, xmm0, 39h	// rotate p right
	ucomiss xmm9, xmm0
	ja do_f4
	shufps xmm0, xmm0, 01001110b
	shufps xmm6, xmm6, 01001110b
	// calc_XY xmm8, xmm3, xmm6
	//%macro calc_XY 3
	shufps xmm8, xmm8, 93h	// rotate left
	shufps xmm3, xmm3, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm3
	shufps xmm8, xmm8, 01001110b
	movss xmm8, xmm15		// nextX := a*X
	shufps xmm8, xmm8, 39h	// rotate right
	shufps xmm3, xmm3, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm3
	shufps xmm8, xmm8, 93h	// rotate left
	addss	xmm8, xmm15	// nextX += b*Y
	shufps xmm6, xmm6, 39h	// rotate right
	addss	xmm8, xmm6		// nextX += e

	shufps xmm8, xmm8, 01001110b
	shufps xmm3, xmm3, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm3
	shufps xmm8, xmm8, 39h	// rotate right
	movss xmm8, xmm15		// nextY := c*X
	shufps xmm8, xmm8, 01001110b
	shufps xmm3, xmm3, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm3
	shufps xmm8, xmm8, 01001110b
	addss	xmm8, xmm15	// nextY += d*Y
	shufps xmm6, xmm6, 93h	// rotate left
	addss	xmm8, xmm6		// nextY += f
	//%endmacro
	shufps xmm6, xmm6, 01001110b
	jmp done_calculating_f
do_f4:
	shufps xmm0, xmm0, 01001110b
	// calc_XY xmm8, xmm4, xmm6
	//%macro calc_XY 3
	shufps xmm8, xmm8, 93h	// rotate left
	shufps xmm4, xmm4, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm4
	shufps xmm8, xmm8, 01001110b
	movss xmm8, xmm15		// nextX := a*X
	shufps xmm8, xmm8, 39h	// rotate right
	shufps xmm4, xmm4, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm4
	shufps xmm8, xmm8, 93h	// rotate left
	addss	xmm8, xmm15	// nextX += b*Y
	shufps xmm6, xmm6, 39h	// rotate right
	addss	xmm8, xmm6		// nextX += e

	shufps xmm8, xmm8, 01001110b
	shufps xmm4, xmm4, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm4
	shufps xmm8, xmm8, 39h	// rotate right
	movss xmm8, xmm15		// nextY := c*X
	shufps xmm8, xmm8, 01001110b
	shufps xmm4, xmm4, 93h	// rotate left
	movss xmm15, xmm8
	mulss xmm15, xmm4
	shufps xmm8, xmm8, 01001110b
	addss	xmm8, xmm15	// nextY += d*Y
	shufps xmm6, xmm6, 93h	// rotate left
	addss	xmm8, xmm6		// nextY += f
	//%endmacro
done_calculating_f:
	shufps xmm8, xmm8, 01000100b	// X := nextX, Y := nextY
	sub r12d, 1
	cmp r12d, 0
	jne fractal_draw_loop

end:
	MOVQ rax, [rbp + 16]
	MOVQ rsp, rbp
	pop rbp
	ret
*/