# RW-Builder

**RW-Builder v1.1.0**

- 홈페이지: https://www.realw.kr<br>
- 디스코드: https://discord.gg/realw<br>
- 유튜브채널: https://www.youtube.com/realw<br>

### 소개 및 기능
```cs
리얼월드2022 에 사용되는 FiveM LUA 번들러입니다.

fxmanifest.lua 의
- shared_script(s)
- server_script(s)
- client_script(s)
- file(s)

에 나열된 모든 파일을 각각 하나의 파일로 합칩니다.
```

### 설정 구성
```diff
+ Config.insertFileHeader (boolean)
병합된 파일에 개별 파일에 대한 정보를 표시합니다.

+ Config.removeComments (boolean)
병합된 파일에 모든 주석을 제거합니다.

+ Config.basePath (string)
프로젝트 루트 경로 입니다.

+ Config.baseResPath (string)
프로젝트 리소스 경로 입니다.

+ Config.srcResPath (string)
소스 리소스 파일 경로 입니다.

+ Config.distResPath (string)
빌드될 리소스 파일 경로 입니다.

+ Config.resDistDirPath (string)
빌드된 파일이 위치할 경로 입니다.

+ Config.manifestMatadataEntries (array)
메니페스트에서 복제될 항목들 입니다.

+ Config.manifestMatadataEntryMultipleName (array)
메니페트스 항목의 복수형 이름 입니다.

```

### 추후 추가 예정
```cs
- LUA 난독화 추가
- 파일 압축 기능 추가
- 빌드 실행 명령어 추가
- 프레임워크별 맞춤 기능 추가
```

### 업데이트

#### - v1.1.0 업데이트
```
- dist의 fxmanifest.lua 자동 생성
- 파일 경로의 *, ** 지원
(예시: client/**/* 또는 client/* 의 단순 표기만 지원)
(test_*.lua, *.* 등은 미지원합니다.)
- 주석 제거 On/Off
- 파일 헤더 삽입 On/Off
```
