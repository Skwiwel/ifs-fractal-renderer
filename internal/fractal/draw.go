package fractal

import (
	"image/color"

	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"
)

func (f *fractal) draw() {
	drawPixelArray(
		f.pixelArray,
		f.width, f.height,
		100000,
		30.0,
		ifsconstants.BarnsleyFernTable,
	)
}

func drawPixelArray(pixelArray [][]color.RGBA, width, height, loopCount uint32, scale float32, ifsTable [4][7]float32)
