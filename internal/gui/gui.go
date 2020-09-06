package gui

import (
	"fyne.io/fyne"
	"fyne.io/fyne/widget"
	"github.com/skwiwel/ifs-fractal-maker/internal/ifsconstants"
)

// Gui represents the gui part of the app.
type Gui struct {
	drawer IFSDrawer
	canvas fyne.CanvasObject
}

// IFSDrawer is an interface of an object able to draw IFS fractals
type IFSDrawer interface {
	Draw(loopcount uint32, scale float32, ifsTable [4][7]float32)
}

// Setup creates a Gui object based on a IFSDrawer it provides interface for.
func Setup(drawer IFSDrawer) *Gui {
	gui := Gui{drawer: drawer}
	gui.canvas = widget.NewButton("Draw", gui.draw)
	return &gui
}

func (gui *Gui) draw() {
	gui.drawer.Draw(
		10000000,
		80.0,
		ifsconstants.BarnsleyFernTable,
	)
}

// Canvas returns the canvas of the Gui
func (gui *Gui) Canvas() fyne.CanvasObject {
	return gui.canvas
}
