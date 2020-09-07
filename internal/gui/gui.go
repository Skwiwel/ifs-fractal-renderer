package gui

import (
	"fyne.io/fyne"
	"fyne.io/fyne/layout"
	"fyne.io/fyne/widget"
	"github.com/skwiwel/ifs-fractal-maker/internal/fractal"
	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"
)

// Gui represents the gui part of the app.
type Gui struct {
	fractalData fractal.DrawData

	drawer IFSDrawer
	canvas fyne.CanvasObject
}

var defaultFractalData = fractal.DrawData{
	LoopCount: 10000000,
	Scale:     80.0,
	IfsTable:  ifsconstants.BarnsleyFernTable,
}

// IFSDrawer is an interface of an object able to draw IFS fractals
type IFSDrawer interface {
	Draw(*fractal.DrawData)
}

// Setup creates a Gui object based on a IFSDrawer it provides interface for.
func Setup(drawer IFSDrawer) *Gui {
	gui := Gui{
		fractalData: defaultFractalData,
		drawer:      drawer,
	}
	gui.setupCanvas()
	return &gui
}

func (gui *Gui) setupCanvas() {
	gui.canvas = fyne.NewContainerWithLayout(layout.NewGridLayout(2),
		widget.NewForm(
			widget.NewFormItem("loopcount", widget.NewEntry()),
			widget.NewFormItem("scale", widget.NewEntry()),
		),
		widget.NewButton("Draw", gui.drawFractal),
	)
}

func (gui *Gui) drawFractal() {
	gui.drawer.Draw(&gui.fractalData)
}

// Canvas returns the canvas of the Gui
func (gui *Gui) Canvas() fyne.CanvasObject {
	return gui.canvas
}
