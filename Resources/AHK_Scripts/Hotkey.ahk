; 탭탭이(TapTap)에서 사용할 "한 글자" 핫키 설정
;    영문자는 대문자만 핫키로 사용.
;
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
