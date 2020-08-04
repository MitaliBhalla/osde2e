#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"/..; pwd)
OSDE2E=quay.io/app-sre/osde2e
HUGO=klakegg/hugo:0.74.3-ext 

run_osde2e() {
	WEATHER_PROVIDER=$1 JOB_ALLOWLIST="osde2e-.*-$1-e2e-.*" docker run -u "$(id -u)" -v "$DIR:/hugo-site" -e WEATHER_PROVIDER -e JOB_ALLOWLIST -e PROMETHEUS_ADDRESS -e PROMETHEUS_BEARER_TOKEN "$OSDE2E" weather-report --output "/hugo-site/content/post/$(uuidgen | sed s/-//g).md" --outputType sd-report
}

docker pull $OSDE2E
docker pull $HUGO

run_osde2e aws
run_osde2e gcp
run_osde2e moa

docker run -u $(id -u) -v "$DIR:/hugo-site" $HUGO -s /hugo-site --cleanDestinationDir

git remote add origin git@github.com:openshift/osde2e.git
git push -u origin gh-pages
git add "$DIR"
git commit -m "Weather report generation at $(date)"
git push
