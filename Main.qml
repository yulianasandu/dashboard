import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import Automotive.Core 1.0

Window {
    id: root
    width: 1920
    height: 720
    visible: true
    title: "Lada Vesta Dashboard"
    color: "#0c0c0e"

    CarController { id: carController }

    FontLoader {
        id: eurostileFont
        source: "fonts/eurostile.ttf"
    }

    // ── фон ─────────────────────────────────────────────────────────────────
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: "#0c0c0e"
        gradient: RadialGradient {
            centerX: root.width * 0.5; centerY: root.height * 0.46
            centerRadius: root.width * 0.62
            focalX: centerX; focalY: centerY
            GradientStop { position: 0.0;  color: "#2c2c31" }
            GradientStop { position: 0.35; color: "#1c1c20" }
            GradientStop { position: 0.65; color: "#131316" }
            GradientStop { position: 1.0;  color: "#080809" }
        }
    }
    // ── тень слева и справа (уход в края, как на референсе) ────────────────
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: parent.width * 0.16
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: parent.width * 0.16
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }
    // ── чёрные края сверху/снизу ───────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.height * 0.22
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: parent.height * 0.22
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }

    // ── клавиши ─────────────────────────────────────────────────────────────
    // Восстанавливаем фокус при возврате в окно после другого приложения
    onActiveChanged: {
        console.log("WINDOW active =", active)

        if (active) keyScope.forceActiveFocus()
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.isAutoRepeat)
                return

            const key = event.text.toLowerCase()

            if ("wц".includes(key))
                carController.setThrottle(true)

            else if ("sы".includes(key))
                carController.setBrake(true)

            else if ("aф".includes(key))
                carController.toggleLeftBlinker()

            else if ("dв".includes(key))
                carController.toggleRightBlinker()

            else if ("fа".includes(key))
                carController.toggleHazard()

            else if (event.key === Qt.Key_1) {
                tachZone.oilWarning = !tachZone.oilWarning
                tachZone.engineWarning = !tachZone.engineWarning
                tachZone.batteryWarning = !tachZone.batteryWarning
                rightZone.lightWarning = !rightZone.lightWarning
            }
        }

        Keys.onReleased: function(event) {
            if (event.isAutoRepeat)
                return

            const key = event.text.toLowerCase()

            if ("wц".includes(key))
                carController.setThrottle(false)

            else if ("sы".includes(key))
                carController.setBrake(false)
        }
    }

    Component.onCompleted: {
        console.log("Font name:", eurostileFont.name)
        keyScope.forceActiveFocus()

        console.log(
            "After startup:",
            keyScope.focus,
            keyScope.activeFocus
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ВЕРХНЯЯ ПОЛОСА
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 50

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 75 }
            Image {
                source: "qrc:/qt/qml/dashboard/icons/turn_left.svg"
                width: 32; height: 32
                fillMode: Image.PreserveAspectFit
                opacity: carController.leftBlinkerOn ? 1.0 : 0.05
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 3 }
            text: "▲  АВАРИЙНАЯ"
            color: "#ff3518"
            font { pixelSize: 17; bold: true; family: eurostileFont.name }
            visible: carController.leftBlinker && carController.rightBlinker
            opacity: carController.leftBlinkerOn ? 1.0 : 0.07
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 5 }
            text: "W — ГАЗ    S — ТОРМОЗ    A, D — ПОВОРОТНИКИ    F — АВАРИЙКА  1 - ИКОНКИ"
            color: "#3d3d4f"
            font { pixelSize: 12; family: eurostileFont.name; letterSpacing: 1.6 }
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 70 }
            Image {
                source: "qrc:/qt/qml/dashboard/icons/turn_right.svg"
                width: 32; height: 32
                fillMode: Image.PreserveAspectFit
                opacity: carController.rightBlinkerOn ? 1.0 : 0.05
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: "#161620"
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ЗОНА ПРИБОРОВ
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: gaugesArea
        anchors {
            top: topBar.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
            topMargin: 2; bottomMargin: 2
        }

        // ── хромированный колодец ────────────────────────────────────────────
        component ChromeWell: Item {
            property real dialSize: 300

            // тонкая тёмная линия-разделитель между бортиком и циферблатом
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 13; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: parent.width * 0.34; centerY: parent.height * 0.22
                    centerRadius: parent.width * 0.62
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#f4f4f6" }
                    GradientStop { position: 0.2;  color: "#4c4c54" }
                    GradientStop { position: 0.5;  color: "#f4f4f6" }
                    GradientStop { position: 0.6;  color: "#4c4c54" }
                    GradientStop { position: 0.9;  color: "#f4f4f6" }
                    GradientStop { position: 1.0;  color: "#1f1e1e" }
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 6; height: width; radius: width / 2
                color: "#040404"
            }
            Rectangle {
                id: dialFace
                anchors.centerIn: parent
                width: dialSize; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: dialFace.width * 0.50; centerY: dialFace.height * 0.38
                    centerRadius: dialFace.width * 0.56
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#26262a" }
                    GradientStop { position: 0.48; color: "#131315" }
                    GradientStop { position: 1.0;  color: "#040404" }
                }
            }
        }

        // ── центральный колпак ───────────────────────────────────────────────
        component NeedleCap: Item {
            property real capSize: 80

            width: capSize
            height: capSize

            // внешнее хромированное кольцо
            Rectangle {
                anchors.fill: parent
                radius: width / 2

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#d0d0d0" }
                    GradientStop { position: 0.2; color: "#202020" }
                    GradientStop { position: 1.0; color: "#101010" }
                }
            }

            // внутренний черный диск
            Rectangle {
                anchors.centerIn: parent

                width: parent.width - 6
                height: width
                radius: width / 2

                gradient: RadialGradient {
                    centerX: width * 0.35
                    centerY: height * 0.25
                    centerRadius: width * 0.55

                    GradientStop { position: 0.0; color: "#2a2a2a" }
                    GradientStop { position: 0.3; color: "#141414" }
                    GradientStop { position: 1.0; color: "#050505" }
                }
            }
        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  ТАХОМЕТР  (левый)                                              ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: tachZone
            // Правый край тахометра заходит под спидометр на ~25% диаметра тахометра
            // x Item = центр_тахзоны - width/2
            // центр_тахзоны = speedCenter - speedRad - tachRad + overlap
            // overlap = tachDiam * 0.25
            // Проще: правый край тахзоны = speedCenter - speedRad + tachDiam*0.25
            // x = правый_край - width = speedCenter - speedRad + tachDiam*0.25 - width
            x: gaugesArea.width * 0.5 - speedZone.dialDiam * 0.5 + tachZone.dialDiam * 0.25 - tachZone.width
            y: 0
            width: gaugesArea.width * 0.35
            height: gaugesArea.height
            z: 0

            property bool oilWarning: false
            property bool engineWarning: false
            property bool batteryWarning: false

            property real dialDiam: Math.min(width, height) * 0.94
            property real dialRad:  dialDiam * 0.5
            property real rpmFraction: Math.min(carController.rpm / 7000.0, 1.0)
            property real needleAngle: -170.0 + rpmFraction * 248.0

            ChromeWell { anchors.centerIn: parent; dialSize: tachZone.dialDiam }

            Canvas {
                id: tachCanvas
                anchors.centerIn: parent
                width: tachZone.dialDiam; height: width
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width * 0.5, cy = height * 0.5
                    var r  = width * 0.38
                    var startRad = 130.0 * Math.PI / 180.0
                    var totalRad = 180.0 * Math.PI / 180.0

                    var redStartFrac = 6.0 / 7.0
                    var redStartAngle = startRad + totalRad * redStartFrac

                    // Белая линия шкалы тахометра
                    ctx.beginPath()
                    ctx.arc(cx, cy, r + 1, startRad, startRad + totalRad, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    // красная зона линии
                    ctx.beginPath()
                    ctx.arc(cx, cy, r + 1, redStartAngle, startRad + totalRad, false)
                    ctx.strokeStyle = "#ff3030"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    for (var i = 0; i <= 70; i++) {
                        var frac  = i / 70.0
                        var angle = startRad + frac * totalRad
                        var major = (i % 10 === 0)
                        var semi  = (i % 5 === 0) && !major
                        var tlen  = major ? 19 : (semi ? 12 : 6)
                        var isRed = (frac > 6.0/7.0 - 0.005)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(r-tlen), cy + Math.sin(angle)*(r-tlen))
                        ctx.lineTo(cx + Math.cos(angle)*(r+1),    cy + Math.sin(angle)*(r+1))
                        ctx.strokeStyle = isRed ? (major ? "#ff3030" : "#ff3030") : "#d8d8d8"
                        ctx.lineWidth = major ? 2.5 : (semi ? 1.5 : 0.75)
                        ctx.stroke()

                        if (major) {
                            var num = i / 10
                            var lr = r + 23   // цифры снаружи шкалы

                            ctx.save()
                            ctx.translate(cx + Math.cos(angle) * lr,
                                          cy + Math.sin(angle) * lr)

                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = isRed ? "#ff3030" : "#f5f5f5"
                            ctx.font = "bold 20px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(num, 0, 0)
                            ctx.restore()
                        }
                    }
                }
                Component.onCompleted: requestPaint()
            }

            // Стрелка тахометра
            Item {
                anchors.centerIn: parent
                width: tachZone.dialDiam; height: tachZone.dialDiam
                rotation: tachZone.needleAngle
                transformOrigin: Item.Center
                Behavior on rotation { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 7; height: tachZone.dialRad * 0.60
                    y: tachZone.dialRad - height; radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 0.8; color: "#d0d0d4" }
                        GradientStop { position: 1.0; color: "#888890" }
                    }
                }
            }

            NeedleCap {
                anchors.centerIn: parent
                capSize: 120
                Text {
                       anchors.centerIn: parent

                       text: "x1000 rpm"
                       color: "#f0f0f0"
                       font.pixelSize: 13
                       font.family: eurostileFont.name

                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                   }
            }

            Row {
                id: warningIcons

                property int iconSize: 50

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 160

                spacing: 20

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/oil.png"
                    width: warningIcons.iconSize
                    height: warningIcons.iconSize
                    fillMode: Image.PreserveAspectFit

                    visible: tachZone.oilWarning
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/engine.png"
                    width: warningIcons.iconSize
                    height: warningIcons.iconSize
                    fillMode: Image.PreserveAspectFit

                    visible: tachZone.engineWarning
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/battery.png"
                    width: warningIcons.iconSize
                    height: warningIcons.iconSize
                    fillMode: Image.PreserveAspectFit

                    visible: tachZone.batteryWarning
                }
            }
        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  СПИДОМЕТР  (центральный)                                       ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: speedZone
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: gaugesArea.width * 0.44
            height: gaugesArea.height
            z: 1

            property real dialDiam: Math.min(width, height) * 0.96
            property real dialRad:  dialDiam * 0.5
            property real speedFraction: carController.speed / 200.0
            property real needleAngle: -135.0 + speedFraction * 270.0

            ChromeWell { anchors.centerIn: parent; dialSize: speedZone.dialDiam }

            Canvas {
                id: speedCanvas
                anchors.centerIn: parent
                width: speedZone.dialDiam; height: speedZone.dialDiam
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width*0.5, cy = height*0.5
                    var r  = width * 0.432
                    var startRad = 135.0 * Math.PI / 180.0
                    var totalRad = 270.0 * Math.PI / 180.0

                    // Белая линия шкалы спидометра
                    ctx.beginPath()
                    ctx.arc(cx, cy, r + 1, startRad, startRad + totalRad, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    for (var i = 0; i <= 200; i++) {
                        var frac  = i / 200.0
                        var angle = startRad + frac * totalRad
                        var major = (i % 20 === 0)
                        var semi  = (i % 10 === 0) && !major
                        var tlen  = major ? 21 : (semi ? 13 : 5)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(r-tlen), cy + Math.sin(angle)*(r-tlen))
                        ctx.lineTo(cx + Math.cos(angle)*(r+1),    cy + Math.sin(angle)*(r+1))
                        ctx.strokeStyle = "#d8d8d8"
                        ctx.lineWidth   = major ? 2.5 : (semi ? 1.4 : 0.65)
                        ctx.stroke()

                        if (major) {
                            var lr = r + 20

                            ctx.save()
                            ctx.translate(cx + Math.cos(angle) * lr,
                                          cy + Math.sin(angle) * lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#dcdce8"
                            ctx.font = "bold 21px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(i, 0, 0)
                            ctx.restore()
                        }
                    }
                }
                Component.onCompleted: requestPaint()
            }

            // Стрелка спидометра
            Item {
                anchors.centerIn: parent
                width: speedZone.dialDiam; height: speedZone.dialDiam
                rotation: speedZone.needleAngle
                transformOrigin: Item.Center
                Behavior on rotation { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 7; height: speedZone.dialRad * 0.7
                    y: speedZone.dialRad - height; radius: 2.5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ffffff" }
                        GradientStop { position: 0.8; color: "#e0e0e0" }
                        GradientStop { position: 1.0; color: "#909090" }
                    }
                }
            }

            NeedleCap {
                anchors.centerIn: parent
                capSize: 120
                Text {
                       anchors.centerIn: parent

                       text: "km/h"
                       color: "#f0f0f0"
                       font.pixelSize: 13
                       font.family: eurostileFont.name

                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                   }
            }

            // ── Боковые закрывашки: перекрывают части боковых приборов ──────
            // Рисуются поверх боковых колодцев благодаря z:1 у speedZone
            // Левая: закрывает правый край тахометра который заходит под спидометр
            Rectangle {
                x: 0
                y: (speedZone.height - speedZone.dialDiam * 0.8) / 2
                width: (speedZone.width - speedZone.dialDiam) / 2 - 14
                height: speedZone.dialDiam * 0.8
                color: "#0b0b0f"
            }
            // Правая: закрывает левый край правого прибора
            Rectangle {
                x: speedZone.width - (speedZone.width - speedZone.dialDiam) / 2 + 14
                y: (speedZone.height - speedZone.dialDiam * 0.8) / 2
                width: (speedZone.width - speedZone.dialDiam) / 2 - 14
                height: speedZone.dialDiam * 0.8
                color: "#0b0b0f"
            }
            // Компоновка: верхняя строка [GEAR | ODO | VOLT] + нижняя строка [часы]
            Item {
                id: obcDisplay
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    // Позиционируем внутри круга: центр круга + смещение вниз
                    // Нижний край круга = center + dialRad. Панель высотой 90px.
                    // Отступаем от нижнего края круга внутрь на ~15% радиуса
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: speedZone.dialRad * 0.73
                    horizontalCenterOffset: -10
                }
                width:  speedZone.dialDiam * 0.45
                height: 80

                // Таймер системного времени
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
                }

                // Подложка дисплея
                Rectangle {
                    anchors.fill: parent; radius: 6
                    color: "#07070c"; opacity: 0.90
                    border { color: "#181826"; width: 1 }
                    // Световой блик
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: 10; radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#11111e" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                // Горизонтальный разделитель между строками
                Rectangle {
                    anchors { left: parent.left; right: parent.right
                              top: parent.top; topMargin: 48 }
                    height: 1; color: "#18182a"
                }

                // ── ВЕРХНЯЯ СТРОКА: GEAR | ODO | VOLT ────────────────────────
                Item {
                    height: 48
                    anchors { left: parent.left; right: parent.right
                              top: parent.top }

                    // GEAR
                    Item {
                        id: gearCell
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: parent.width * 0.26

                        Text {
                            anchors.centerIn: parent
                            text: {
                                var g = carController.gear
                                // Если gear пустой/0 — определяем по состоянию
                                if (g && g !== "" && g !== "0" && g !== 0) return g
                                // Газ нажат или машина едет — D
                                if (carController.throttle || carController.speed > 0) return "D"
                                return "P"
                            }
                            color: {
                                var g = carController.gear
                                var displayGear = (g && g !== "" && g !== "0" && g !== 0) ? g
                                    : (carController.throttle || carController.speed > 0 ? "D" : "P")
                                if (displayGear === "P") return "#808090"
                                if (displayGear === "R") return "#ff6644"
                                return "#00d0ea"
                            }
                            font { pixelSize: 34; bold: true; family: eurostileFont.name }
                        }
                    }

                    // Пунктирный разделитель GEAR | ODO
                    Canvas {
                        id: sepA
                        x: gearCell.width; y: 0; width: 2; height: parent.height
                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0,0,width,height)
                            c.setLineDash([3,5])
                            c.beginPath(); c.moveTo(1,6); c.lineTo(1,height-6)
                            c.strokeStyle="#1e1e30"; c.lineWidth=1.5; c.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // ODO (пробег)
                    Item {
                        id: odoCell
                        anchors { left: gearCell.right; leftMargin: 2
                                  top: parent.top; bottom: parent.bottom }
                        width: parent.width * 0.36

                        Column {
                            anchors.centerIn: parent; spacing: 1
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "ODO"
                                color: "#282838"
                                font { pixelSize: 9; letterSpacing: 1.2; family: eurostileFont.name }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                Text {
                                    text: "4"
                                    color: "#b8b8c8"
                                    font { pixelSize: 18; family: eurostileFont.name }
                                }
                                Text {
                                    text: "km"
                                    color: "#404050"
                                    font { pixelSize: 11; family: eurostileFont.name }
                                    anchors.baseline: parent.children[0].baseline
                                }
                            }
                        }
                    }

                    // Пунктирный разделитель ODO | VOLT
                    Canvas {
                        id: sepB
                        x: gearCell.width + 2 + odoCell.width; y: 0; width: 2; height: parent.height
                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0,0,width,height)
                            c.setLineDash([3,5])
                            c.beginPath(); c.moveTo(1,6); c.lineTo(1,height-6)
                            c.strokeStyle="#1e1e30"; c.lineWidth=1.5; c.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // VOLT (напряжение)
                    Item {
                        anchors { left: odoCell.right; leftMargin: 2
                                  right: parent.right
                                  top: parent.top; bottom: parent.bottom }

                        Column {
                            anchors.centerIn: parent; spacing: 1
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "VOLT"
                                color: "#282838"
                                font { pixelSize: 9; letterSpacing: 1.2; family: eurostileFont.name }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                Text {
                                    text: "13.6"
                                    color: "#b8b8c8"
                                    font { pixelSize: 18; family: eurostileFont.name }
                                }
                                Text {
                                    text: "V"
                                    color: "#404050"
                                    font { pixelSize: 11; family: eurostileFont.name }
                                    anchors.baseline: parent.children[0].baseline
                                }
                            }
                        }
                    }
                }

                // ── НИЖНЯЯ СТРОКА: цифровые часы ─────────────────────────────
                Item {
                    anchors { left: parent.left; right: parent.right
                              bottom: parent.bottom; top: parent.top; topMargin: 49 }

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(new Date(), "hh:mm")
                        color: "#c8c8d8"
                        font { pixelSize: 28; bold: true; family: eurostileFont.name }
                    }
                }
            }
        }
        // ____ПРАВЫЙ КОЛОДЕЦ_________________(TEMP, FUEL)___________
        Item {
            id: rightZone
            x: gaugesArea.width * 0.5 + speedZone.dialDiam * 0.5 - rightZone.dialDiam * 0.25
            y: 0
            width: gaugesArea.width * 0.35
            height: gaugesArea.height
            z: 0

            //property real dialDiam: Math.min(width, height) * 0.94
            property real dialDiam: gaugesArea.width * 0.35 * 0.94
            property real dialRad:  dialDiam * 0.5
            property real scaleOffset: 20.0

            // ── значения физики ───────────────────────────────────────────
            // Температура охлаждающей жидкости 50..130°C
            property real tempVal:      90.0   // подключить: carController.coolantTemp
            property real tempFraction: (tempVal - 50.0) / 80.0

            property real tempNeedle: (-60.0 + scaleOffset) + tempFraction * 90.0
            Behavior on tempNeedle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            // Уровень топлива 0..1
            property real fuelVal:      0.65   // подключить: carController.fuelLevel
            property real fuelNeedle: 60.0 + fuelVal * 60.0
            Behavior on fuelNeedle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            property bool lightWarning: false

            ChromeWell { anchors.centerIn: parent; dialSize: rightZone.dialDiam }

            // Шкала правого прибора
            Canvas {
                id: rightCanvas
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: width
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width * 0.5, cy = height * 0.5
                    var r  = width * 0.40   // радиус шкалы
                    var PI = Math.PI
                    var toRad = PI / 180.0

                    var tCSSstart = (210.0 + rightZone.scaleOffset) * toRad   // 10ч
                    var tCSS_end  = (330.0 + rightZone.scaleOffset) * toRad   // 2ч
                    var tSweep    = 80.0 * toRad

                    //белая линия на шкале температуры
                    var tRedFrom = tCSSstart + 0.80 * tSweep

                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, tCSSstart, tRedFrom, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    //красная часть
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, tRedFrom, tCSSstart + tSweep, false)
                    ctx.strokeStyle = "#ff3030"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    // Деления TEMP: 6 секций (0..6 = 7 делений), крупные 0/3/6
                    var tTicks = 9
                    for (var i = 0; i <= tTicks; i++) {
                        var frac  = i / tTicks
                        var angle = tCSSstart + frac * tSweep
                        var major = (i === 0 || i === 3 || i === 6 || i == 9)
                        var tlen  = major ? 17 : 9
                        var isHot = (frac >= 0.80)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(r-3-tlen), cy + Math.sin(angle)*(r-3-tlen))
                        ctx.lineTo(cx + Math.cos(angle)*(r-3+1),    cy + Math.sin(angle)*(r-3+1))
                        ctx.strokeStyle = isHot ? "#cc3030" : "#d8d8d8"
                        ctx.lineWidth = major ? 2.0 : 1.0; ctx.stroke()

                        if (major) {
                            // 3 цифры: 50 (i=0), 90 (i=3), 130 (i=6)
                            var labels = ["30", "50", "90", "130"]
                            var li = i / 3
                            var lr = r + 16
                            var lx = cx + Math.cos(angle)*lr
                            var ly = cy + Math.sin(angle)*lr
                            ctx.fillStyle = isHot ? "#ee4444" : "#d8d8d8"
                            ctx.font = "bold 20px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(labels[li], lx, ly)
                        }
                    }

                    // Подпись
                    var tMidAngle = tCSSstart + 0.5 * tSweep   // = 270° CSS = 12ч
                    var iconR = r - 3 - 44
                    ctx.font = "16px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"

                    var fCSSstart = (30.0 - rightZone.scaleOffset + 40) * toRad    // 5ч (Full)
                    var fCSS_end  = (150.0 - rightZone.scaleOffset) * toRad   // 7ч (Empty)
                    var fSweep    = 80.0 * toRad
                    var fOrangeFrom = fCSSstart + 0.75 * fSweep

                    // Правая соединительная дуга
                    var bridgeStart = tCSSstart + tSweep;   // конец температуры (130)
                    var bridgeEnd   = fCSSstart;            // начало топлива (1)

                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 20, bridgeStart, bridgeEnd, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    //белая линия шкалы топлива
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, fCSSstart, fOrangeFrom, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    //оранжевая линии зона резерва
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, fOrangeFrom, fCSSstart + fSweep, false)
                    ctx.strokeStyle = "#ff9922"
                    ctx.lineWidth = 2
                    ctx.stroke()

                    // Деления FUEL: 4 секции (0..4 = 5 делений)
                    var fTicks = 4
                    for (var j = 0; j <= fTicks; j++) {
                        var ff     = j / fTicks
                        var fa     = fCSSstart + ff * fSweep
                        var fmaj   = (j === 0 || j === 2 || j === 4 || j == 6)
                        var flen2  = fmaj ? 17 : 9
                        var isLow  = (ff >= 0.75)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(fa)*(r-3-flen2), cy + Math.sin(fa)*(r-3-flen2))
                        ctx.lineTo(cx + Math.cos(fa)*(r-3+1),      cy + Math.sin(fa)*(r-3+1))
                        ctx.strokeStyle = isLow ? "#cc6600" : "#d8d8d8"
                        ctx.lineWidth = fmaj ? 2.0 : 1.0; ctx.stroke()

                        if (fmaj) {
                            // 3 подписи: "1" (j=0, Full=5ч), "0.5" (j=2, 6ч), "0" (j=4, Empty=7ч)
                            var fLabels = ["1", "0.5", "0"]
                            var fli = j / 2
                            var flr = r + 13
                            var flx = cx + Math.cos(fa)*flr
                            var fly = cy + Math.sin(fa)*flr
                            ctx.fillStyle = isLow ? "#ff9922" : "#d8d8d8"
                            ctx.font = "bold 20px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(fLabels[fli], flx, fly)
                        }
                    }
                }

                Component.onCompleted: requestPaint()
            }

            // ── Стрелка ТЕМПЕРАТУРЫ ───────────────────────────────────────
            // Qt: 12ч=0°, -60°=10ч, +30°=1ч.
            // fraction=0(50°C) → Qt rotation=-60°; fraction=1(130°C) → Qt rotation=+60°
            // tempNeedle = -60 + fraction*120 ✓
            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.tempNeedle
                transformOrigin: Item.Center

                // Стрелка короткая — видна только во внешнем кольце
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 7
                    height: rightZone.dialRad * 0.50   // выходит из под диска
                    y: rightZone.dialRad - height       // от центра вверх
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 1.0; color: "#a0a0a8" }
                    }
                }
            }

            // ── Стрелка ТОПЛИВА ───────────────────────────────────────────
            property real fuelNeedleCorrect: 120.0 + fuelVal * 120.0
            Behavior on fuelNeedleCorrect { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.fuelNeedleCorrect
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 7
                    height: rightZone.dialRad * 0.50
                    y: rightZone.dialRad - height
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 1.0; color: "#a0a0a8" }
                    }
                }
            }
            // Центральный колпак поверх диска и хвостов стрелок
            NeedleCap {
                anchors.centerIn: parent
                capSize: 120
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5

                    source: "qrc:/qt/qml/dashboard/icons/white_fuel.png"
                    width: 25
                    height: 25
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 5

                    source: "qrc:/qt/qml/dashboard/icons/temp.png"
                    width: 50
                    height: 50
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item {
                id: temp_fuelIcons

                width: rightZone.dialDiam
                height: rightZone.dialDiam

                anchors.centerIn: parent

                property real iconRadius: rightZone.dialRad * 0.72
                property int iconSize: 50

                function posX(angleDeg) {
                    return width / 2
                            + Math.cos(angleDeg * Math.PI / 180) * iconRadius
                }

                function posY(angleDeg) {
                    return height / 2
                            + Math.sin(angleDeg * Math.PI / 180) * iconRadius
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/side_lamps.svg"
                    width: temp_fuelIcons.iconSize
                    height: temp_fuelIcons.iconSize
                    fillMode: Image.PreserveAspectFit

                    x: temp_fuelIcons.posX(-15) - width/2 + 15
                    y: temp_fuelIcons.posY(-15) - height/2 - 40

                    visible: rightZone.lightWarning
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/high_beam.png"
                    width: temp_fuelIcons.iconSize
                    height: temp_fuelIcons.iconSize
                    fillMode: Image.PreserveAspectFit

                    x: temp_fuelIcons.posX(10) - width/2 + 25
                    y: temp_fuelIcons.posY(10) - height/2 - 25

                    visible: rightZone.lightWarning
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/fog_front.svg"
                    width: 45
                    height: 45
                    fillMode: Image.PreserveAspectFit

                    x: temp_fuelIcons.posX(35) - width/2 + 36
                    y: temp_fuelIcons.posY(35) - height/2 - 10

                    visible: rightZone.lightWarning
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -80
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 260

                source: "qrc:/qt/qml/dashboard/icons/yellow_fuel.png"
                width: 30
                height: 30
                fillMode: Image.PreserveAspectFit

                visible: rightZone.lightWarning
            }
        }
    }
}
