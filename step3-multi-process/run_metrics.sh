#!/bin/bash

INPUT=$1
OUTPUT=$2
NUM_PROC=$3
BINARY="./compressor"
LOGFILE="full_log.txt"

if [ ! -f "$INPUT" ]; then
  echo "❌ 입력 파일 '$INPUT' 이 존재하지 않습니다."
  exit 1
fi

if [ -z "$NUM_PROC" ]; then
  echo "❌ 사용법: $0 <입력파일> <출력파일> <프로세스 수>"
  exit 1
fi

# 이전 출력/로그 삭제
rm -f "$OUTPUT" "$LOGFILE"

echo -e "\n▶ 1. 프로그램 실행 + 전체 리소스 측정 결과 (time -v)\n"

# 1회차 실행 (print_thread_count 포함됨)
{ /usr/bin/time -v $BINARY "$INPUT" "$OUTPUT" "$NUM_PROC"; } 2>&1 | tee "$LOGFILE"

echo -e "\n=== 내부 성능 측정 요약 ==="
grep -E "Command being timed|User time|System time|Elapsed|Maximum resident set size|Voluntary|Involuntary" "$LOGFILE"

echo -e "\n▶ 2. 시스템콜 측정 결과 (strace -c)\n"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "(Linux 환경에서 strace 사용)"
  STRACE_CHILD=1 strace -c $BINARY "$INPUT" "$OUTPUT" "$NUM_PROC"
else
  echo "⚠️ 시스템콜 분석은 현재 OS에서 지원되지 않습니다."
fi
