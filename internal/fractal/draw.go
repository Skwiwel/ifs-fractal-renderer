package fractal

import (
	"time"

	"github.com/vijayviji/executor"
)

const fps = 30

var drawingExecutor = executor.NewSingleThreadExecutor("drawingExecutor", 1)

// Draw draws the ifs on the canvas.
// When called it triggers the drawing process. While the ifs is being drawn the canvas will
// keep refreshing until it's finished. Function calls while the ifs is still being drawn are dropped.
func (f *Fractal) Draw(data *DrawData) {
	f.drawingMux.Lock()
	if f.drawing {
		f.drawingMux.Unlock()
		return
	}
	f.drawing = true
	f.drawingMux.Unlock()

	drawingEnd := make(chan struct{})

	go drawUsingExecutor(drawingEnd,
		ifsDrawData{
			f.image.Pix,
			f.width, f.height,
			data,
		})

	f.refreshUntilFinished(drawingEnd)
}

func drawUsingExecutor(endChan chan struct{}, data ifsDrawData) {
	task := drawingExecutor.Submit(func(taskData interface{}, threadName string, taskID uint64) interface{} {
		drawPixelArrayEncapsulated(taskData.(ifsDrawData))
		return true
	}, data)

	waitForTaskFinish(&task)
	close(endChan)
}

type ifsDrawData struct {
	pixelArray    []uint8
	width, height uint32
	drawData      *DrawData
}

func drawPixelArrayEncapsulated(data ifsDrawData) {
	drawPixelArray(
		data.pixelArray,
		data.width,
		data.height,
		data.drawData.LoopCount,
		data.drawData.Scale,
		data.drawData.IfsTable,
	)
}

func waitForTaskFinish(future *executor.Future) {
	future.Get()
}

func (f *Fractal) refreshUntilFinished(drawingEnd chan struct{}) {
	fpsTicker := time.NewTicker(time.Second / fps)
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

func drawPixelArray(pixelArray []uint8, width, height, loopCount uint32, scale float32, ifsTable [4][7]float32)
