import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    width: 450
    height: 600

    property alias inputText: inputField.text
    property alias resultText: resultLabel.text
    property alias actionButton: actionBtn

    // Aliases for the Title Bar buttons
    property alias closeButton: closeBtn
    property alias maximizeButton: maxBtn
    property alias minimizeButton: minBtn

    // Aliases للتحكم من ملف الـ main
    property alias clipWrapper: clipWrapper
    property alias glassEffect: glassEffect
    property alias mainShadowEffect: mainShadowEffect
    property alias glassContainer: glassContainer
    property alias bgImage: bgImage
    property alias scrollArea: scrollArea
    property alias titleBar: titleBar

    // خصائص جديدة لمعرفة حالة الشاشة وإرسال إشارة الدبل كليك
    property bool isWindowMaximized: false
    signal titleDoubleClicked()

    Image {
        id: bgImage
        anchors.fill: parent
        source: "image.png"
        fillMode: Image.PreserveAspectCrop
    }

    // ==========================================
    // Custom Title Bar (3D Blue Jeans + Fabric Texture)
    // ==========================================
    Item {
        id: titleBar
        width: parent.width
        height: 40
        anchors.top: parent.top
        z: 100

        // 1. Drop Shadow الخارجي
        Rectangle {
            id: titleShadowRect
            anchors.fill: parent
            color: "black"
            visible: false
        }

        MultiEffect {
            source: titleShadowRect
            anchors.fill: titleShadowRect
            shadowEnabled: true
            shadowBlur: 1.0
            shadowOpacity: 0.6
            shadowVerticalOffset: 5
            shadowHorizontalOffset: 0
            shadowColor: "#000000"
        }

        // 2. تصميم قماش الجينز الأزرق مع النسيج
        Rectangle {
            id: jeansBackground
            anchors.fill: parent
            clip: true

            // التدرج اللوني الأساسي
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#4B7CB3" }
                GradientStop { position: 0.3; color: "#2A5283" }
                GradientStop { position: 0.8; color: "#1C3A60" }
                GradientStop { position: 1.0; color: "#11243D" }
            }

            // --- طبقة نسيج القماش (Fabric Texture) ---
            Canvas {
                id: fabricTexture
                anchors.fill: parent
                // تم زيادة الشفافية هنا عشان النسيج يظهر بقوة على لينكس
                opacity: 0.45

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.lineWidth = 1;
                    ctx.clearRect(0, 0, width, height); // تنظيف قبل الرسم

                    // رسم خيوط النسيج الفاتحة (بزاوية)
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
                    ctx.beginPath();
                    for (var i = -width; i < width * 2; i += 4) {
                        ctx.moveTo(i, 0);
                        ctx.lineTo(i + height, height);
                    }
                    ctx.stroke();

                    // رسم خيوط النسيج الغامقة (بالزاوية العكسية عشان يدي شكل التقاطع)
                    ctx.strokeStyle = "rgba(0, 0, 0, 0.7)";
                    ctx.beginPath();
                    for (var j = -width; j < width * 2; j += 4) {
                        ctx.moveTo(j, height);
                        ctx.lineTo(j + height, 0);
                    }
                    ctx.stroke();
                }

                // إجبار الكانفاس على الرسم بمجرد التحميل (لحل مشكلة عدم ظهوره في لينكس)
                Component.onCompleted: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }

            // إضاءة الحافة العلوية لزيادة التجسيم
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: "#8AB6EB"
                opacity: 0.6
            }

            // ظل الحافة السفلية لزيادة التجسيم
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: "#050A12"
                opacity: 0.8
            }

            // خطوط الخياطة العلوية
            Row {
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 5
                spacing: 4
                clip: true
                Repeater {
                    model: Math.max(0, Math.floor(parent.width / 8))
                    Rectangle { width: 4; height: 1.5; color: "#D4A373"; opacity: 0.8 }
                }
            }

            // خطوط الخياطة السفلية
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 5
                spacing: 4
                clip: true
                Repeater {
                    model: Math.max(0, Math.floor(parent.width / 8))
                    Rectangle { width: 4; height: 1.5; color: "#D4A373"; opacity: 0.7 }
                }
            }

            // MouseArea لاستقبال الدبل كليك على التايتل بار
            MouseArea {
                anchors.fill: parent
                onDoubleClicked: root.titleDoubleClicked()
            }

            // أزرار التحكم
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                z: 2

                Button {
                    id: minBtn
                    width: 20
                    height: 20
                    padding: 0
                    background: Rectangle {
                        color: minBtn.pressed ? "#11243D" : (minBtn.hovered ? "#4B7CB3" : "transparent")
                        radius: 4
                        border.color: minBtn.hovered ? "#8AB6EB" : "transparent"
                        border.width: 1
                        Rectangle {
                            width: 10
                            height: 2
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                }

                Button {
                    id: maxBtn
                    width: 20
                    height: 20
                    padding: 0
                    background: Rectangle {
                        color: maxBtn.pressed ? "#11243D" : (maxBtn.hovered ? "#4B7CB3" : "transparent")
                        radius: 4
                        border.color: maxBtn.hovered ? "#8AB6EB" : "transparent"
                        border.width: 1

                        Item {
                            width: 10
                            height: 10
                            anchors.centerIn: parent

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "white"
                                border.width: 1
                                visible: !root.isWindowMaximized
                            }

                            Item {
                                anchors.fill: parent
                                visible: root.isWindowMaximized
                                Rectangle {
                                    x: 2; y: 0; width: 8; height: 8
                                    color: "transparent"
                                    border.color: "white"
                                    border.width: 1
                                }
                                Rectangle {
                                    x: 0; y: 2; width: 8; height: 8
                                    color: maxBtn.pressed ? "#11243D" : (maxBtn.hovered ? "#4B7CB3" : "#2A5283")
                                    border.color: "white"
                                    border.width: 1
                                }
                            }
                        }
                    }
                }

                Button {
                    id: closeBtn
                    width: 20
                    height: 20
                    padding: 0
                    background: Rectangle {
                        color: closeBtn.pressed ? "#8B0000" : (closeBtn.hovered ? "#ff6666" : "#E53935")
                        radius: 4
                        border.color: closeBtn.hovered ? "#ffb3b3" : "transparent"
                        border.width: 1
                        Text {
                            text: "×"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -2
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // Main Scroll Area & Glass Container
    // ==========================================
    Flickable {
        id: scrollArea
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: parent.width
        contentHeight: 1500
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        function centerView() {
            Qt.callLater(function() {
                if (!scrollArea.moving && !scrollArea.dragging) {
                    scrollArea.contentX = (scrollArea.contentWidth - scrollArea.width) / 2;
                    scrollArea.contentY = (scrollArea.contentHeight - scrollArea.height) / 2;
                }
            });
        }

        Component.onCompleted: centerView()
        onHeightChanged: centerView()

        Item {
            id: glassContainer
            width: 360
            height: 480

            property real baseX: (scrollArea.contentWidth - width) / 2
            property real baseY: (scrollArea.contentHeight - height) / 2

            onBaseXChanged: { if (!dragArea.pressed && !returnX.running) x = baseX }
            onBaseYChanged: { if (!dragArea.pressed && !returnY.running) y = baseY }
            Component.onCompleted: { x = baseX; y = baseY }

            property real dx: x - baseX
            property real dy: y - baseY

            SpringAnimation { id: returnX; target: glassContainer; property: "x"; to: glassContainer.baseX; spring: 4.0; damping: 0.18 }
            SpringAnimation { id: returnY; target: glassContainer; property: "y"; to: glassContainer.baseY; spring: 4.0; damping: 0.18 }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                z: -1
                drag.target: glassContainer
                drag.axis: Drag.XAndYAxis
                onPressed: { returnX.stop(); returnY.stop() }
                onReleased: { returnX.start(); returnY.start() }
            }

            transform: [
                Scale {
                    origin.x: glassContainer.width / 2
                    origin.y: glassContainer.height / 2
                    xScale: dragArea.pressed ? 0.97 : 1.0
                    yScale: dragArea.pressed ? 0.97 : 1.0
                    Behavior on xScale { SpringAnimation { spring: 4.0; damping: 0.2 } }
                    Behavior on yScale { SpringAnimation { spring: 4.0; damping: 0.2 } }
                },
                Rotation {
                    origin.x: glassContainer.width / 2
                    origin.y: glassContainer.height / 2
                    axis { x: 1; y: 0; z: 0 }
                    angle: dragArea.pressed ? (glassContainer.dy * -0.05) : (scrollArea.movingVertically ? Math.max(-25, Math.min(25, scrollArea.verticalVelocity * 0.015)) : 0)
                    Behavior on angle { SpringAnimation { spring: 3.0; damping: 0.1 } }
                },
                Rotation {
                    origin.x: glassContainer.width / 2
                    origin.y: glassContainer.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: dragArea.pressed ? (glassContainer.dx * 0.05) : (scrollArea.movingHorizontally ? Math.max(-25, Math.min(25, scrollArea.horizontalVelocity * -0.015)) : 0)
                    Behavior on angle { SpringAnimation { spring: 3.0; damping: 0.1 } }
                }
            ]

            Rectangle {
                id: mainShadowRect
                anchors.fill: parent
                radius: 15
                color: "black"
                visible: false
            }

            MultiEffect {
                id: mainShadowEffect
                source: mainShadowRect
                anchors.fill: mainShadowRect
                shadowEnabled: true
                shadowBlur: 1.0
                shadowOpacity: 0.4
                shadowVerticalOffset: 10
                shadowHorizontalOffset: 0
                shadowColor: "#000000"
            }

            ShaderEffectSource {
                id: effectSource
                sourceItem: bgImage
                anchors.fill: parent
                sourceRect: Qt.rect(glassContainer.x - scrollArea.contentX,
                                    (glassContainer.y - scrollArea.contentY) + titleBar.height,
                                    glassContainer.width, glassContainer.height)
                visible: false
            }

            Item {
                id: clipWrapper
                width: parent.width
                height: parent.height
                anchors.top: parent.top
                clip: true

                Item {
                    width: glassContainer.width
                    height: glassContainer.height
                    anchors.top: parent.top

                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: 15
                        color: "black"
                        visible: false
                        layer.enabled: true
                    }

                    MultiEffect {
                        id: glassEffect
                        source: effectSource
                        anchors.fill: parent
                        blurEnabled: true
                        blurMax: 64
                        blur: 0.5
                        maskEnabled: true
                        maskSource: maskRect
                        colorization: 0.0
                        colorizationColor: "#FF4500"
                        brightness: 0.0
                    }

                    Rectangle {
                        id: glassTint
                        anchors.fill: parent
                        color: Qt.rgba(1.0, 0.2, 0.2, 0.2)
                        radius: 15
                        border.color: Qt.rgba(1.0, 0.2, 0.2, 0.5)
                        border.width: 1

                        ColumnLayout {
                            id: formLayout
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 0

                            Item { Layout.fillHeight: true }

                            TextField {
                                id: inputField
                                placeholderText: "Enter text here..."
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "black"
                                font.pixelSize: 16
                                background: Rectangle {
                                    color: "#fffaea"
                                    radius: 8
                                    border.color: "#e6d583"
                                    border.width: 1
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Button {
                                id: actionBtn
                                text: "Solve"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                hoverEnabled: true
                                scale: pressed ? 0.98 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                contentItem: Text {
                                    text: actionBtn.text
                                    font.pointSize: 18
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: actionBtn.hovered ? "#ffea00" : "#ffffff"
                                    layer.enabled: actionBtn.hovered
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true
                                        shadowColor: "#ffea00"
                                        shadowBlur: 0.8
                                    }
                                }
                                background: Item {
                                    Rectangle {
                                        id: btnBg
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        radius: 8
                                        visible: false
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: actionBtn.pressed ? "#1565c0" : "#64b5f6" }
                                            GradientStop { position: 1.0; color: actionBtn.pressed ? "#0a3478" : "#1976d2" }
                                        }
                                        border.color: actionBtn.hovered ? "#ffea00" : "#0a3478"
                                        border.width: actionBtn.hovered ? 2 : 1
                                    }
                                    MultiEffect {
                                        anchors.fill: btnBg
                                        source: btnBg
                                        shadowEnabled: true
                                        shadowColor: "#80000000"
                                        shadowBlur: actionBtn.pressed ? 0.3 : 0.8
                                        shadowHorizontalOffset: actionBtn.pressed ? 1 : 3
                                        shadowVerticalOffset: actionBtn.pressed ? 1 : 4
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                id: resultContainer
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                radius: 8
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#fff9c4" }
                                    GradientStop { position: 1.0; color: "#fff59d" }
                                }
                                border.color: "#fbc02d"
                                border.width: 1
                                clip: true
                                Text {
                                    text: resultLabel.text
                                    font: resultLabel.font
                                    color: "white"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 1.5
                                    anchors.horizontalCenterOffset: 1
                                }
                                Text {
                                    text: resultLabel.text
                                    font: resultLabel.font
                                    color: "black"
                                    opacity: 0.6
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -1.5
                                    anchors.horizontalCenterOffset: -1.5
                                }
                                Text {
                                    id: resultLabel
                                    text: "Result"
                                    font.pointSize: 22
                                    font.bold: true
                                    color: "black"
                                    visible: false
                                    anchors.centerIn: parent
                                }
                                Rectangle {
                                    id: gradientMaskSrc
                                    anchors.fill: resultLabel
                                    visible: false
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#777777" }
                                        GradientStop { position: 0.5; color: "#000000" }
                                        GradientStop { position: 1.0; color: "#888888" }
                                    }
                                }
                                MultiEffect {
                                    anchors.fill: resultLabel
                                    source: gradientMaskSrc
                                    maskEnabled: true
                                    maskSource: resultLabel
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }
}
