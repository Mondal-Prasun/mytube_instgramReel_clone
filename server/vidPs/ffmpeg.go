package vidps

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
)

func HLSsegmentGenerate(outputFolder string, uploadedPath string) error {

	if err := os.MkdirAll(outputFolder, os.ModeDir); err != nil {
		log.Println("Cannot make " + outputFolder)
		return err
	}

	segmentFilePath := fmt.Sprintf("%v/segment_%%03d.ts", outputFolder)

	outPutM3U8FilePath := fmt.Sprintf("%v/output.m3u8", outputFolder)

	cmd := exec.Command(
		"ffmpeg", "-i", uploadedPath,
		"-vf", "crop=ih*(9/16):ih,scale=1080:1920",
		"-c:v", "libx264", "-crf", "20", "-preset", "ultrafast", "-g", "48", "-keyint_min", "48", "-sc_threshold", "0",
		"-c:a", "aac", "-b:a", "128k",
		"-f", "hls",
		"-hls_time", "4",
		"-hls_playlist_type", "vod",
		"-hls_segment_filename", segmentFilePath,
		outPutM3U8FilePath,
	)

	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		log.Printf("Cannot generate HLS Segmentation: %v | Stderr: %s\n", err, stderr.String())
		return err
	}

	return nil

}
