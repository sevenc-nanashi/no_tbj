package main

// import "fmt"
import (
	"os"
	"os/exec"
)

func main() {
	executable, _ := os.Executable()
	args := os.Args
	base := executable[:len(executable)-3]
	args[0] = base
	cmd := exec.Command("ruby", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Run()
}
