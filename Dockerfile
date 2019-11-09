ARG GO_VERSION

FROM golang:${GO_VERSION}-stretch

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF
ARG DOCKERFILE_PATH
ARG JSONNET_VERSION
ARG GOLANGCILINT_VERSION

RUN apt-get update -y && apt-get install -y g++ make git && \
    rm -rf /var/lib/apt/lists/*
RUN curl -Lso - https://github.com/google/jsonnet/archive/v${JSONNET_VERSION}.tar.gz | \
    tar xfz - -C /tmp && \
    cd /tmp/jsonnet-${JSONNET_VERSION} && \
    make && mv jsonnetfmt /usr/local/bin && \
    rm -rf /tmp/jsonnet-${JSONNET_VERSION}

RUN GO111MODULE=on go get github.com/google/go-jsonnet/cmd/jsonnet@v${JSONNET_VERSION}
RUN GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@v${GOLANGCILINT_VERSION}
RUN GO111MODULE=on go get github.com/brancz/gojsontoyaml
RUN GO111MODULE=on go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
RUN GO111MODULE=on go get -u github.com/raviqqe/liche
RUN GO111MODULE=on go get -u github.com/rakyll/gotest
RUN GO111MODULE=on go get -u github.com/campoy/embedmd

FROM golang:${GO_VERSION}-stretch
COPY --from=0 /usr/local/bin/jsonnetfmt /bin
COPY --from=0 /go/bin/jsonnet /bin
COPY --from=0 /go/bin/golangci-lint /bin
COPY --from=0 /go/bin/gojsontoyaml /bin
COPY --from=0 /go/bin/jb /bin
COPY --from=0 /go/bin/liche /bin
COPY --from=0 /go/bin/gotest /bin
COPY --from=0 /go/bin/embedmd /bin

LABEL vendor="kakkoyun" \
    name="kakkoyun/go-jsonnet-ci" \
    description="A container image to easy things up with the CI." \
    maintainer="Kemal Akkoyun <kakkoyun@gmail.com>" \
    version="$VERSION" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.description="A container image to easy things up with the CI." \
    org.label-schema.docker.cmd="docker run kakkoyun/docker-go-jsonnet-ci" \
    org.label-schema.docker.dockerfile=$DOCKERFILE_PATH \
    org.label-schema.name="kakkoyun/docker-go-jsonnet-ci" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/kakkoyun/docker-go-jsonnet-ci" \
    org.label-schema.vendor="kakkoyun/docker-go-jsonnet-ci" \
    org.label-schema.version=$VERSION
