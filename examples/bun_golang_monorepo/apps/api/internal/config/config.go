package config

import "os"

// Config holds runtime configuration loaded from the environment.
type Config struct {
	Addr string
}

// Load returns a Config populated from environment variables with sensible defaults.
func Load() Config {
	addr := os.Getenv("ADDR")
	if addr == "" {
		addr = ":8080"
	}
	return Config{Addr: addr}
}
