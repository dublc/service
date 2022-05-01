FROM golang:1.18 as build_sales-api
ENV CGO_ENABLED 0
ARG BUILD_REF

COPY . /service
WORKDIR /service
RUN go build -ldflags "-X main.build=$BUILD_REF"

FROM alpine:3.15
COPY --from=build_sales-api /service/service /service/service
WORKDIR /service
CMD ["./service"]
