package fractal

import (
	"image/color"
	"time"
)

const fps = 30

func (f *fractal) Draw(loopCount uint32, scale float32, ifsTable [4][7]float32) {
	f.drawingMux.Lock()
	if f.drawing {
		f.drawingMux.Unlock()
		return
	}
	f.drawing = true
	f.drawingMux.Unlock()

	drawingEnd := make(chan struct{})
	fpsTicker := time.NewTicker(time.Second / fps)

	go func() {
		drawPixelArray(
			f.pixelArray,
			f.width, f.height,
			loopCount,
			scale,
			ifsTable,
		)
		close(drawingEnd)
	}()

	for {
		select {
		case <-drawingEnd:
			f.refresh()
			f.drawingMux.Lock()
			f.drawing = false
			f.drawingMux.Unlock()
			return
		case <-fpsTicker.C:
			f.refresh()
		}
	}

}

func drawPixelArray(pixelArray [][]color.RGBA, width, height, loopCount uint32, scale float32, ifsTable [4][7]float32)
