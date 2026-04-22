package main

import (
	"log"
	"net/http"

	"github.com/example/api/internal/config"
	"github.com/example/api/internal/handler"
)

func main() {
	cfg := config.Load()
	h := handler.New()
	log.Printf("listening on %s", cfg.Addr)
	log.Fatal(http.ListenAndServe(cfg.Addr, h))
}
