#Golang docker
FROM golang as builder
RUN go get -u github.com/tomnomnom/waybackurls && go get -u github.com/ffuf/ffuf && go get -u github.com/sensepost/gowitness && go get -u github.com/lc/gau && go get -u github.com/tomnomnom/httprobe && GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder && GO111MODULE=on go get -v -u github.com/OWASP/Amass && go get github.com/hakluke/hakrawler && go get -u github.com/tomnomnom/anew

#Node docker
FROM node:buster as builder2
WORKDIR /builder2
RUN npm install broken-link-checker


FROM ubuntu:bionic
LABEL maintainer="vshalson"
RUN apt-get update && apt-get install -y git nano whois wget curl jq vim python3 python3-pip nodejs npm build-essential && pip3 install requests requests_file jsbeautifier lxml

COPY --from=builder /go/bin/* /usr/local/bin/
COPY --from=builder2  /builder2 /builder2
COPY . /tornado

RUN mkdir /loot

ENTRYPOINT ["/bin/bash", "/tornado/attacks/options.sh"] 
