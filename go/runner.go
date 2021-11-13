package main

// import "fmt"
import (
	"os"
	"os/exec"
	"path"
	"strings"
)

func main() {
	executable, _ := os.Executable()
	executable = strings.Replace(executable, "\\", "/", -1)
	args := os.Args
	base := executable[:len(executable)-3]
	args[0] = base
	directory := path.Dir(base)
	cmd := exec.Command(directory+"/ruby.exe", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Run()
}
