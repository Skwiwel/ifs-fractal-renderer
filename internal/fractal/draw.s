DATA	fractal_scale+0(SB)/8, $70.0

// func drawPixelArray(pixelArray []uint8, width, height, loopCount uint32, scale float32, ifsTable [4][7]float32)
TEXT ·drawPixelArray(SB), $0-152

// clear the bitmap - set RGBA to (0,0,0,255)
	MOVQ	pixelArray+0(FP), DI
	MOVQ	$4, AX
	MULL	width+24(FP)
	MULL	height+28(FP)
	ADDQ	DI, AX
	MOVQ	AX, R8	// first memory address after the last pixel
	MOVQ	DI, R9	// current pixel address
bitmapClearPixel:
	MOVQ	$0xff000000, 0(R9)
	ADDQ	$4, R9
	CMPQ	R9, R8
	JLT		bitmapClearPixel

// Prepare propability values
	MOVSS	ifsTable+(40+6*4)(FP), X0
	MOVSS	ifsTable+(40+13*4)(FP), X1
	MOVSS 	ifsTable+(40+20*4)(FP), X2
	MOVSS	ifsTable+(40+27*4)(FP), X3
	// sum up the propability values
	ADDSS	X0, X1
	ADDSS	X1, X2
	ADDSS	X2, X3
	// pack the values into a single register
	UNPCKLPS	X1, X0
	UNPCKLPS	X3, X2
	MOVLHPS		X2, X0	// X0 := [p4, p3, p2, p1]

// Prepare function value registers
	MOVSS		ifsTable+(40+3*4)(FP), X1
	MOVSS		ifsTable+(40+2*4)(FP), X15
	UNPCKLPS	X15, X1 
	MOVSS		ifsTable+(40+1*4)(FP), X15
	MOVSS		ifsTable+(40+0*4)(FP), X14
	UNPCKLPS	X14, X15 
	MOVLHPS		X15, X1	// X1 := [a1, b1, c1, d1]

	MOVSS		ifsTable+(40+10*4)(FP), X2
	MOVSS		ifsTable+(40+9*4)(FP), X15
	UNPCKLPS	X15, X2
	MOVSS		ifsTable+(40+8*4)(FP), X15
	MOVSS		ifsTable+(40+7*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X2	// X2 := [a2, b2, c2, d2]

	MOVSS		ifsTable+(40+17*4)(FP), X3
	MOVSS		ifsTable+(40+16*4)(FP), X15
	UNPCKLPS	X15, X3
	MOVSS		ifsTable+(40+15*4)(FP), X15
	MOVSS		ifsTable+(40+14*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X3	// X3 := [a3, b3, c3, d3]

	MOVSS		ifsTable+(40+24*4)(FP), X4
	MOVSS		ifsTable+(40+23*4)(FP), X15
	UNPCKLPS	X15, X4
	MOVSS		ifsTable+(40+22*4)(FP), X15
	MOVSS		ifsTable+(40+21*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X4	// X4 := [a4, b4, c4, d4]

	MOVSS		ifsTable+(40+12*4)(FP), X5
	MOVSS		ifsTable+(40+11*4)(FP), X15
	UNPCKLPS	X15, X5
	MOVSS		ifsTable+(40+5*4)(FP), X15
	MOVSS		ifsTable+(40+4*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X5	// X5 := [e1, f1, e2, f2]

	MOVSS		ifsTable+(40+26*4)(FP), X6
	MOVSS		ifsTable+(40+25*4)(FP), X15
	UNPCKLPS	X15, X6
	MOVSS		ifsTable+(40+19*4)(FP), X15
	MOVSS		ifsTable+(40+18*4)(FP), X14
	UNPCKLPS	X14, X15
	MOVLHPS		X15, X6	// X6 := [e3, f3, e4, f4]

// Create a semi-random seed using rdtsc
	RDTSCP		// RTDSC seems not to be present in Go's assembler, but RTDSCP is.
	MOVQ	AX, R13

// Prepare the rest of the registers
	MOVSS	scale+36(FP), X12
	MOVL	width+24(FP), R8
	MOVL	height+28(FP), R9
	MOVL	loopCount+32(FP), R12
	XORPS 	X8, X8	// X, Y, nextX, nextY := 0

// Draw the fractal
	// X0 := [p4, p3, p2, p1]
	// X1 := [a1, b1, c1, d1]
	// X2 := [a2, b2, c2, d2]
	// X3 := [a3, b3, c3, d3]
	// X4 := [a4, b4, c4, d4]
	// X5 := [e1, f1, e2, f2]
	// X6 := [e3, f3, e4, f4]
	// X8 := [X, Y, nextX, nextY]
	// X9 := random number [0.001-1.000]
	// X12 := fractal_scale
	// R8 := int width
	// R9 := int height
	// R10 := int X to draw
	// R11 := int Y to draw
	// R12 := loopCount
	// R13 := RNG seed
	// DI := pixelArray slice

fractal_draw_loop:
	// Get x and y int
	SHUFPS		$0x93, X8, X8	// rotate left
	MOVSS		X8, X15
	MULSS		X12, X15
	CVTSS2SL	X15, R10
	SHUFPS		$0x93, X8, X8	// rotate left
	MOVSS		X8, X15
	MULSS		X12, X15
	CVTSS2SL	X15, R11
	SHUFPS		$0b01001110, X8, X8	// restore from rotations
	
	// TODO: proper positioning of vector
	// hardcoded for now
	ADDL	$100, R10
	ADDL	$10, R11
	
	// invert y
	SUBL	R9, R11
	NEGL	R11
	// Check whether X is contained within image dimensions
	CMPL	R10, R8
	JGE		skip_dye
	CMPL	R10, $0
	JLT		skip_dye
	// Check whether Y is contained within image dimensions
	CMPL	R11, R9
	JGE		skip_dye
	CMPL	R11, $0
	JLT		skip_dye

	// dye pixel
	MOVQ	$4, AX
	MULQ	R10
	MOVQ	AX, R15
	MOVQ	$4, AX
	MULQ	R8
	MULQ	R11
	ADDQ	R15, AX
	ADDQ	DI, AX		// pointer to target pixel
	MOVQ	(AX), R15	// pixel RGBA
	RORQ	$8, R15		// dyeing green
	ADDB	$1, R15
	JNC		not_max_val
	MOVB	$0xff, R15
not_max_val:
	ROLQ	$8, R15
	MOVQ	R15, (AX)
skip_dye:

	// RNG using seed
	// For the curious: Uncomment the RDTCSP command and comment the rest of the section (up to XORQ DX, DX)
	// This will show the effects of a very predictable rng that uses pure rdtsc in quick succesion
	//RDTSCP			// [DX:AX] := pseudo random
	MOVQ	$25173, AX
	MULQ	R13
	ADDQ	$13849, AX
	MOVQ	AX, R13

	XORQ	DX, DX
	MOVQ	$1000, CX	// accuracy of random number
	DIVQ	CX			// AX/CX -> DX is random%1000
	MOVQ	DX, AX		// AX := [0-999]
	ADDQ	$1, AX		// AX := [1-1000]
	MOVL	AX, X9
	MOVL	CX, X15
	DIVSS	X15, X9		// X9 := [0.001-1.000]
	
	// perform fractal function according to random
	UCOMISS	X0, X9
	JA		check_f2

	SHUFPS	$0b01001110, X5, X5	// double rotate ef
	// inline function/macro calc_XY X8, X1, X5
	SHUFPS 	$0x93, X8, X8	// rotate left
	SHUFPS 	$0x93, X1, X1	// rotate left
	MOVSS 	X8, X15
	MULSS	X1, X15
	SHUFPS 	$0b01001110, X8, X8
	MOVSS	X15, X8			// nextX := a*X
	SHUFPS 	$0x39, X8, X8	// rotate right
	SHUFPS 	$0x93, X1, X1	// rotate left
	MOVSS 	X8, X15
	MULSS	X1, X15
	SHUFPS 	$0x93, X8, X8	// rotate left
	ADDSS	X15, X8			// nextX += b*Y
	SHUFPS	$0x39, X5, X5	// rotate right
	ADDSS	X5, X8			// nextX += e

	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X1, X1	// rotate left
	MOVSS 	X8, X15
	MULSS	X1, X15
	SHUFPS 	$0x39, X8, X8	// rotate right
	MOVSS	X15, X8			// nextY := c*X
	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X1, X1	// rotate left
	MOVSS 	X8, X15
	MULSS	X1, X15
	SHUFPS 	$0b01001110, X8, X8
	ADDSS	X15, X8			// nextY += d*Y
	SHUFPS	$0x93, X5, X5	// rotate left
	ADDSS	X5, X8			// nextY += f
	//%endmacro
	SHUFPS $0b01001110, X5, X5
	JMP done_calculating_f
check_f2:
	SHUFPS	$0x39, X0, X0	// rotate p right
	UCOMISS	X0, X9
	JA		check_f3
	SHUFPS	$0x93, X0, X0
	// inline function/macro calc_XY X8, X2, X5
	SHUFPS 	$0x93, X8, X8	// rotate left
	SHUFPS 	$0x93, X2, X2	// rotate left
	MOVSS 	X8, X15
	MULSS	X2, X15
	SHUFPS 	$0b01001110, X8, X8
	MOVSS	X15, X8			// nextX := a*X
	SHUFPS 	$0x39, X8, X8	// rotate right
	SHUFPS 	$0x93, X2, X2	// rotate left
	MOVSS 	X8, X15
	MULSS	X2, X15
	SHUFPS 	$0x93, X8, X8	// rotate left
	ADDSS	X15, X8			// nextX += b*Y
	SHUFPS	$0x39, X5, X5	// rotate right
	ADDSS	X5, X8			// nextX += e

	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X2, X2	// rotate left
	MOVSS 	X8, X15
	MULSS	X2, X15
	SHUFPS 	$0x39, X8, X8	// rotate right
	MOVSS	X15, X8			// nextY := c*X
	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X2, X2	// rotate left
	MOVSS 	X8, X15
	MULSS	X2, X15
	SHUFPS 	$0b01001110, X8, X8
	ADDSS	X15, X8			// nextY += d*Y
	SHUFPS	$0x93, X5, X5	// rotate left
	ADDSS	X5, X8			// nextY += f
	//%endmacro
	JMP		done_calculating_f
check_f3:
	SHUFPS	$0x39, X0, X0	// rotate p right
	UCOMISS	X0, X9
	JA 		do_f4
	SHUFPS 	$0b01001110, X0, X0
	SHUFPS 	$0b01001110, X6, X6
	// inline function/macro calc_XY X8, X3, X6
	SHUFPS 	$0x93, X8, X8	// rotate left
	SHUFPS 	$0x93, X3, X3	// rotate left
	MOVSS 	X8, X15
	MULSS	X3, X15
	SHUFPS 	$0b01001110, X8, X8
	MOVSS	X15, X8			// nextX := a*X
	SHUFPS 	$0x39, X8, X8	// rotate right
	SHUFPS 	$0x93, X3, X3	// rotate left
	MOVSS 	X8, X15
	MULSS	X3, X15
	SHUFPS 	$0x93, X8, X8	// rotate left
	ADDSS	X15, X8			// nextX += b*Y
	SHUFPS	$0x39, X6, X6	// rotate right
	ADDSS	X6, X8			// nextX += e

	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X3, X3	// rotate left
	MOVSS 	X8, X15
	MULSS	X3, X15
	SHUFPS 	$0x39, X8, X8	// rotate right
	MOVSS	X15, X8			// nextY := c*X
	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X3, X3	// rotate left
	MOVSS 	X8, X15
	MULSS	X3, X15
	SHUFPS 	$0b01001110, X8, X8
	ADDSS	X15, X8			// nextY += d*Y
	SHUFPS	$0x93, X6, X6	// rotate left
	ADDSS	X6, X8			// nextY += f
	//%endmacro
	SHUFPS 	$0b01001110, X6, X6
	JMP		done_calculating_f
do_f4:
	SHUFPS 	$0b01001110, X0, X0
	// inline function/macro calc_XY X8, X4, X6
	SHUFPS 	$0x93, X8, X8	// rotate left
	SHUFPS 	$0x93, X4, X4	// rotate left
	MOVSS 	X8, X15
	MULSS	X4, X15
	SHUFPS 	$0b01001110, X8, X8
	MOVSS	X15, X8			// nextX := a*X
	SHUFPS 	$0x39, X8, X8	// rotate right
	SHUFPS 	$0x93, X4, X4	// rotate left
	MOVSS 	X8, X15
	MULSS	X4, X15
	SHUFPS 	$0x93, X8, X8	// rotate left
	ADDSS	X15, X8			// nextX += b*Y
	SHUFPS	$0x39, X6, X6	// rotate right
	ADDSS	X6, X8			// nextX += e

	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X4, X4	// rotate left
	MOVSS 	X8, X15
	MULSS	X4, X15
	SHUFPS 	$0x39, X8, X8	// rotate right
	MOVSS	X15, X8			// nextY := c*X
	SHUFPS 	$0b01001110, X8, X8
	SHUFPS 	$0x93, X4, X4	// rotate left
	MOVSS 	X8, X15
	MULSS	X4, X15
	SHUFPS 	$0b01001110, X8, X8
	ADDSS	X15, X8			// nextY += d*Y
	SHUFPS	$0x93, X6, X6	// rotate left
	ADDSS	X6, X8			// nextY += f
	//%endmacro
done_calculating_f:
	SHUFPS 	$0b01001110, X8, X8
	SUBL	$1, R12
	CMPL	R12, $0
	JNE		fractal_draw_loop

end:
	RET
