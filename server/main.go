package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/Mondal-Prasun/mytube_instgramReel_clone/server/api"
	sqlitedb "github.com/Mondal-Prasun/mytube_instgramReel_clone/server/sqliteDb"
)

const (
	serverPort string = "SERVER_ADDR"

	uploadDirectory      string = "./upload"
	processJobsDirectory string = "./processJobs"
)

func main() {

	sPort := os.Getenv(serverPort)

	checkDirectories()

	sqliteDb, err := sqlitedb.InitSqliteDb()

	if err != nil {
		log.Panicf("Cannot open db %v \n", err)
	}

	api := api.Api{
		SqliteDb:      sqliteDb,
		UploadFolder:  uploadDirectory,
		ProcessFolder: processJobsDirectory,
	}

	api.ProcessJobs()

	serverMux := http.NewServeMux()

	serverMux.HandleFunc("/checkHealth", api.CheckHealth)
	serverMux.HandleFunc("/signUp", api.AddUser)

	serverMux.Handle("/secure/uploadVideo", api.JWTMiddleware(http.HandlerFunc(api.UploadVideo)))
	serverMux.Handle("/hls/", api.CorsMiddleware(api.JWTMiddleware(http.StripPrefix("/hls/", http.HandlerFunc(api.StreamHLSVideo)))))

	log.Println("Server running at : " + sPort)

	http.ListenAndServe(sPort, serverMux)

}

func checkDirectories() {

	directories := []string{uploadDirectory, processJobsDirectory}

	for _, dir := range directories {

		_, err := os.Stat(dir)

		if os.IsNotExist(err) {
			fmt.Printf("%v is does not exsist \n", dir)
			fmt.Printf("Creating %v directory \n", dir)
			err = os.Mkdir(dir, os.ModeDir)
			if err != nil {
				panic(err)
			}

		}
	}
}
