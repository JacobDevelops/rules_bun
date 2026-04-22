package handler

import (
	"encoding/json"
	"net/http"
)

// Handler is the root HTTP handler for the API.
type Handler struct {
	mux *http.ServeMux
}

// New constructs a Handler with all routes registered.
func New() *Handler {
	h := &Handler{mux: http.NewServeMux()}
	h.mux.HandleFunc("GET /healthz", h.healthz)
	return h
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.mux.ServeHTTP(w, r)
}

func (h *Handler) healthz(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"}) //nolint:errcheck
}
