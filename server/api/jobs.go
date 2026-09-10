package api

import (
	"log"

	sqlitedb "github.com/Mondal-Prasun/mytube_instgramReel_clone/server/sqliteDb"
	vidps "github.com/Mondal-Prasun/mytube_instgramReel_clone/server/vidPs"
)

type VidJob struct {
	UserId     string
	JobId      string
	UploadPath string
	VidName    string
	VidDes     string
	ResultChan chan Result
}

type Result struct {
	Success bool
	Error   error
}

const (
	workerNumber uint8 = 3
)

func (a *Api) workOnJob(job *VidJob) {

	outputFolder := a.ProcessFolder + "/" + job.JobId

	if err := vidps.HLSsegmentGenerate(outputFolder, job.UploadPath); err != nil {
		job.ResultChan <- Result{
			Success: false,
			Error:   err,
		}
		return
	}

	if err := a.SqliteDb.InsertVideoHLS(&sqlitedb.VideoHLS{
		VidId:          job.JobId,
		UserId:         job.UserId,
		VidName:        job.VidName,
		VidDes:         job.VidDes,
		VidDestination: outputFolder,
	}); err != nil {

		job.ResultChan <- Result{
			Success: false,
			Error:   err,
		}
		return
	}

	job.ResultChan <- Result{
		Success: true,
		Error:   nil,
	}

}

func (a *Api) ProcessJobs() {

	a.JobQueue = make(chan VidJob, 100)

	for i := range workerNumber {
		go func(workerId uint8) {
			for job := range a.JobQueue {
				log.Printf("Woker number is :%v \n", workerId)
				a.workOnJob(&job)
			}
		}(i)
	}

}
