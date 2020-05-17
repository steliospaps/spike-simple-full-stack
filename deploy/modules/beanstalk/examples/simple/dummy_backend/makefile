.PHONY: clean help
.DEFAULT: help
## see https://devhints.io/makefile
## see https://gist.github.com/prwhite/8168133
help:     ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
clean:    ## cleanup temporary files
	@rm -rf target

target:
	mkdir target

target/mockserver-netty-5.10.0-jar-with-dependencies.jar: | target
	cd target && curl http://search.maven.org/remotecontent?filepath=org/mock-server/mockserver-netty/5.10.0/mockserver-netty-5.10.0-jar-with-dependencies.jar -LOJ

target/Procfile: | target
	echo web: java -Dmockserver.livenessHttpGetPath="/" -jar ./mockserver-netty-5.10.0-jar-with-dependencies.jar -serverPort 5000 > target/Procfile

target/beanstalk.zip: target/mockserver-netty-5.10.0-jar-with-dependencies.jar target/Procfile
	cd target && zip -u beanstalk.zip mockserver-netty-5.10.0-jar-with-dependencies.jar Procfile

build: target/beanstalk.zip ## build the deployment in the target directory
