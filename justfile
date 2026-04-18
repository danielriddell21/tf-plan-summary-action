binary := "bin/tf-plan-summary"

# build to bin/tf-plan-summary
build:
    go build -o {{ binary }} .

# run bash test suite
test:
    bash scripts/test.sh

# install unum then build and run tests
ci:
    go install github.com/danielriddell21/unum/cmd/unum@latest
    just test

# install binary to GOPATH/bin
install:
    go install .

# remove build artifacts
clean:
    rm -rf bin/
