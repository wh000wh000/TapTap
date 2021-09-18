#
# 탭탭이(TapTap)에서 테스트할 파이썬 Hello World 파일
#
import tkinter
import sys


def quit_greeting():
    """인사 대화 창 종료"""
    window.quit()


인사 = "\n안녕하세요!, 반갑습니다~ 탭탭이입니다!\n\n" \
       "이 창은 5초 후 사라집니다.\n\n"
인자 = ""
for arg in sys.argv:
    if not 인자:
        인자 = arg
    else:
        인자 += " " + arg
인사말 = 인사 + "명령어 인자: " + 인자

window = tkinter.Tk()
window.title("인사 대화 창")
window.geometry("500x200+400+400")
label=tkinter.Label(window, text=인사말)
label.pack()

window.after(5000, quit_greeting)

window.mainloop()
