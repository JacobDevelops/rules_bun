package handler_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/example/api/internal/handler"
)

func TestHealthz(t *testing.T) {
	h := handler.New()
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("want 200, got %d", rec.Code)
	}
}
