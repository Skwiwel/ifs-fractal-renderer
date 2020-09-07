package fractal

// DrawData is a data struct for passing values to the fractal Draw() function.
type DrawData struct {
	LoopCount uint32
	Scale     float32
	IfsTable  [4][7]float32
}
