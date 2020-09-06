package main

import (
	"math"

	"fyne.io/fyne"
	"fyne.io/fyne/app"

	"github.com/skwiwel/ifs-fractal-maker/internal/fractal"
	"github.com/skwiwel/ifs-fractal-maker/internal/gui"
	"github.com/skwiwel/ifs-fractal-maker/internal/layout"
)

var (
	defaultSize = fyne.Size{
		Width:  500,
		Height: 1000,
	}
	guiDefaultSize = fyne.Size{
		Width: defaultSize.Width,
		Height: int(math.Min(
			100,
			float64(defaultSize.Height)*0.2),
		),
	}
	fractalDefaultSize = fyne.Size{
		Width:  defaultSize.Width,
		Height: defaultSize.Height - guiDefaultSize.Height,
	}
)

func main() {
	app := app.New()

	window := app.NewWindow("Fractal Maker")
	window.SetPadded(false)
	window.Resize(defaultSize)

	fractalObj := fractal.Setup()
	guiObj := gui.Setup(fractalObj)

	layout := layout.MakeDefault(guiObj.Canvas(), fractalObj.Canvas())
	masterContainer := fyne.NewContainerWithLayout(layout, guiObj.Canvas(), fractalObj.Canvas())
	window.SetContent(masterContainer)
	window.ShowAndRun()
}
