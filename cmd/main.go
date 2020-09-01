package main

import (
	"fyne.io/fyne"
	"fyne.io/fyne/app"

	"github.com/skwiwel/ifs-fractal-maker/internal/fractal"
)

func main() {
	app := app.New()

	window := app.NewWindow("Fractal Maker")
	window.SetPadded(false)
	window.Resize(fyne.NewSize(200, 400))

	fractal.Setup(window)
	//gui.Run(window, fractal.getController())

	window.Show()

	app.Run()
}
