# RW-Builder

**RW-Builder v1.1.0**

리얼월드2022 에 사용되는 LUA 번들러입니다.
```cs
[ 무엇 ]
fxmanifest.lua의
- shared_script(s)
- server_script(s)
- client_script(s)
- file(s)
에 나열된 모든 파일을 각각 하나의 파일로 합칩니다.
```
```cs
[ 추후 추가 예정 ]
- LUA 난독화 추가
- 파일 압축 기능 추가
- 빌드 실행 명령어 추가
- 프레임워크별 맞춤 기능 추가
```
```
[ v1.1.0 업데이트 ]
- dist의 fxmanifest.lua 자동 생성
- 파일 경로의 *, ** 지원
(예시: client/**/* 또는 client/* 의 단순 표기만 지원)
(test_*.lua, *.* 등은 미지원합니다.)
- 주석 제거 On/Off
- 파일 헤더 삽입 On/Off
```
