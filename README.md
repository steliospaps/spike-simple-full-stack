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


# build
## requirements

- maven
- java11
- node

## instructions

```
(cd src/backend && ./mvnw clean package)
(cd src/frontend && npm install && npm run build)
```

# deployment

## local

```
cd src/backend && ./mvnw clean spring-boot:run
#in another window
cd src/frontend && node start
```
