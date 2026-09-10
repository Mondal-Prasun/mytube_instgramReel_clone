package api

import (
	"encoding/json"
	"net/http"
)

type Response struct {
	w http.ResponseWriter
}

type ResponseCode int

const (
	RES_OK           ResponseCode = 200
	RES_ERROR        ResponseCode = 302
	RES_SERVER_ERROR ResponseCode = 500
	RES_BAD_GATEWAY  ResponseCode = 502
)

func (r *Response) Success(stausCode ResponseCode, data any) {

	payload, err := json.Marshal(data)

	if err != nil {
		r.Error(RES_SERVER_ERROR, "Cannot parse payload")
		return
	}

	r.w.WriteHeader(int(stausCode))

	r.w.Write(payload)

}

func (r *Response) Error(statusCode ResponseCode, err string) {
	r.w.WriteHeader(int(statusCode))
	r.w.Write([]byte(err))
}
