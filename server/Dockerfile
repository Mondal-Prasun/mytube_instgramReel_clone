# Step 1: Build stage using Alpine
FROM golang:alpine AS builder

# Install GCC and musl-dev needed for CGO in Alpine
RUN apk add --no-cache gcc musl-dev

WORKDIR /app

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

# Build with CGO enabled
RUN CGO_ENABLED=1 GOOS=linux go build -o server .

# Step 2: Runtime stage
FROM alpine:latest

# Install runtime dependencies (gcc is not needed in runtime)
RUN apk add --no-cache ffmpeg ca-certificates

WORKDIR /app

COPY --from=builder /app/server .

EXPOSE 8080

CMD ["./server"]
