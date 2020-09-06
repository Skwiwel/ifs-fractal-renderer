package fractal

import (
	"image"
	"sync"

	"fyne.io/fyne"
	"fyne.io/fyne/canvas"
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

// Fractal represents the fractal drawing part of the app.
// It manages it's own canvas and offers funtions for drawing.
type Fractal struct {
	width, height uint32
	image         *image.RGBA

	drawIterations uint32

	canvas *canvas.Raster

	drawing    bool
	drawingMux sync.Mutex
}

// Setup creates a Fractal object
func Setup() *Fractal {
	fractal := newFractal(DefaultWidth, DefaultHeight)
	fractal.canvas = canvas.NewRasterFromImage(fractal.image)

	return fractal
}

func newFractal(width, height uint32) *Fractal {
	return &Fractal{
		width:  DefaultWidth,
		height: DefaultHeight,
		image:  image.NewRGBA(image.Rect(0, 0, int(width), int(height))),
	}
}

// Canvas returns the Fractal's canvas
func (f *Fractal) Canvas() *canvas.Raster {
	return f.canvas
}

// Size returns the dimensions of the fractal image
func (f *Fractal) Size() fyne.Size {
	imgBounds := f.image.Bounds()
	imgWidth := imgBounds.Max.X
	imgHeight := imgBounds.Max.Y
	return fyne.Size{
		Width:  imgWidth,
		Height: imgHeight,
	}
}

func (f *Fractal) refresh() {
	f.canvas.Refresh()
}
