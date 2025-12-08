#!/bin/bash
set -e

JMETER_HOME="apache-jmeter-5.6.3"
JMX="$1"
VAULT="$2"

RUN_ID="${VAULT}-$(date +%Y%m%d-%H%M%S)"
RUN_DIR="results/${RUN_ID}"

mkdir -p "${RUN_DIR}"
cp -r data "${RUN_DIR}/data"
cp "${JMX}" "${RUN_DIR}/testplan.jmx"

sed -i 's#\\\\#/#g' "${RUN_DIR}/testplan.jmx"
sed -i 's#[A-Za-z]:/##g' "${RUN_DIR}/testplan.jmx"

for f in data/*; do
  name=$(basename "$f")
  xmlstarlet ed -L \
    -u "//stringProp[@name='filename' and contains(text(), '${name}')]" \
    -v "data/${name}" \
    "${RUN_DIR}/testplan.jmx" || true
done

ERR=0
grep -oP '(?<=<stringProp name="filename\">)[^<]+' "${RUN_DIR}/testplan.jmx" | while read file; do
  if [ ! -f "${RUN_DIR}/${file}" ]; then
    echo "Missing CSV: ${file}"
    ERR=1
  fi
done

if [ "$ERR" -eq 1 ]; then
  echo "CSV validation failed"
  exit 1
fi

"${JMETER_HOME}/bin/jmeter" -n \
  -t "${RUN_DIR}/testplan.jmx" \
  -l "${RUN_DIR}/results.jtl" \
  -j "${RUN_DIR}/jmeter.log" \
  -e -o "${RUN_DIR}/html"

echo "JMeter run completed for ${VAULT}"
