/*
    탭탭이(TapTap)에서 사용할 "한 글자" 핫키 설정
    영문자는 대문자만 핫키로 사용.
    Hotkey: '1' 키
    기능: 인사하기
*/

인사 := "안녕하세요, 탭탭이입니다!`n`n이 창은 5초 후 사라집니다.`n`n"

msg := 인사 . "명령어 인자:"
if (A_Args) {
    for index, arg in A_Args {
        msg .= " " . arg
    }
}
msg .= "`n"

MsgBox,  , 인사 대화 창, %인사%, 5
