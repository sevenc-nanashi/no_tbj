package main

// import "fmt"
import (
	"os"
	"os/exec"
	"os/signal"
	"path"
	"strings"
	"syscall"
)

func main() {
	executable, _ := os.Executable()
	executable = strings.Replace(executable, "\\", "/", -1)
	trap := make(chan os.Signal, 1)
	signal.Notify(trap, syscall.SIGTERM, syscall.SIGHUP, syscall.SIGINT)
	go func() {
		<-trap
		// Do nothing
	}()
	args := os.Args
	base := executable[:len(executable)-4]
	args[0] = base
	directory := path.Dir(base)
	cmd := exec.Command(directory+"/../../../../../bin/ruby.exe", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Run()
}
