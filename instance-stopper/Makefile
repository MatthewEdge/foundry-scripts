BINARY := app
LAMDBA_ZIP := function.zip

.PHONY: dist
dist:
	GOOS=linux CGO_ENABLED=0 go build -o ${BINARY} main.go
	zip ./function.zip ${BINARY}
	chmod 644 ${LAMDBA_ZIP}

.PHONY: clean
clean:
	rm -f ${LAMDBA_ZIP}
	rm ${BINARY}

