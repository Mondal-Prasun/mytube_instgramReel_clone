package main

import (
	"log"
	"net/http"
	"os"
)

const (
	serverPort string = "SERVER_ADDR"
	redisAddr  string = "REDIS_ADDR"
)

func main() {

	sPort := os.Getenv(serverPort)

	serverMux := http.NewServeMux()

	http.ListenAndServe(sPort, serverMux)

}
