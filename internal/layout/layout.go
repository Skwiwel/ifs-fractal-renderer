package layout

import (
	"math"

	"fyne.io/fyne"
	"github.com/skwiwel/ifs-fractal-maker/internal/util"
)

type Default struct {
	gui     fyne.CanvasObject
	fractal fyne.CanvasObject
}

func MakeDefault(gui, fractal fyne.CanvasObject) *Default {
	return &Default{
		gui:     gui,
		fractal: fractal,
	}
}

func (d *Default) MinSize(objects []fyne.CanvasObject) fyne.Size {
	w, h := 0, 0
	for _, o := range objects {
		childSize := o.MinSize()

		w = util.MaxInt(w, childSize.Width)
		h += childSize.Height
	}
	return fyne.NewSize(w, h)
}

func (d *Default) Layout(objects []fyne.CanvasObject, containerSize fyne.Size) {
	basePos := fyne.NewPos(0, 0)

	guiSize := fyne.Size{
		Width:  containerSize.Width,
		Height: int(math.Min(100, float64(containerSize.Height)*0.2)),
	}
	d.gui.Resize(guiSize)
	d.gui.Move(basePos)

	fractalSize := fyne.Size{
		Width:  containerSize.Width,
		Height: containerSize.Height - guiSize.Height,
	}
	d.fractal.Resize(fractalSize)
	fractalPos := basePos.Add(fyne.NewPos(0, guiSize.Height))
	d.fractal.Move(fractalPos)
}
