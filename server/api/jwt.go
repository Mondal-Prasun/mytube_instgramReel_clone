package api

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	sqlitedb "github.com/Mondal-Prasun/mytube_instgramReel_clone/server/sqliteDb"
	"github.com/golang-jwt/jwt/v5"
)

type JwtClaims struct {
	UserName  string `json:"UserName"`
	UserId    string `json:"UserId"`
	UserEmail string `json:"UserEmail"`
	jwt.RegisteredClaims
}

type UserDetContextKey string

const (
	userDetContextKey UserDetContextKey = "UserDetContectKey"
)

var jwtKey []byte = []byte("SUPER_SECRET_KEY")

func generateJWT(user *sqlitedb.User) (jwtToken string, err error) {

	log.Println("generating user token....")

	jwtClaim := &JwtClaims{
		UserName:  user.Username,
		UserEmail: user.UserEmail,
		UserId:    user.UserId,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwtClaim)

	tokenString, err := token.SignedString(jwtKey)

	if err != nil {
		return "", err
	}

	return tokenString, nil

}

func parseJwt(tokenString string) (*sqlitedb.User, error) {
	var jwtClaim JwtClaims

	token, err := jwt.ParseWithClaims(tokenString, &jwtClaim, func(t *jwt.Token) (any, error) {

		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected siging method %v ,", t.Header["alg"])
		}

		return jwtKey, nil
	})

	if err != nil || !token.Valid {
		return nil, err
	}

	return &sqlitedb.User{
		UserId:    jwtClaim.UserId,
		Username:  jwtClaim.UserName,
		UserEmail: jwtClaim.UserEmail,
	}, nil

}

func (a *Api) JWTMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		res := Response{
			w: w,
		}

		var authHeader string

		if authHeader = r.Header.Get("Authorization"); authHeader == "" {
			if authHeader = r.URL.Query().Get("token"); authHeader == "" {
				res.Error(RES_ERROR, "Missing Authorization Header")
				return
			}
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			http.Error(w, "Invalid Authorization format", http.StatusUnauthorized)
			return
		}
		tokenString := parts[1]

		user, err := parseJwt(tokenString)

		if err != nil {
			res.Error(RES_SERVER_ERROR, "Cannot parse jwt token")
			return
		}

		ctx := context.WithValue(r.Context(), userDetContextKey, user)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
