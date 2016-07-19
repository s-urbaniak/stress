package main

import (
	"flag"
	"os"
	"runtime"
	"sync"
	"time"

	"golang.org/x/net/context"
)

var (
	flagP       = flag.Int("p", runtime.NumCPU(), "run `N` processes in parallel")
	flagTimeout = flag.Duration("timeout", 10*time.Minute, "timeout each process after `duration`")
)

func main() {
	flag.Parse()
	ctx, cancel := context.WithCancel(context.Background())

	var wg sync.WaitGroup
	wg.Add(*flagP)

	for i := 0; i < *flagP; i++ {
		go func() {
			runtime.LockOSThread() // spend an OS thread for this stresser loop

			for {
				select {
				case <-ctx.Done():
					wg.Done()
					return
				default:
				}
			}
		}()
	}

	time.Sleep(*flagTimeout)
	cancel()
	wg.Wait()
	os.Exit(0)
}
