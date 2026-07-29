import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Particles
import Backend 1.0

Window {
    id: mainWindow
    width: 450
    height: 600
    visible: true
    title: "تطبيق تكبير الحروف"

    flags: Qt.Window | Qt.FramelessWindowHint

    property bool isClosing: false

    // استدعاء ملف الديزاين الإصدار السابع وتمرير حالة الشاشة
    GuiV072 {
        id: ui
        anchors.fill: parent
        // ربط خاصية الماكسيمايز بحالة الشاشة الفعلية
        isWindowMaximized: mainWindow.visibility === Window.Maximized
    }

    // ==========================================
    // التايمر اللي هيقفل البرنامج (5 ثواني)
    // ==========================================
    Timer {
        id: quitTimer
        interval: 5000
        onTriggered: mainWindow.close()
    }

    // ==========================================
    // نظام جزيئات النار محقون جوه واجهة الـ GUI
    // ==========================================
    ParticleSystem {
        id: fireSystem
        parent: ui.glassContainer
        anchors.fill: parent

        Wander { anchors.fill: parent; affectedParameter: Wander.Position; xVariance: 30; pace: 250 }

        ItemParticle {
            system: fireSystem
            delegate: Component {
                Rectangle {
                    id: flameRect
                    property real startSize: 15 + Math.random() * 25
                    width: startSize; height: startSize * 1.8; radius: width / 2
                    property var colors: ["#FFFFA0", "#FF8C00", "#FF4500", "#FF0000"]
                    color: colors[Math.floor(Math.random() * colors.length)]
                    opacity: 0.9; scale: 1.0; rotation: (Math.random() * 60) - 30

                    Component.onCompleted: flameAnim.start()

                    ParallelAnimation {
                        id: flameAnim
                        NumberAnimation { target: flameRect; property: "opacity"; to: 0.0; duration: 700 + Math.random() * 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: flameRect; property: "scale"; to: 0.1; duration: 800 }
                        NumberAnimation { target: flameRect; property: "rotation"; to: (Math.random() > 0.5 ? 60 : -60); duration: 800 }
                    }
                }
            }
        }

        Emitter {
            id: fireEmitter
            system: fireSystem
            width: parent.width; height: 30
            y: ui.clipWrapper.height - 15
            x: 0
            enabled: false
            emitRate: 250; lifeSpan: 900
            velocity: AngleDirection { angle: -90; angleVariation: 15; magnitude: 220; magnitudeVariation: 80 }
        }
    }

    // ==========================================
    // شاشة الوداع الزجاجية (تم جعلها ثابتة ومستقلة)
    // ==========================================
    Item {
        id: goodbyeContainer
        width: 360
        height: 480
        anchors.centerIn: parent // تثبيت في منتصف الشاشة
        visible: false
        opacity: 0
        scale: 0.5
        z: 10 // لضمان ظهورها فوق كل العناصر

        Rectangle {
            id: goodbyeMaskRect
            anchors.fill: parent
            radius: 15; color: "black"; visible: false; layer.enabled: true
        }

        ShaderEffectSource {
            id: goodbyeEffectSource
            sourceItem: ui.bgImage
            anchors.fill: parent
            // كود مبسط جداً لأنها بقت ثابتة في الشاشة
            sourceRect: Qt.rect(goodbyeContainer.x, goodbyeContainer.y, goodbyeContainer.width, goodbyeContainer.height)
            visible: false
        }

        MultiEffect {
            source: goodbyeEffectSource
            anchors.fill: parent
            blurEnabled: true; blurMax: 64; blur: 0.5
            maskEnabled: true; maskSource: goodbyeMaskRect
            shadowEnabled: true; shadowBlur: 1.0; shadowOpacity: 0.4; shadowVerticalOffset: 10; shadowHorizontalOffset: 0; shadowColor: "#000000"
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(1.0, 0.2, 0.2, 0.2)
            radius: 15
            border.color: Qt.rgba(1.0, 0.2, 0.2, 0.5); border.width: 1

            Text {
                text: "GOODBYE"
                color: "white"; font.pixelSize: 46; font.bold: true; anchors.centerIn: parent
                MultiEffect { source: parent; anchors.fill: parent; shadowEnabled: true; shadowColor: "black"; shadowBlur: 0.5; shadowOpacity: 0.8 }
            }
        }
    }

    // ==========================================
    // أنيميشن الحرق وظهور الوداع
    // ==========================================
    SequentialAnimation {
        id: burnAnimation

        ScriptAction { script: { fireEmitter.enabled = true } }

        ParallelAnimation {
            NumberAnimation { target: ui.glassEffect; property: "colorization"; to: 0.8; duration: 400 }
            NumberAnimation { target: ui.glassEffect; property: "brightness"; to: 0.5; duration: 400 }
        }

        ParallelAnimation {
            NumberAnimation { target: ui.clipWrapper; property: "height"; to: 0; duration: 2500; easing.type: Easing.InQuad }
            ColorAnimation { target: ui.glassEffect; property: "colorizationColor"; to: "#000000"; duration: 2500 }
            NumberAnimation { target: ui.mainShadowEffect; property: "opacity"; to: 0; duration: 1500 }
        }

        ScriptAction { script: { fireEmitter.enabled = false } }

        PauseAnimation { duration: 300 }

        onFinished: {
            ui.clipWrapper.visible = false
            goodbyeContainer.visible = true
            goodbyeAnimation.start()
        }
    }

    ParallelAnimation {
        id: goodbyeAnimation
        NumberAnimation { target: goodbyeContainer; property: "opacity"; to: 1.0; duration: 800; easing.type: Easing.OutCubic }
        NumberAnimation { target: goodbyeContainer; property: "scale"; to: 1.0; duration: 800; easing.type: Easing.OutBack }
    }

    // ==========================================
    // الإيفينت الجديد الخاص بالدبل كليك على التايتل بار
    // ==========================================
    Connections {
        target: ui
        function onTitleDoubleClicked() {
            if (mainWindow.visibility === Window.Maximized) {
                mainWindow.showNormal()
            } else {
                mainWindow.showMaximized()
            }
        }
    }

    // ==========================================
    // ربط زراير الـ Title Bar
    // ==========================================
    Connections {
        target: ui.closeButton
        function onClicked() {
            if (!isClosing) {
                isClosing = true
                burnAnimation.start()
                quitTimer.start()
            }
        }
    }

    Connections {
        target: ui.maximizeButton
        function onClicked() {
            if (mainWindow.visibility === Window.Maximized) {
                mainWindow.showNormal()
            } else {
                mainWindow.showMaximized()
            }
        }
    }

    Connections {
        target: ui.minimizeButton
        function onClicked() {
            mainWindow.showMinimized()
        }
    }

    // ==========================================
    // الباك إيند
    // ==========================================
    Connections {
        target: Bridge
        function onResultChanged(result) {
            ui.resultText = result
        }
    }

    Connections {
        target: ui.actionButton
        function onClicked() {
            Bridge.processText(ui.inputText)
        }
    }
}
