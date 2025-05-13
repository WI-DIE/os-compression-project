#!/bin/bash

INPUT=$1
OUTPUT=$2
BINARY="./compressor"
LOGFILE="full_log.txt"

if [ ! -f "$INPUT" ]; then
  echo "❌ 입력 파일 '$INPUT' 이 존재하지 않습니다."
  exit 1
fi

# 이전 로그 제거
rm -f "$OUTPUT" "$LOGFILE"

echo -e "\n▶ 프로그램 실행 + 전체 리소스 측정 결과 (time -v)\n"

# 1회차: 실제 실행 (환경 변수 STRACE_CHILD 없음 → print_thread_count 실행됨)
{ /usr/bin/time -v $BINARY "$INPUT" "$OUTPUT"; } 2>&1 | tee "$LOGFILE"

# 1회차 로그에서 핵심 요약 뽑기
echo -e "\n=== 내부 성능 측정 요약 ==="
grep -E "Command being timed|User time|System time|Elapsed|Maximum resident set size|Voluntary|Involuntary" "$LOGFILE"

# 2회차: 시스템콜 측정 (STRACE_CHILD=1 설정 → print_thread_count 건너뜀)
echo -e "\n▶ 시스템콜 측정 결과 (strace -c)\n"
STRACE_CHILD=1 strace -c $BINARY "$INPUT" "$OUTPUT"
