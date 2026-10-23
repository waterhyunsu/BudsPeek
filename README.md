> 한국어 안내는 아래에 있습니다.

# BudsPeek

BudsPeek is an open-source macOS menu bar companion for checking and controlling Samsung Galaxy Buds. It aims to bring the quick, native status experience Mac users expect from AirPods to Galaxy Buds.

> **Project status:** Early development. Battery reporting, noise control, and EQ changes have been verified on a MacBook Air with Galaxy Buds3 Pro (SM-R630). Other models and firmware versions still need testing.

## Features

- Native SwiftUI menu bar interface that condenses to a compact status header while connected.
- Bluetooth discovery and Samsung's RFCOMM/SPP control channel.
- Left, right, and charging-case battery readings.
- Quick controls for noise cancellation, ambient sound, and off, plus EQ presets.
- A C++17 protocol core for SPP frame encoding/decoding and CRC-16/CCITT.

The charging case reports its battery through an earbud. Keep at least one earbud in the open case when checking the case level; the case may not report a value while both earbuds are out.

## Compatibility

- macOS 14 or later.
- Apple Silicon Mac. The current build script targets `arm64`.
- Galaxy Buds3 Pro (SM-R630) is the initial hardware target and the only model verified so far. Other models may be detected, but are not yet validated.
- Pair the earbuds with macOS first. BudsPeek uses Bluetooth for the Samsung control channel; audio continues to use the normal macOS Bluetooth connection.

## Build and run

Install Xcode Command Line Tools, clone the repository, then run:

```sh
./build-app.sh
open build/BudsPeek.app
```

On first launch, allow Bluetooth access when macOS asks. In VS Code, **Terminal → Run Build Task** runs the same build script. The script creates an unsigned local app bundle; there is no signed/notarized release package yet.

## Project layout

```text
Sources/BudsPeek/          SwiftUI app, Bluetooth manager, models, diagnostics
Sources/BudsPeekCore/      C++17 SPP framing and CRC implementation
Packaging/                 macOS app Info.plist
ThirdParty/                 Third-party license and attribution notices
build-app.sh                Local arm64 app bundle build
```

## Open-source and trademarks

BudsPeek is distributed under the MIT License. Some Bluetooth, model, diagnostics, and firmware-support code is derived from Budsy; its MIT license and attribution are included in [`ThirdParty/`](ThirdParty/NOTICE.md). The firmware support code is not exposed as a user feature in this early release.

BudsPeek is an independent, unofficial project and is not affiliated with, endorsed by, or sponsored by Samsung or Apple. Galaxy Buds, Samsung, and Apple are trademarks of their respective owners. Product names are used only to describe compatibility.

## Contributing

Bug reports and pull requests are welcome. Please include your Mac model, macOS version, earbud model and firmware version, and the steps to reproduce an issue. Remove personal information before sharing diagnostic output.

---

# BudsPeek (한국어)

BudsPeek은 Samsung Galaxy Buds의 상태를 확인하고 제어하는 오픈소스 macOS 메뉴 막대 앱입니다. Mac에서 AirPods를 연결할 때처럼 빠르고 자연스러운 상태 확인 경험을 Galaxy Buds에도 제공하는 것을 목표로 합니다.

> **프로젝트 상태:** 초기 개발 단계입니다. MacBook Air와 Galaxy Buds3 Pro(SM-R630) 조합에서 배터리 표시, 소음 제어, EQ 변경을 확인했습니다. 다른 모델과 펌웨어 버전은 추가 검증이 필요합니다.

## 기능

- 연결 중에는 간결한 상태 막대로 줄어드는 SwiftUI 메뉴 막대 화면
- Bluetooth 기기 검색 및 Samsung RFCOMM/SPP 제어 채널 연결
- 왼쪽·오른쪽 이어버드와 케이스 배터리 표시
- 노이즈 캔슬링, 주변 소리, 끄기 빠른 제어와 EQ 프리셋 선택
- SPP 패킷 인코딩·디코딩과 CRC-16/CCITT를 처리하는 C++17 프로토콜 코어

케이스는 이어버드를 통해 배터리 상태를 전달합니다. 케이스 잔량을 확인할 때는 이어버드 하나 이상을 케이스에 넣고 뚜껑을 열어 주세요. 이어버드가 모두 케이스 밖에 있으면 케이스 값이 오지 않을 수 있습니다.

## 호환성

- macOS 14 이상
- Apple Silicon Mac (현재 빌드 스크립트는 `arm64` 대상)
- 첫 번째 지원 목표는 Galaxy Buds3 Pro(SM-R630)이며, 현재 실제 확인을 마친 모델도 이 모델뿐입니다. 다른 모델은 검색될 수 있지만 동작을 검증하지 않았습니다.
- 먼저 macOS Bluetooth 설정에서 버즈를 페어링해 주세요. BudsPeek은 Samsung 제어 채널에 Bluetooth를 사용하고, 오디오는 macOS의 일반 Bluetooth 연결을 사용합니다.

## 빌드 및 실행

Xcode Command Line Tools를 설치하고 저장소를 내려받은 뒤 실행합니다.

```sh
./build-app.sh
open build/BudsPeek.app
```

처음 실행할 때 macOS Bluetooth 접근을 허용해 주세요. VS Code에서는 **Terminal → Run Build Task**로 동일한 빌드 스크립트를 실행할 수 있습니다. 스크립트는 로컬 실행용 서명되지 않은 앱을 만들며, 아직 서명·공증된 배포 패키지는 제공하지 않습니다.

## 프로젝트 구조

```text
Sources/BudsPeek/          SwiftUI 앱, Bluetooth 관리자, 모델, 진단
Sources/BudsPeekCore/      C++17 SPP 프레임 및 CRC 구현
Packaging/                 macOS 앱 Info.plist
ThirdParty/                 제3자 라이선스 및 저작자 표시
build-app.sh                로컬 arm64 앱 빌드 스크립트
```

## 오픈소스 및 상표

BudsPeek은 MIT License로 배포합니다. Bluetooth 통신, 모델, 진단 및 펌웨어 지원 코드 일부는 Budsy에서 파생되었습니다. 해당 MIT 라이선스와 저작자 표시는 [`ThirdParty/`](ThirdParty/NOTICE.md)에 포함되어 있습니다. 초기 버전에서 펌웨어 지원 코드는 사용자 기능으로 제공하지 않습니다.

BudsPeek은 독립적인 비공식 프로젝트이며 Samsung 또는 Apple과 제휴·승인·후원을 받지 않습니다. Galaxy Buds, Samsung, Apple은 각 권리자의 상표이며, 제품명은 호환성을 설명하기 위한 목적으로만 사용합니다.

## 기여

버그 제보와 Pull Request를 환영합니다. 제보할 때 Mac 모델, macOS 버전, 이어버드 모델과 펌웨어 버전, 재현 단계를 적어 주세요. 진단 정보를 공유하기 전에는 개인 정보를 제거해 주세요.
