package fractal

import (
	"image"
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
	image         *image.RGBA
	//pixelArray    [][]color.RGBA

	drawIterations uint32

	window fyne.Window
	output *canvas.Image

	drawing    bool
	drawingMux sync.Mutex
}

// Setup inserts the fractal into the window
func Setup(window fyne.Window) {
	fractal := newFractal(defaultWidth, defaultHeight, window)
	fractal.output = canvas.NewImageFromImage(fractal.image)
	fractal.output.ScaleMode = canvas.ImageScalePixels

	fractal.paintRed()

	window.SetContent(fyne.NewContainerWithLayout(fractal, fractal.output))
	go func() {
		time.Sleep(2 * time.Second)
		fractal.Draw(
			100000000,
			30.0,
			ifsconstants.BarnsleyFernTable,
		)
	}()
}

func newFractal(width, height uint32, window fyne.Window) *fractal {
	return &fractal{
		width:  defaultWidth,
		height: defaultHeight,
		image:  image.NewRGBA(image.Rect(0, 0, int(width), int(height))),
		window: window,
	}
}

// for testing purposes
func (f *fractal) paintRed() {
	for x := 0; x < int(f.width); x++ {
		for y := 0; y < int(f.height); y++ {
			f.image.SetRGBA(x, y, color.RGBA{255, 0, 0, 255})
		}
	}
}

func (f *fractal) getPixelAt(x, y, w, h int) color.Color {
	if insideDimensions(x, y, f) {
		return f.image.At(x, y)
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
	f.output.Refresh()
}

func (f *fractal) Layout(objects []fyne.CanvasObject, size fyne.Size) {
	f.output.Resize(size)
}

func (f *fractal) MinSize(objects []fyne.CanvasObject) fyne.Size {
	return fyne.NewSize(int(minWidth), int(minHeight))
}
