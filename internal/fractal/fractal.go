package fractal

import (
	"image/color"

	"fyne.io/fyne"

	"fyne.io/fyne/canvas"
)

const defaultWidth int32 = 200
const defaultHeight int32 = 400

const minWidth int32 = 100
const minHeight int32 = 100

type fractal struct {
	width, height int32
	pixelArray    [][]color.RGBA

	drawIterations int32

	window fyne.Window
	canvas fyne.CanvasObject
}

func (f *fractal) getPixelAt(x, y, w, h int) color.Color {
	if insideDimensions(x, y, f) {
		return f.pixelArray[x][y]
	}
	return color.RGBA{}
}

func insideDimensions(x, y int, f *fractal) bool {
	return x < int(f.width) && y < int(f.height)
}

func (f *fractal) Layout(objects []fyne.CanvasObject, size fyne.Size) {
	f.canvas.Resize(size)
}

func (f *fractal) MinSize(objects []fyne.CanvasObject) fyne.Size {
	return fyne.NewSize(int(minWidth), int(minHeight))
}

func newFractal(width, height int32, window fyne.Window) *fractal {
	pixelArray := make([][]color.RGBA, width)
	for column := range pixelArray {
		pixelArray[column] = make([]color.RGBA, height)
	}

	return &fractal{
		width:      defaultWidth,
		height:     defaultHeight,
		pixelArray: pixelArray,
		window:     window,
	}
}

func Setup(window fyne.Window) {
	fractal := newFractal(defaultWidth, defaultHeight, window)
	fractal.canvas = canvas.NewRasterWithPixels(fractal.getPixelAt)

	window.SetContent(fyne.NewContainerWithLayout(fractal, fractal.canvas))
}
