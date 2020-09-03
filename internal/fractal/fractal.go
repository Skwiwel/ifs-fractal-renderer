package fractal

import (
	"image/color"
	"sync"
	"time"

	"fyne.io/fyne"
	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"

	"fyne.io/fyne/canvas"
)

const (
	defaultWidth  uint32 = 200
	defaultHeight uint32 = 400

	minWidth  uint32 = 100
	minHeight uint32 = 100
)

type fractal struct {
	width, height uint32
	pixelArray    [][]color.RGBA

	drawIterations uint32

	window fyne.Window
	canvas fyne.CanvasObject

	drawing    bool
	drawingMux sync.Mutex
}

// Setup inserts the fractal into the window
func Setup(window fyne.Window) {
	fractal := newFractal(defaultWidth, defaultHeight, window)
	fractal.paintRed()
	fractal.canvas = canvas.NewRasterWithPixels(fractal.getPixelAt)

	window.SetContent(fyne.NewContainerWithLayout(fractal, fractal.canvas))
	go func() {
		time.Sleep(1 * time.Second)
		fractal.Draw(
			100000000,
			30.0,
			ifsconstants.BarnsleyFernTable,
		)
	}()
}

func newFractal(width, height uint32, window fyne.Window) *fractal {
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

// for testing purposes
func (f *fractal) paintRed() {
	for column := range f.pixelArray {
		for row := range f.pixelArray[column] {
			f.pixelArray[column][row] = color.RGBA{255, 0, 0, 255}
		}
	}
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

func (f *fractal) fractalKey(ev *fyne.KeyEvent) {
	f.Draw(
		10000000,
		30.0,
		ifsconstants.BarnsleyFernTable,
	)
}

func (f *fractal) refresh() {
	f.window.Canvas().Refresh(f.canvas)
}

func (f *fractal) Layout(objects []fyne.CanvasObject, size fyne.Size) {
	f.canvas.Resize(size)
}

func (f *fractal) MinSize(objects []fyne.CanvasObject) fyne.Size {
	return fyne.NewSize(int(minWidth), int(minHeight))
}
