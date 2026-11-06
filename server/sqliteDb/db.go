package sqlitedb

import (
	"database/sql"

	_ "github.com/mattn/go-sqlite3"
	"golang.org/x/crypto/bcrypt"
)

type SqliteDb struct {
	dbPtr *sql.DB
}

type User struct {
	UserId       string `json:"UserId"`
	Username     string `json:"Username"`
	UserEmail    string `json:"UserEmail"`
	UserPassword string `json:"UserPassword"`
}

type VideoHLS struct {
	UserId         string `json:"UserId"`
	VidId          string `json:"VidId"`
	VidName        string `json:"VidName"`
	VidDes         string `json:"VideDes"`
	VidDestination string `json:"VidDestination"`
}

const (
	usersTable string = `CREATE TABLE IF NOT EXISTS Users (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    createdAt TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);`
	videoTable string = `CREATE TABLE IF NOT EXISTS Videos (
    id UUID PRIMARY KEY,
    userId UUID NOT NULL,
    VidName VARCHAR(255) NOT NULL,
    VidDes TEXT,
    videoUrl VARCHAR(255) NOT NULL,
    createdAt TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE
);`
	insertUser string = `INSERT INTO Users (id, name, email, password) VALUES (?, ?, ?, ?)`

	insertVideo string = `INSERT INTO Videos (id, userId, VidName, VidDes, videoUrl)
VALUES (?, ?, ?, ?, ?);`

	getVideos string = `SELECT * FROM Videos ORDER BY createdAt DESC;`
)

func InitSqliteDb() (*SqliteDb, error) {

	db, err := sql.Open("sqlite3", "./sqDb.db")

	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
 		return nil, err
	}

	if err = createTables(db); err != nil {
		return nil, err
	}

	return &SqliteDb{
		dbPtr: db,
	}, nil

}

func createTables(db *sql.DB) error {

	if _, err := db.Exec(usersTable); err != nil {
		return err
	}

	if _, err := db.Exec(videoTable); err != nil {
		return err
	}

	return nil
}

func (db *SqliteDb) InsertUser(user *User) error {

	byteHash, err := bcrypt.GenerateFromPassword([]byte(user.UserPassword), bcrypt.MinCost)

	if err != nil {
		return err
	}

	if _, err := db.dbPtr.Exec(insertUser, user.UserId, user.Username, user.UserEmail, string(byteHash)); err != nil {
		return err
	}

	return nil
}

func (db *SqliteDb) InsertVideoHLS(vidDet *VideoHLS) error {

	if _, err := db.dbPtr.Exec(insertVideo, vidDet.VidId, vidDet.UserId, vidDet.VidName, vidDet.VidDes, vidDet.VidDestination); err != nil {
		return err
	}

	return nil

}

func (db *SqliteDb) GetShortVideos() (*[]VideoHLS, error) {
	rowRes, err := db.dbPtr.Query(getVideos)

	if err != nil {
		return nil, err
	}

	defer rowRes.Close()

	var id, userId, VidName, VidDes, videoUrl, createdAt string

	videos := []VideoHLS{}

	for rowRes.Next() {
		err := rowRes.Scan(&id, &userId, &VidName, &VidDes, &videoUrl, &createdAt)
		if err != nil {
			return nil, err
		}

		videos = append(videos, VideoHLS{
			UserId:         userId,
			VidId:          id,
			VidName:        VidName,
			VidDes:         VidDes,
			VidDestination: videoUrl,
		})

	}

	return &videos, nil

}
