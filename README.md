# about
This is a simple frontend that talks to a backend jar.
I use it to investigate various deployment ways
## components
### frontend
a simple app that uses the backed and displays the result.
### backend
Cors enabled for everywhere (for now)
```
curl -X POST localhost:8080/echo -d '{"request":"world"}' -H "Content-Type: application/json" --silent |jq
{
  "response": "hello world"
}
```

# codebuild (aws)
## local
see https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/



# build local
## requirements

- maven
- java 11
- node
- terraform
- gnu make

## instructions

```
(cd src/backend && ./mvnw clean package )
(cd src/frontend && npm install && npm run build)
```

when you run the server locally use something like:
```
curl -d '{"request":"hello"}' http://localhost:5000/echo -H 'Content-Type:application/json'
```
to test
# deployment

## local

```
cd src/backend && ./mvnw clean spring-boot:run
#in another window
cd src/frontend && node start
```
## terraform
see [readme](./deploy/README.md) for initialization instructions
### api gateway

```
( cd deploy/api-gateway-s3-eb
 && terraform apply)

(cd src/backend && make ebdeploy)

(cd src/frontend && make deploy)
#this outputs the url
#the backend deploy might take some time to finish
#use curl to check when it is back up
```
