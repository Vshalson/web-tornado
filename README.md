# web-tornado
Recon workflow automation

## To Build Docker container image
```bash
$ git clone https://github.com/Vshalson/web-tornado.git

$ cd web-tornado

# Following process will take 15 minutes
$ docker build -t "web-tornado:v0.4" .

# To run Basic scan on domain
$ docker run -it -v /tmp/check:/loot "web-tornado:v0.4" -b domain.com

# To run Full scan on domain
$ docker run --rm -e AWS_ACCESS_KEY_ID=my-key-id -e AWS_SECRET_ACCESS_KEY=my-secret-access-key -v /tmp/check:/loot "web-tornado:v0.4"  -b domain.com
```

## Preparation 
Update `WHOOK` variable with discord webhook in ./attacks/full.sh and ./attacks/basic.sh


## Tools and Online Service we Use
* Corsy
* Striker
* discord.sh
* SecretFinder.py
* ffuf
* waybackurls
* gau
* crt.sh
* certspotter
* alienvault.com
* bufferover.run
* amass
* subfinder
* hakrawler
* corsy 