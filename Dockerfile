FROM golang:1.12-stretch

ARG JSONNET_VERSION
ARG PROMTOOL_VERSION
ARG GOLANGCILINT_VERSION

RUN apt-get update -y && apt-get install -y g++ make git jq gawk python-yaml && \
    rm -rf /var/lib/apt/lists/*
RUN curl -Lso - https://github.com/google/jsonnet/archive/v${JSONNET_VERSION}.tar.gz | \
    tar xfz - -C /tmp && \
    cd /tmp/jsonnet-${JSONNET_VERSION} && \
    make && mv jsonnetfmt /usr/local/bin && \
    rm -rf /tmp/jsonnet-${JSONNET_VERSION}

RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnet@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCILINT_VERSION}
RUN GO111MODULE=on go get github.com/prometheus/prometheus/cmd/promtool@v${PROMTOOL_VERSION}

FROM golang:1.12-stretch
COPY --from=0 /usr/local/bin/jsonnetfmt /bin
COPY --from=0 /go/bin/jsonnet /bin
COPY --from=0 /go/bin/golangci-lint /bin
COPY --from=0 /go/bin/promtool /bin
