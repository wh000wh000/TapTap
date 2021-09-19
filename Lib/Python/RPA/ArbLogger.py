import datetime
import logging, logging.handlers


class WidgetLogger(logging.Handler):
    def __init__(self, targetWidget):
        super().__init__()
        self.target_widget = targetWidget

    def emit(self, record):
        msg = f'{record.getMessage()} < {record.levelname} {record.module}.{record.funcName}:{record.lineno} '
        self.target_widget.appendPlainText(msg)


class ArbLogger:
    '''ARB Logger'''

    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_ArbLogger__singleton'):
            cls.__singleton = super().__new__(cls)
        return cls.__singleton

    def __init__(self):
        cls = type(self)
        if not hasattr(cls, '_ArbLogger__init'):
            cls.__init = True
            super().__init__()
            self.set_logger()   # 로그 인스턴스 환경 설정을 셋팅함

    def add_widget_logger(self, targetWidget):
        if not hasattr(self, 'widget_logger'):
            self.widget_logger = None
        if not self.widget_logger:
            self.widget_logger = WidgetLogger(targetWidget)
            fomatter = logging.Formatter('[%(levelname)s|%(lineno)s] %(asctime)s > %(message)s')
            self.widget_logger.setFormatter(fomatter)
            self.logger.addHandler(self.widget_logger)
    
    def remove_widget_logger(self):
        if self.widget_logger:
            self.logger.removeHandler(self.widget_logger)
            self.widget_logger = None

    def set_logger(self):   # 로그 환경을 설정해주는 함수
        # self.logger = logging.getLogger()  # Roiot 로그 인스턴스
        self.logger = logging.getLogger('ARB_Logger')
        # 로그를 남길 방식으로 "[로그레벨|라인번호] 날짜 시간,밀리초 > 메시지" 형식의 포매터를 만든다
        streamFomatter = logging.Formatter('%(message)s < %(levelname)s %(module)s.%(funcName)s:%(lineno)s %(asctime)s.%(msecs)03d', datefmt='%I:%M:%S')
        fileFomatter = logging.Formatter('%(asctime)s.%(msecs)03d %(module)s.%(funcName)s:%(lineno)s %(levelname)s\n%(message)s', datefmt='%y/%m/%d %H:%M:%S')
        # 로그 파일 네임에 들어갈 날짜를 만듬 (%Y: YYYYmmdd 형태, %y:YYmmdd 형태)
        logday = datetime.date.today().strftime("%y%m%d")
        fileMaxByte = 1024 * 1024 * 100  # 파일 최대 용량인 100MB를 변수에 할당 (100MB, 102,400KB)
        # 파일에 로그를 출력하는 핸들러 (100MB가 넘으면 최대 10개까지 신규 생성)
        fileHandler = logging.handlers.RotatingFileHandler(f'Log_{str(logday)}.log', mode='w', maxBytes=fileMaxByte, backupCount=10)
        # 콘솔에 로그를 출력하는 핸들러
        streamHandler = logging.StreamHandler()
        fileHandler.setFormatter(fileFomatter)
        streamHandler.setFormatter(streamFomatter)
        self.logger.addHandler(fileHandler)
        self.logger.addHandler(streamHandler)
        self.logger.setLevel(logging.DEBUG)  # 로그 레벨을 디버그로 만듬

        