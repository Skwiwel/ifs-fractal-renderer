package main

import (
	"fmt"
	"os"

	platforms "github.com/skwiwel/ifs-fractal-maker/internal/platforms"
	renderers "github.com/skwiwel/ifs-fractal-maker/internal/renderers"

	"github.com/inkyblackness/imgui-go/v2"
)

func main() {
	context := imgui.CreateContext(nil)
	defer context.Destroy()
	io := imgui.CurrentIO()

	platform, err := platforms.NewGLFW(io, platforms.GLFWClientAPIOpenGL3)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(-1)
	}
	defer platform.Dispose()

	renderer, err := renderers.NewOpenGL3(io)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(-1)
	}
	defer renderer.Dispose()
}
