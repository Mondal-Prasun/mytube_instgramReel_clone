package api

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	sqlitedb "github.com/Mondal-Prasun/mytube_instgramReel_clone/server/sqliteDb"
	"github.com/google/uuid"
)

const (
	maxFileSize int64 = 32 << 10
)

type Api struct {
	SqliteDb      *sqlitedb.SqliteDb
	UploadFolder  string
	ProcessFolder string
	JobQueue      chan VidJob
}

func (a *Api) CheckHealth(w http.ResponseWriter, r *http.Request) {

	res := Response{
		w: w,
	}

	if r.Method != http.MethodGet {
		res.Error(RES_BAD_GATEWAY, "cant get the api")
		return
	}

	res.Success(RES_OK, struct {
		Message string `json:"Message"`
	}{
		Message: "Healthy",
	})

}

func (a *Api) AddUser(w http.ResponseWriter, r *http.Request) {
	res := Response{
		w: w,
	}

	if r.Method != http.MethodPost {
		res.Error(RES_BAD_GATEWAY, "no api found")
		return
	}

	var user sqlitedb.User

	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		res.Error(RES_ERROR, "Invalid json")
		return
	}

	userId, err := uuid.NewV7()

	if err != nil {
		res.Error(RES_SERVER_ERROR, "Something went wrong")
		return
	}

	user.UserId = userId.String()

	if err := a.SqliteDb.InsertUser(&user); err != nil {
		res.Error(RES_SERVER_ERROR, fmt.Sprintf("Cannot create new user %v ", err))
		return
	}

	jwtToken, err := generateJWT(&user)

	if err != nil {
		res.Error(RES_SERVER_ERROR, fmt.Sprintf("Cannot create token %v", err))
		return
	}

	res.Success(RES_OK, struct {
		Token string `json:"Token"`
	}{
		Token: jwtToken,
	})

}

func (a *Api) UploadVideo(w http.ResponseWriter, r *http.Request) {

	res := Response{w: w}

	if r.Method != http.MethodPost {
		res.Error(RES_BAD_GATEWAY, "no api found")
		return
	}

	user, ok := r.Context().Value(userDetContextKey).(*sqlitedb.User)

	log.Println(user)

	if !ok {
		res.Error(RES_ERROR, "Cannot get user details")
		return
	}

	userId := user.UserId

	if err := r.ParseMultipartForm(maxFileSize); err != nil {
		res.Error(RES_ERROR, "Excedded max file size")
		return
	}

	vName := r.FormValue("VideoName")

	if vName == "" {
		res.Error(RES_ERROR, "Cannot find VideoName")
		return
	}

	vDes := r.FormValue("VideoDes")

	if vDes == "" {
		res.Error(RES_ERROR, "Cannot find VideoDes")
		return
	}

	vf, vh, err := r.FormFile("VideoFile")

	if err != nil {
		res.Error(RES_ERROR, "Cannot find VideoFile")
		return
	}

	defer vf.Close()

	uploadPath, err := a.writeToUploadFolder(vf, vh, userId)

	if err != nil {
		res.Error(RES_SERVER_ERROR, "Cannot upload video")
		return
	}

	vidId, err := uuid.NewV7()

	if err != nil {
		res.Error(RES_SERVER_ERROR, "Cannot upload video")
		return
	}

	resChan := make(chan Result, 1)

	vidJob := VidJob{
		UserId:     userId,
		JobId:      vidId.String(),
		UploadPath: uploadPath,
		VidName:    vName,
		VidDes:     vDes,
		ResultChan: resChan,
	}

	a.JobQueue <- vidJob

	select {
	case result := <-vidJob.ResultChan:

		if !result.Success {
			res.Error(RES_SERVER_ERROR, fmt.Sprintf("Cannot segment video %v", result.Error.Error()))
			return
		}

		res.Success(RES_OK, "Upload done!")

	case <-r.Context().Done():
		log.Println("Client disconnected ")
	}

}

func (a *Api) writeToUploadFolder(file multipart.File, stat *multipart.FileHeader, userId string) (path string, uploadErr error) {

	uploadFileDir := fmt.Sprintf("%v/%v", a.UploadFolder, userId)

	err := os.MkdirAll(uploadFileDir, os.ModeDir)

	if err != nil {
		return "", err
	}

	uploadPath := fmt.Sprintf("%v/%v/%v", a.UploadFolder, userId, stat.Filename)

	f, err := os.Create(uploadPath)

	if err != nil {
		return "", err
	}

	defer f.Close()

	_, err = io.Copy(f, file)

	if err != nil {
		return "", err
	}

	return uploadPath, nil

}

func (a *Api) CorsMiddleware(next http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Handle OPTIONS preflight before auth checks
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	}
}

func (a *Api) StreamHLSVideo(w http.ResponseWriter, r *http.Request) {
	res := Response{
		w: w,
	}

	if strings.HasSuffix(r.URL.Path, ".m3u8") {
		res.w.Header().Set("Content-Type", "application/x-mpegURL")
	} else if strings.HasSuffix(r.URL.Path, ".ts") {
		res.w.Header().Set("Content-Type", "video/mp2t")
	}

	baseDir := a.ProcessFolder

	cleanPath := filepath.Clean(r.URL.Path)

	filePath := filepath.Join(baseDir, cleanPath)

	log.Printf("Video file path: %v", filePath)

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		res.Error(RES_ERROR, "Video not found")
		return
	}

	http.ServeFile(w, r, filePath)

}
