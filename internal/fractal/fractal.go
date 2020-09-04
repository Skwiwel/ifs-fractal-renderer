package fractal

import (
	"image"
	"image/color"
	"sync"
	"time"

	"fyne.io/fyne"
	"fyne.io/fyne/canvas"

	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"
)

const (
	// DefaultWidth is the default width of the fractal part of the window
	DefaultWidth uint32 = 500
	// DefaultHeight is the default height of the fractal part of the window
	DefaultHeight uint32 = 1000

	// MinWidth is the the minimum width the window is allowed to be
	MinWidth uint32 = 100
	// MinHeight is the the minimum height the window is allowed to be
	MinHeight uint32 = 100
)

type fractal struct {
	width, height uint32
	image         *image.RGBA

	drawIterations uint32

	window fyne.Window
	output *canvas.Raster

	drawing    bool
	drawingMux sync.Mutex
}

// Setup inserts the fractal into the window
func Setup(window fyne.Window) {
	fractal := newFractal(DefaultWidth, DefaultHeight, window)
	fractal.output = canvas.NewRasterFromImage(fractal.image)

	fractal.paintRed()

	window.SetContent(fyne.NewContainerWithLayout(fractal, fractal.output))
	go func() {
		time.Sleep(2 * time.Second)
		fractal.Draw(
			100000000,
			100.0,
			ifsconstants.BarnsleyFernTable,
		)
	}()
}

func newFractal(width, height uint32, window fyne.Window) *fractal {
	return &fractal{
		width:  DefaultWidth,
		height: DefaultHeight,
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
	return fyne.NewSize(int(MinWidth), int(MinHeight))
}
