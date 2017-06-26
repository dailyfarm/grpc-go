#!/usr/bin/env bash
echo $TRAVIS_GO_VERSION
echo $TRAVIS_COMMIT_RANGE
IFS='...' read -r -a commits <<< "$TRAVIS_COMMIT_RANGE"
echo "base commit number:"
echo ${commits[0]}
echo "current commit number:"
echo ${commits[-1]}

if [[ $TRAVIS_GO_VERSION = 1.8* ]]; then
  if [ -d "benchmark/compare" ]; then
    echo "dir benchmark/compare exist"
    go get -d -v -t google.golang.org/grpc/...

    cp benchmark/compare/main.go tmpmain
    cp -r benchmark/stats benchmark/tmpstats
    cp benchmark/benchmark17_test.go benchmark/tmp17test

    go test google.golang.org/grpc/benchmark/... -benchmem -bench=BenchmarkClient/Unary-Tracing-kbps_0-MTU_0-maxConcurrentCalls_1 | tee benchmark/compare/result1
    ls benchmark/compare/
    git reset --hard ${commits[0]}
    ls benchmark/compare/
    if [ -e "benchmark/compare/main.go" ]; then
      echo "after reset: dir benchmark/compare exist"
    else
      mv benchmark/tmpstats benchmark/stats
      mv benchmark/tmp17test benchmark/benchmark17_test.go 
      mv benchmark/compare/tmpmain benchmark/compare/main.go
    fi
    go test google.golang.org/grpc/benchmark/... -benchmem -bench=BenchmarkClient/Tracing-kbps_0-MTU_0-maxConcurrentCalls_1 | tee benchmark/compare/result2
    go run benchmark/compare/main.go benchmark/compare/result1 benchmark/compare/result2
  fi
fi
