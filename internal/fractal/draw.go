package fractal

import (
	"image/color"

	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"
)

func (f *fractal) draw() {
	drawPixelArray(
		f.pixelArray,
		f.width, f.height,
		f.drawIterations,
		70.0,
		ifsconstants.BarnsleyFernProbabilities[0],
		ifsconstants.BarnsleyFernProbabilities[1],
		ifsconstants.BarnsleyFernProbabilities[2],
		ifsconstants.BarnsleyFernProbabilities[3],
		ifsconstants.BarnsleyFernTable,
	)
}

func drawPixelArray(pixelArray [][]color.RGBA, width, height, loopCount uint32, scale, p1, p2, p3, p4 float32, ifsTable [4][6]float32)
