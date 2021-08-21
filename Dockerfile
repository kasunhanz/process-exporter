FROM golang:1.16-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o /process_exporter
RUN apk add lsof

EXPOSE 8080

CMD [ "/process_exporter" ]