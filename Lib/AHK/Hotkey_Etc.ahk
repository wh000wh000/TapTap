/*
    탭탭이(TapTap)에서 사용할 "한 글자" 핫키 설정
    영문자는 대문자만 핫키로 사용.
    모든 Hotkey에는 "핫키" 한(1) 자가 "인자"로 전달됨.
*/

; 핫키 호출 함수
; 기능: TapTap이로부터 인자를 받아 영문자 핫키를 호출함.
Hotkey_Etc:
{
    arg := A_Args[1]

    hotkeyFunc := Func("Hotkey_" . arg)

    %hotkeyFunc%(arg)
}

; Hotkey: 'A' 키
; 기능: 인사하기 테스트
Hotkey_A(option) {
    greeting := "안녕하세요!, 반갑습니다~ 탭탭이입니다!`n`n이 창은 5초 후 사라집니다.`n`n"

    if (option)
        msg := greeting . "명령어 인자: " . option
    else
        msg := greeting
    MsgBox,  , 인사 대화 창 ('%option%'), %msg%, 5
}
