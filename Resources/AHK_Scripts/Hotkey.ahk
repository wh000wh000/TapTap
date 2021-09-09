#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.

; 탭탭이(TapTap)에서 사용할 "한 글자" 핫키 설정
;    영문자는 대문자만 핫키로 사용.
;
; 숫자 핫키 테스트
::T_Hotkey_1::
인사말 := "안녕하세요, 탭탭입니다!"
MsgBox, , 인사, %인사말%, 5
return

; 탭탭이 종료
::T_Hotkey_Q::   ; 'Q'키 Hotkey
ExitApp
return

; 탭탭이 재 실행
::T_HotKey_R::   ; 'R'키 Hotkey
Reload
return

; 탭탭이(TapTap) 핫키
;Control::   ; Control 키 Hotkey
Alt::       ; Alt 키 Hotkey
;Shift::     ; Shift 키 Hotkey
ShowAliasRunBox() ; 탭탭이 별칭 입력창(Alias Run Box) 보이기
return

; CapsLock 키 변경 to LControl by KeyTweak
; CapsLock Toggle 키 (CapsLock + 우측 Shift)
>+LControl::
SetCapsLockState % !GetKeyState("CapsLock", "T")
return

; 탭탭이 기동 시, 자동 실행
::T_OnTapTapBoot::
new Watch() ; 색시 시계
new ScreenSaver()   ; 마우스 포인터를 화면 좌상단(0, 0) 으로 가져가면 화면 보호기 실행
return

; Hotkey 용 파일 Include
#Include, Resources\AHK_Scripts\Watch.ahk
#Include, Resources\AHK_Scripts\ScreenSaver.ahk
