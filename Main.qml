import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import Automotive.Core 1.0

// ═══════════════════════════════════════════════════════════════════════════
//  СИСТЕМА КООРДИНАТ СТРЕЛОК
//
//  Qt rotation=0 → стрелка вверх (12ч). Положительный = по часовой.
//
//  ТАХОМЕТР / СПИДОМЕТР (270° охват, начало в 7ч):
//    rotation = -135 + fraction * 270
//
//  ПРАВЫЙ ПРИБОР:
//    TEMP: дуга от 10ч до 12ч (60° охват левой верхней четверти)
//      10ч = -120°, 12ч = 0°
//      rotation = -120 + fraction * 120
//      fraction = (temp - 50) / 80
//
//    FUEL: дуга от 7ч до 5ч через 6ч (120° охват нижней половины)
//      7ч = -45°(от низа) → в Qt: 7ч = 210°, 5ч = 150°
//      7ч = rotation -150°, 6ч = rotation 180°(/-180°), 5ч = rotation 150°
//      Удобнее: 7ч = 210° (Qt), 5ч = 150° (Qt, с другой стороны)
//      Шкала идёт ОТ 7ч (Empty=0) ЧЕРЕЗ 6ч ДО 5ч (Full=1)
//      7ч = -150°, 6ч = 180° = -180°, 5ч = 150°
//      rotation = -150 + fraction * 300... нет, охват 7ч→5ч = 120° через низ
//      В Qt: 7ч = 210°, 5ч = 150°. Идём по часовой от 210° до 360°+150°=510°
//      Охват = 300°? Нет. Визуально 7ч→6ч→5ч = 120° по часовой (правая часть низа)
//      Но на референсе шкала топлива — узкая дуга от ~5ч до ~7ч через низ (120°).
//      7ч в Qt = -150° (= 210°), 5ч = 150°.
//      Идём по часовой: 7ч(210°) → 6ч(270°) → 5ч(330°)... это 120° по часовой.
//      Стрелка FUEL: rotation = 210 + fraction * 120  (0=Empty=7ч, 1=Full=5ч)
//      Но Qt: 210° = -150°. Используем: rotation = -150 + fraction * 120
// ═══════════════════════════════════════════════════════════════════════════

Window {
    id: root
    width: 1920
    height: 720
    visible: true
    title: "Lada Vesta Dashboard"
    color: "#0c0c0e"

    CarController { id: carController }

    // ── фон ─────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#17171d" }
            GradientStop { position: 0.6; color: "#0b0b0f" }
            GradientStop { position: 1.0; color: "#070709" }
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
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 70 }
            spacing: 2
            Text {
                text: "►"
                font.pixelSize: 28; font.bold: true
                color: "#1ecc50"
                opacity: carController.leftBlinkerOn ? 1.0 : 0.05
                Behavior on opacity { NumberAnimation { duration: 50 } }
                rotation: 180
            }
            Text {
                text: "►"
                font.pixelSize: 28; font.bold: true
                color: "#1ecc50"
                opacity: carController.leftBlinkerOn ? 1.0 : 0.05
                Behavior on opacity { NumberAnimation { duration: 50 } }
                rotation: 180
            }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 3 }
            text: "▲  АВАРИЙНАЯ"
            color: "#ff3518"
            font { pixelSize: 17; bold: true; family: "Helvetica Neue" }
            visible: carController.leftBlinker && carController.rightBlinker
            opacity: carController.leftBlinkerOn ? 1.0 : 0.07
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 5 }
            text: "W — ГАЗ    S — ТОРМОЗ    A — ◄    D — ►    F — АВАРИЙКА"
            color: "#252530"
            font { pixelSize: 12; family: "Helvetica Neue"; letterSpacing: 1.6 }
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 70 }
            spacing: 2
            Text {
                text: "►"
                font.pixelSize: 28; font.bold: true
                color: "#1ecc50"
                opacity: carController.rightBlinkerOn ? 1.0 : 0.05
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }
            Text {
                text: "►"
                font.pixelSize: 28; font.bold: true
                color: "#1ecc50"
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

            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 28; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: parent.width * 0.36; centerY: parent.height * 0.24
                    centerRadius: parent.width * 0.52
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#8e8e98" }
                    GradientStop { position: 0.28; color: "#363640" }
                    GradientStop { position: 0.55; color: "#cecede" }
                    GradientStop { position: 0.78; color: "#232330" }
                    GradientStop { position: 1.0;  color: "#767680" }
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 9; height: width; radius: width / 2
                color: "#040406"
            }
            Rectangle {
                anchors.centerIn: parent
                width: dialSize; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: parent.width * 0.50; centerY: parent.height * 0.38
                    centerRadius: parent.width * 0.56
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#22222e" }
                    GradientStop { position: 0.48; color: "#101016" }
                    GradientStop { position: 1.0;  color: "#040406" }
                }
            }
        }

        // ── центральный колпак ───────────────────────────────────────────────
        component NeedleCap: Rectangle {
            property real capSize: 28
            width: capSize; height: capSize; radius: capSize / 2
            anchors.centerIn: parent
            gradient: RadialGradient {
                centerX: width * 0.34; centerY: height * 0.28; centerRadius: width * 0.55
                focalX: centerX; focalY: centerY
                GradientStop { position: 0.0; color: "#606070" }
                GradientStop { position: 1.0; color: "#080808" }
            }
            border { color: "#1c1c28"; width: 1 }
        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  ТАХОМЕТР  (левый)                                              ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: tachZone
            x: gaugesArea.width * 0.012
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real dialDiam: Math.min(width, height) * 0.87
            property real dialRad:  dialDiam * 0.5
            property real rpmFraction: Math.min(carController.rpm / 7000.0, 1.0)
            property real needleAngle: -135.0 + rpmFraction * 270.0

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
                    var r  = width * 0.432
                    var startRad = 135.0 * Math.PI / 180.0
                    var totalRad = 270.0 * Math.PI / 180.0

                    // Красная зона 6–7 тысяч
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 5, startRad + (6.0/7.0)*totalRad, startRad + totalRad)
                    ctx.strokeStyle = "#8a1010"; ctx.lineWidth = 11; ctx.lineCap = "butt"; ctx.stroke()

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
                        ctx.strokeStyle = isRed ? (major ? "#ff4444" : "#661818")
                                                : (major ? "#d0d0d8" : (semi ? "#545460" : "#2c2c34"))
                        ctx.lineWidth = major ? 2.5 : (semi ? 1.5 : 0.75)
                        ctx.stroke()

                        if (major) {
                            var num = i / 10
                            var lr  = r - 36
                            ctx.save()
                            ctx.translate(cx + Math.cos(angle)*lr, cy + Math.sin(angle)*lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = isRed ? "#ff5555" : "#d8d8e4"
                            ctx.font = "bold 20px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(num, 0, 0)
                            ctx.restore()
                        }
                    }

                    ctx.fillStyle = "#3a3a48"
                    ctx.font = "12px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("x1000 rpm", cx, cy - r * 0.28)
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
                    width: 4; height: tachZone.dialRad * 0.60
                    y: tachZone.dialRad - height; radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 0.8; color: "#d0d0d4" }
                        GradientStop { position: 1.0; color: "#888890" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 5; height: tachZone.dialRad * 0.13
                    y: tachZone.dialRad; radius: 2.5; color: "#c01818"
                }
            }

            NeedleCap { anchors.centerIn: parent; capSize: 26 }
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

                    for (var i = 0; i <= 200; i++) {
                        var frac  = i / 200.0
                        var angle = startRad + frac * totalRad
                        var major = (i % 20 === 0)
                        var semi  = (i % 10 === 0) && !major
                        var tlen  = major ? 21 : (semi ? 13 : 5)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(r-tlen), cy + Math.sin(angle)*(r-tlen))
                        ctx.lineTo(cx + Math.cos(angle)*(r+1),    cy + Math.sin(angle)*(r+1))
                        ctx.strokeStyle = major ? "#d4d4d8" : (semi ? "#505058" : "#272730")
                        ctx.lineWidth   = major ? 2.5 : (semi ? 1.4 : 0.65)
                        ctx.stroke()

                        if (major) {
                            var lr = r - 38
                            ctx.save()
                            ctx.translate(cx + Math.cos(angle)*lr, cy + Math.sin(angle)*lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#dcdce8"
                            ctx.font = "bold 21px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(i, 0, 0)
                            ctx.restore()
                        }
                    }

                    ctx.fillStyle = "#383844"
                    ctx.font = "14px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("km/h", cx, cy - r * 0.22)
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
                    width: 5; height: speedZone.dialRad * 0.60
                    y: speedZone.dialRad - height; radius: 2.5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ffffff" }
                        GradientStop { position: 0.8; color: "#e0e0e0" }
                        GradientStop { position: 1.0; color: "#909090" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 6; height: speedZone.dialRad * 0.14
                    y: speedZone.dialRad; radius: 3; color: "#cc2020"
                }
            }

            NeedleCap { anchors.centerIn: parent; capSize: 34 }

            // ── Бортовой компьютер (внутри спидометра) ────────────────────────
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
                            font { pixelSize: 34; bold: true; family: "Helvetica Neue" }
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
                                font { pixelSize: 9; letterSpacing: 1.2; family: "Helvetica Neue" }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                Text {
                                    text: "4"
                                    color: "#b8b8c8"
                                    font { pixelSize: 18; family: "Helvetica Neue" }
                                }
                                Text {
                                    text: "km"
                                    color: "#404050"
                                    font { pixelSize: 11; family: "Helvetica Neue" }
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
                                font { pixelSize: 9; letterSpacing: 1.2; family: "Helvetica Neue" }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                Text {
                                    text: "13.6"
                                    color: "#b8b8c8"
                                    font { pixelSize: 18; family: "Helvetica Neue" }
                                }
                                Text {
                                    text: "V"
                                    color: "#404050"
                                    font { pixelSize: 11; family: "Helvetica Neue" }
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
                        font { pixelSize: 28; bold: true; family: "Helvetica Neue" }
                    }
                }
            }
        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  ПРАВЫЙ ПРИБОР: TEMP (верх-лево) + FUEL (низ) + центральный диск║
        // ║                                                                  ║
        // ║  Компоновка как на референсе:                                   ║
        // ║  • Большой чёрный диск по центру (~50% радиуса)                 ║
        // ║  • Шкала TEMP: дуга от 10ч до 12ч (60°), верхний левый сектор  ║
        // ║    10ч = -120°, 12ч = 0° в Qt rotation                         ║
        // ║    CSS: 10ч = 240°→ 240-90 = 150° в CSS; 12ч = 270°-90 = 180°? ║
        // ║    Перейдём к простой CSS-геометрии:                            ║
        // ║    10ч = 210° в CSS (= 240° от верха = 7ч нет, 10ч=300° от 3ч) ║
        // ║    Используем градусы от оси X (3ч=0°, 6ч=90°, 9ч=180°, 12ч=270°):
        // ║    10ч ≈ 240°, 12ч = 270°                                       ║
        // ║    TEMP дуга: ctx.arc(cx,cy,r, 240°, 270°) anticlockwise=false  ║
        // ║    (короткая дуга 30° слева-вверху)                             ║
        // ║                                                                  ║
        // ║  Нет, на референсе дуга шире. Смотрим:                         ║
        // ║  TEMP: от ~8ч до 12ч ≈ 120° через верх                         ║
        // ║    8ч = 210° CSS, 12ч = 270° CSS                               ║
        // ║    arc(cx,cy,r, 210°toRad, 270°toRad) → дуга 60° по часовой   ║
        // ║  FUEL: от 6ч до ~4ч ≈ 120° через низ                           ║
        // ║    6ч = 90° CSS, 4ч = 30° CSS                                  ║
        // ║    arc(cx,cy,r, 30°toRad, 90°toRad) → дуга 60° по часовой     ║
        // ║                                                                  ║
        // ║  Стрелки: вращаются вокруг центра, короткие                    ║
        // ║  TEMP needle: Qt rotation -120 (= 10ч) .. 0 (= 12ч)            ║
        // ║    rotation = -120 + fraction * 120                             ║
        // ║  FUEL needle: Qt rotation 90 (= 6ч) .. 150 (= 4ч)             ║
        // ║    Нет — FUEL 0→Full = от 6ч назад к 4ч = по часовой           ║
        // ║    6ч = Qt rotation 180°; 4ч = Qt 120°                         ║
        // ║    Но хотим 0=пусто=6ч, 1=полный=4ч — шкала идёт от 6ч к 4ч  ║
        // ║    Значит: rotation = 180 - fraction * 60                      ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: rightZone
            x: gaugesArea.width - width - gaugesArea.width * 0.012
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real dialDiam: Math.min(width, height) * 0.87
            property real dialRad:  dialDiam * 0.5

            // ── значения физики ───────────────────────────────────────────
            // Температура охлаждающей жидкости 50..130°C
            property real tempVal:      90.0   // подключить: carController.coolantTemp
            property real tempFraction: (tempVal - 50.0) / 80.0
            // TEMP шкала: 8ч..12ч (CSS: 210°..270°), охват 60° по часовой
            // Qt rotation: 8ч=-150°, 12ч=-90°
            // Но нам нужно чтобы rotation=0 у Item → стрелка вверх.
            // 8ч в Qt = -150°, 12ч = -90°.
            // rotation = -150 + fraction * 60    (0→-150°=8ч, 1→-90°=12ч)
            // Подожди — на референсе TEMP от ~10ч до ~1ч (широкая дуга ~90°).
            // 10ч в Qt: 10ч = 300° по часовой от 12ч = Qt rotation -60°? Нет.
            // Qt: 12ч=0°, 3ч=90°, 6ч=180°, 9ч=-90°(=270°), 10ч=-60°(=300°)
            // 10ч = -60°; 12ч = 0°; 1ч = 30°
            // TEMP: от 10ч(-60°) до 1ч(+30°) = 90° охват
            // rotation = -60 + fraction * 90
            property real tempNeedle: -60.0 + tempFraction * 90.0
            Behavior on tempNeedle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            // Уровень топлива 0..1
            property real fuelVal:      0.65   // подключить: carController.fuelLevel
            // FUEL шкала: от 7ч до 5ч через 6ч (нижний сектор ~120°)
            // 7ч = Qt -150°; 5ч = Qt 150°
            // Проблема: 7ч→5ч через низ = 120° по часовой (7ч→6ч→5ч)
            // 7ч Qt = 210° = -150°; 5ч Qt = 150°
            // rotation = -150 + fraction * (150-(-150)) — нет, это через верх
            // Через низ: 7ч→6ч→5ч = по часовой: -150° → -180°/+180° → +150°
            // Это 300° охват — слишком много!
            // На референсе FUEL от ~5ч до ~7ч дуга всего ~120° через низ.
            // 5ч = 150° CSS = Qt 60° (5ч = 5*30=150° от 12ч = Qt rotation 60°)
            // 7ч = 210° CSS = Qt 120°
            // Дуга через низ = CSS arc(cx,cy,r, 150°, 210°, false) — 60° дуга.
            // FUEL: 0=Empty=5ч(Qt 60°) .. 1=Full=7ч(Qt 120°)
            // rotation = 60 + fraction * 60   (60°=5ч=Empty, 120°=7ч=Full)
            property real fuelNeedle: 60.0 + fuelVal * 60.0
            Behavior on fuelNeedle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

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
                    var r  = width * 0.41   // радиус шкалы
                    var PI = Math.PI
                    var toRad = PI / 180.0

                    // ──────────────────────────────────────────────────────
                    //  TEMP: CSS дуга от 210° до 300° (10ч → 1ч, 90°)
                    //  10ч: CSS=240°, Qt=-60°. 1ч: CSS=330° Qt=30°.
                    //  По часовой arc(start, end, false)
                    //  210° = 8ч; 300° = 10ч (считая от 3ч=0°)
                    //  Хотим: левый верхний сектор, как на референсе.
                    //  8ч = 8*30=240° от 12ч → CSS = 240-90=150°
                    //  Нет. CSS 0°=3ч, 90°=6ч, 180°=9ч, 270°=12ч.
                    //  10ч = (10/12)*360 = 300° от 12ч → CSS = 300-90 = 210°
                    //  12ч = CSS = 270°; 2ч = CSS = 330°... нет
                    //  ПРОЩЕ: 12ч = CSS 270°. 10ч = CSS 270° - 60° = 210°.
                    //  Дуга TEMP: CSS 210° → 330° (через 270°=12ч), охват 120°
                    //  arc(cx, cy, r, 210*toRad, 330*toRad)
                    //  Стрелка Qt: 210° CSS = 12ч - 60° = -60° в Qt. 330° CSS = 60° в Qt.
                    //  rotation = -60 + fraction * 120  ✓ (совпадает с tempNeedle выше)

                    var tCSSstart = 210.0 * toRad   // 10ч
                    var tCSS_end  = 330.0 * toRad   // 2ч
                    var tSweep    = 120.0 * toRad

                    // Фоновая дуга TEMP
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, tCSSstart, tCSS_end, false)
                    ctx.strokeStyle = "#1a1a24"; ctx.lineWidth = 14; ctx.lineCap = "butt"; ctx.stroke()

                    // Красная зона: последние 20% (>117°C = ближе к 2ч)
                    var tRedFrom = tCSSstart + 0.80 * tSweep
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, tRedFrom, tCSS_end, false)
                    ctx.strokeStyle = "#7a1010"; ctx.lineWidth = 14; ctx.lineCap = "butt"; ctx.stroke()

                    // Деления TEMP: 6 секций (0..6 = 7 делений), крупные 0/3/6
                    var tTicks = 6
                    for (var i = 0; i <= tTicks; i++) {
                        var frac  = i / tTicks
                        var angle = tCSSstart + frac * tSweep
                        var major = (i === 0 || i === 3 || i === 6)
                        var tlen  = major ? 17 : 9
                        var isHot = (frac >= 0.80)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(r-3-tlen), cy + Math.sin(angle)*(r-3-tlen))
                        ctx.lineTo(cx + Math.cos(angle)*(r-3+1),    cy + Math.sin(angle)*(r-3+1))
                        ctx.strokeStyle = isHot ? "#cc3030" : "#606070"
                        ctx.lineWidth = major ? 2.0 : 1.0; ctx.stroke()

                        if (major) {
                            // 3 цифры: 50 (i=0), 90 (i=3), 130 (i=6)
                            var labels = ["50", "90", "130"]
                            var li = i / 3
                            var lr = r - 3 - 30
                            var lx = cx + Math.cos(angle)*lr
                            var ly = cy + Math.sin(angle)*lr
                            ctx.fillStyle = isHot ? "#ee4444" : "#b8b8c8"
                            ctx.font = "bold 14px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(labels[li], lx, ly)
                        }
                    }

                    // Иконка термометра рядом с "90" (середина = угол tCSSstart+tSweep/2)
                    var tMidAngle = tCSSstart + 0.5 * tSweep   // = 270° CSS = 12ч
                    var iconR = r - 3 - 44
                    ctx.font = "16px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("🌡", cx + Math.cos(tMidAngle)*iconR, cy + Math.sin(tMidAngle)*iconR - 4)

                    // Подпись «ТЕМП» над дугой температуры
                    ctx.fillStyle = "#606070"
                    ctx.font = "bold 10px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("ТЕМП", cx + Math.cos(tMidAngle)*(r - 3 - 56), cy + Math.sin(tMidAngle)*(r - 3 - 56) - 4)

                    // ──────────────────────────────────────────────────────
                    //  FUEL: CSS дуга от 30° до 150° (5ч → 7ч через 6ч)
                    //  5ч CSS: 12ч=270°, 5ч = 270° + 5*30° - 360°? Нет.
                    //  3ч=0°, 4ч=30°, 5ч=60°, 6ч=90°, 7ч=120°, 8ч=150°
                    //  Правильно! 3ч=0°, каждый час = 30°.
                    //  5ч = 60° CSS; 7ч = 120° CSS. Дуга по часовой 60°..120°.
                    //  arc(cx, cy, r, 60°, 120°, false) — через низ (6ч=90°) ✓

                    var fCSSstart = 60.0 * toRad    // 5ч (Full)
                    var fCSS_end  = 120.0 * toRad   // 7ч (Empty)
                    var fSweep    = 60.0 * toRad

                    // Фоновая дуга FUEL
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, fCSSstart, fCSS_end, false)
                    ctx.strokeStyle = "#1a1a24"; ctx.lineWidth = 14; ctx.lineCap = "butt"; ctx.stroke()

                    // Оранжевая зона резерва: последние 25% (ближе к 7ч = Empty)
                    var fOrangeFrom = fCSSstart + 0.75 * fSweep
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 3, fOrangeFrom, fCSS_end, false)
                    ctx.strokeStyle = "#7a4000"; ctx.lineWidth = 14; ctx.lineCap = "butt"; ctx.stroke()

                    // Деления FUEL: 4 секции (0..4 = 5 делений)
                    var fTicks = 4
                    for (var j = 0; j <= fTicks; j++) {
                        var ff     = j / fTicks
                        var fa     = fCSSstart + ff * fSweep
                        var fmaj   = (j === 0 || j === 2 || j === 4)
                        var flen2  = fmaj ? 17 : 9
                        var isLow  = (ff >= 0.75)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(fa)*(r-3-flen2), cy + Math.sin(fa)*(r-3-flen2))
                        ctx.lineTo(cx + Math.cos(fa)*(r-3+1),      cy + Math.sin(fa)*(r-3+1))
                        ctx.strokeStyle = isLow ? "#cc6600" : "#606070"
                        ctx.lineWidth = fmaj ? 2.0 : 1.0; ctx.stroke()

                        if (fmaj) {
                            // 3 подписи: "1" (j=0, Full=5ч), "0.5" (j=2, 6ч), "0" (j=4, Empty=7ч)
                            var fLabels = ["1", "0.5", "0"]
                            var fli = j / 2
                            var flr = r - 3 - 30
                            var flx = cx + Math.cos(fa)*flr
                            var fly = cy + Math.sin(fa)*flr
                            ctx.fillStyle = isLow ? "#ff9922" : "#b8b8c8"
                            ctx.font = "bold 14px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(fLabels[fli], flx, fly)
                        }
                    }

                    // Иконка бензоколонки (у нуля = 7ч = CSS 120°)
                    var fuelIconAngle = fCSS_end + 18 * toRad  // чуть правее шкалы
                    var fuelIconR = r - 3 - 34
                    ctx.font = "18px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("⛽", cx + Math.cos(fuelIconAngle)*fuelIconR,
                                       cy + Math.sin(fuelIconAngle)*fuelIconR)

                    // Подпись «ТОПЛИВО» под дугой топлива
                    var fMidAngle = fCSSstart + 0.5 * fSweep   // = 90° CSS = 6ч
                    ctx.fillStyle = "#606070"
                    ctx.font = "bold 10px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("ТОПЛИВО", cx + Math.cos(fMidAngle)*(r - 3 - 54), cy + Math.sin(fMidAngle)*(r - 3 - 54))

                    // ──────────────────────────────────────────────────────
                    //  Зелёная пиктограмма габаритов (правая сторона)
                    //  Правая сторона ≈ CSS 330°–30° (область 3ч)
                    ctx.fillStyle = "#1a6a1a"
                    ctx.font = "13px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    // Позиция у 3ч = cx+r*cos(0), cy+r*sin(0), чуть внутрь
                    ctx.fillText("≡О≡", cx + r * 0.58, cy - r * 0.08)
                    ctx.fillText("x1000 rpm", cx, cy - r * 0.28)
                }

                Component.onCompleted: requestPaint()
            }

            // ── БОЛЬШОЙ центральный диск ─────────────────────────────────
            // Закрывает центр, оставляя видимыми только дуги на краях
            Rectangle {
                anchors.centerIn: parent
                width: rightZone.dialDiam * 0.54
                height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: width * 0.42; centerY: height * 0.35
                    centerRadius: width * 0.58
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#2a2a36" }
                    GradientStop { position: 0.40; color: "#141420" }
                    GradientStop { position: 0.85; color: "#070710" }
                    GradientStop { position: 1.0;  color: "#040408" }
                }
                border { color: "#0e0e18"; width: 1 }
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
                    width: 3
                    height: rightZone.dialRad * 0.50   // выходит из под диска
                    y: rightZone.dialRad - height       // от центра вверх
                    radius: 1.5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 1.0; color: "#a0a0a8" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4; height: rightZone.dialRad * 0.10
                    y: rightZone.dialRad; radius: 2; color: "#b01818"
                }
            }

            // ── Стрелка ТОПЛИВА ───────────────────────────────────────────
            // CSS: fCSSstart=60°(5ч=Full), fCSS_end=120°(7ч=Empty)
            // Qt: 5ч = 60° CSS = Qt rotation 60°-90° = -30°...
            // CSS→Qt: Qt_rot = CSS_angle - 270°  (т.к. 12ч = CSS 270° = Qt 0°)
            // 5ч CSS=60°: Qt = 60-270 = -210° = 150°
            // 7ч CSS=120°: Qt = 120-270 = -150°
            // fraction=0=Full=5ч → Qt=150°; fraction=1=Empty=7ч → Qt=-150°(-210°?)
            // Нет: -150° и 150° это одно и то же направление через разный знак...
            // 5ч Qt: 5 часов = 150° по часовой от 12ч = Qt rotation 150°.
            // 7ч Qt: 7 часов = 210° по часовой от 12ч = Qt rotation 210° = -150°.
            // Full(0) = 5ч = 150°. Empty(1) = 7ч = 210°.
            // fuelNeedle = 150 + fraction * 60
            // (переопределяем — в properties выше формула была другой)
            // Пересчёт: 150 + 0*60=150 ✓; 150 + 0.65*60=189; 150+1*60=210 ✓
            // Обновляем свойство напрямую через binding:
            // Создаём локальный alias:
            property real fuelNeedleCorrect: 150.0 + fuelVal * 60.0
            Behavior on fuelNeedleCorrect { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.fuelNeedleCorrect
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 3
                    height: rightZone.dialRad * 0.50
                    y: rightZone.dialRad - height
                    radius: 1.5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f4" }
                        GradientStop { position: 1.0; color: "#a0a0a8" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4; height: rightZone.dialRad * 0.10
                    y: rightZone.dialRad; radius: 2; color: "#b06010"
                }
            }

            // Центральный колпак поверх диска и хвостов стрелок
            NeedleCap { anchors.centerIn: parent; capSize: 28 }

            // ── Подписи шкал поверх центрального диска ───────────────────
            // ТЕМП — в верхней части диска (12 часов)
            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: parent.height * 0.465 - rightZone.dialRad * 0.82
                }
                text: "ТЕМП"
                color: "#707080"
                font { pixelSize: 11; bold: true; family: "Helvetica Neue"; letterSpacing: 1.0 }
            }

            // ТОПЛИВО — в нижней части диска (6 часов)
            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: parent.height * 0.555 + rightZone.dialRad * 0.64
                }
                text: "ТОПЛИВО"
                color: "#707080"
                font { pixelSize: 11; bold: true; family: "Helvetica Neue"; letterSpacing: 1.0 }
            }
        }
    }
}
