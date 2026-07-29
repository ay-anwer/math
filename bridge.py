import requests
from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtQml import QmlElement, QmlSingleton

QML_IMPORT_NAME = "Backend"
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

@QmlElement
@QmlSingleton
class Bridge(QObject):
    resultChanged = Signal(str, arguments=['result'])

    @Slot(str)
    def processText(self, text):
        try:
            response = requests.post("http://127.0.0.1:8000/process", json={"text": text})
            if response.status_code == 200:
                result = response.json().get("result")
                self.resultChanged.emit(result)
        except Exception as e:
            print("خطأ في الاتصال:", e)
