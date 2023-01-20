FROM golang:1.19 as builder
WORKDIR /code

COPY main.go .
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY *.go ./

# `skaffold debug` sets SKAFFOLD_GO_GCFLAGS to disable compiler optimizations
ARG SKAFFOLD_GO_GCFLAGS
RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -trimpath -o /app main.go

FROM gcr.io/distroless/base-debian10
# Define GOTRACEBACK to mark this container as using the Go language runtime
# for `skaffold debug` (https://skaffold.dev/docs/workflows/debug/).
ENV GOTRACEBACK=single
EXPOSE 80
CMD ["./app"]
COPY --from=builder /app .
