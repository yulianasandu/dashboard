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
    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: true

        MouseArea {
            anchors.fill: parent
            onClicked: keyScope.forceActiveFocus()
            propagateComposedEvents: true
        }

        Keys.onPressed: function(event) {
            if (event.isAutoRepeat) return
            switch (event.key) {
                case Qt.Key_W: carController.setThrottle(true);    break
                case Qt.Key_S: carController.setBrake(true);       break
                case Qt.Key_A: carController.toggleLeftBlinker();  break
                case Qt.Key_D: carController.toggleRightBlinker(); break
                case Qt.Key_F: carController.toggleHazard();       break
            }
        }
        Keys.onReleased: function(event) {
            if (event.isAutoRepeat) return
            switch (event.key) {
                case Qt.Key_W: carController.setThrottle(false); break
                case Qt.Key_S: carController.setBrake(false);    break
            }
        }
    }

    Component.onCompleted: keyScope.forceActiveFocus()

    // ═══════════════════════════════════════════════════════════════════════
    //  ВЕРХНЯЯ ПОЛОСА
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 50

        // Левый поворотник
        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 70 }
            spacing: 2
            Repeater {
                model: 2
                Text {
                    text: "◄"
                    font { pixelSize: 28 - index * 7; bold: true }
                    color: "#1ecc50"
                    opacity: carController.leftBlinkerOn ? 1.0 : 0.05
                    Behavior on opacity { NumberAnimation { duration: 50 } }
                }
            }
        }

        // Аварийная надпись
        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 3 }
            text: "▲  АВАРИЙНАЯ"
            color: "#ff3518"
            font { pixelSize: 17; bold: true; family: "Helvetica Neue" }
            visible: carController.leftBlinker && carController.rightBlinker
            opacity: carController.leftBlinkerOn ? 1.0 : 0.07
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }

        // Подсказки клавиш
        Text {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 5 }
            text: "W — ГАЗ    S — ТОРМОЗ    A — ◄    D — ►    F — АВАРИЙКА"
            color: "#252530"
            font { pixelSize: 12; family: "Helvetica Neue"; letterSpacing: 1.6 }
        }

        // Правый поворотник
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 70 }
            spacing: 2
            Repeater {
                model: 2
                Text {
                    text: "►"
                    font { pixelSize: 21 + index * 7; bold: true }
                    color: "#1ecc50"
                    opacity: carController.rightBlinkerOn ? 1.0 : 0.05
                    Behavior on opacity { NumberAnimation { duration: 50 } }
                }
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

        // ── переиспользуемый компонент: хромированный колодец ───────────────
        component ChromeWell: Item {
            property real dialSize: 300

            // Внешнее хромовое кольцо с металлическим градиентом
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
            // Чёрный паз — создаёт ощущение глубины
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 9; height: width; radius: width / 2
                color: "#040406"
            }
            // Основная чаша
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

        // ── компонент: стрелка (переиспользуется) ───────────────────────────
        component GaugeNeedle: Item {
            property real dialDiam: 300
            property real needleAngle: -135
            property color tailColor: "#cc2020"
            // охват тела = 60% радиуса, хвост = 13% радиуса

            anchors.centerIn: parent
            width: dialDiam; height: dialDiam
            rotation: needleAngle
            transformOrigin: Item.Center

            Behavior on rotation { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

            // тело
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 4
                height: dialDiam * 0.30    // 60% от радиуса = 30% от диаметра
                y: dialDiam * 0.50 - height  // верхний край = центр − длина
                radius: 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f5f5f5" }
                    GradientStop { position: 0.75; color: "#d8d8d8" }
                    GradientStop { position: 1.0;  color: "#909090" }
                }
            }
            // хвост
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 5
                height: dialDiam * 0.065
                y: dialDiam * 0.50     // нижний край хвоста уходит вниз от центра
                radius: 2.5
                color: tailColor
            }
        }

        // ── компонент: центральный колпак ────────────────────────────────────
        component NeedleCap: Rectangle {
            property real capSize: 26
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
        // ║  Диапазон: 0..7000 об/мин (0..7 × 1000)                        ║
        // ║  rotation = -135 + (rpm / 7000) * 270                          ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: tachZone
            x: gaugesArea.width * 0.012
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real dialDiam: Math.min(width, height) * 0.87
            property real dialRad:  dialDiam * 0.5

            // rpm из C++ уже ограничен до 6000 отсечкой — здесь масштабируем
            // по шкале 0..7000, чтобы стрелка реально доходила до красной зоны
            property real rpmFraction: Math.min(carController.rpm / 7000.0, 1.0)
            property real needleAngle: -135.0 + rpmFraction * 270.0

            ChromeWell {
                anchors.centerIn: parent
                dialSize: tachZone.dialDiam
            }

            // Шкала тахометра
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
                    // startRad = 135° в CSS (= 225° от 12ч = 7 часов)
                    var startRad = 135.0 * Math.PI / 180.0
                    var totalRad = 270.0 * Math.PI / 180.0

                    // Красная зона: 6..7 тысяч (последние 1/7 = ~14.3%)
                    var redFrom = startRad + (6.0 / 7.0) * totalRad
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 5, redFrom, startRad + totalRad)
                    ctx.strokeStyle = "#8a1010"; ctx.lineWidth = 11; ctx.lineCap = "butt"
                    ctx.stroke()

                    // 70 тиков (7 главных × 10)
                    for (var i = 0; i <= 70; i++) {
                        var frac  = i / 70.0
                        var angle = startRad + frac * totalRad
                        var major = (i % 10 === 0)
                        var semi  = (i %  5 === 0) && !major
                        var tickLen = major ? 19 : (semi ? 12 : 6)
                        var isRed   = (frac > 6.0/7.0 - 0.005)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle) * (r - tickLen), cy + Math.sin(angle) * (r - tickLen))
                        ctx.lineTo(cx + Math.cos(angle) * (r + 1),        cy + Math.sin(angle) * (r + 1))
                        ctx.strokeStyle = isRed
                            ? (major ? "#ff4444" : "#661818")
                            : (major ? "#d0d0d8" : (semi ? "#545460" : "#2c2c34"))
                        ctx.lineWidth = major ? 2.5 : (semi ? 1.5 : 0.75)
                        ctx.stroke()

                        if (major) {
                            var num = i / 10          // 0..7
                            var lr  = r - 36
                            var lx  = cx + Math.cos(angle) * lr
                            var ly  = cy + Math.sin(angle) * lr
                            ctx.save()
                            ctx.translate(lx, ly)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = isRed ? "#ff5555" : "#d8d8e4"
                            ctx.font = "bold 20px 'Helvetica Neue'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(num, 0, 0)
                            ctx.restore()
                        }
                    }

                    // Подпись
                    ctx.fillStyle = "#3a3a48"
                    ctx.font = "12px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("x1000 rpm", cx, cy - r * 0.28)
                }
                Component.onCompleted: requestPaint()
            }

            // Предупреждающие иконки
            Row {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: tachZone.dialDiam * 0.17
                }
                spacing: 14
                Text { id: oilWarn;      text: "🛢"; font.pixelSize: 22; opacity: 0.09 }
                Text { id: checkWarn;    text: "⚙";  font.pixelSize: 22; color: "#ff9800"; opacity: 0.09 }
                Text { id: battWarn;     text: "🔋"; font.pixelSize: 22; opacity: 0.09 }
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
                    width: 4
                    height: tachZone.dialRad * 0.60
                    y: tachZone.dialRad - height
                    radius: 2
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
        // ║  Диапазон: 0..200 км/ч                                          ║
        // ║  rotation = -135 + (speed / 200) * 270                         ║
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

            ChromeWell {
                id: speedChrome
                anchors.centerIn: parent
                dialSize: speedZone.dialDiam
            }

            // Шкала спидометра
            Canvas {
                id: speedCanvas
                anchors.centerIn: parent
                width: speedZone.dialDiam
                height: speedZone.dialDiam
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width * 0.5, cy = height * 0.5
                    var r  = width * 0.432
                    var startRad = 135.0 * Math.PI / 180.0
                    var totalRad = 270.0 * Math.PI / 180.0

                    // 200 тиков
                    for (var i = 0; i <= 200; i++) {
                        var frac  = i / 200.0
                        var angle = startRad + frac * totalRad
                        var major = (i % 20 === 0)
                        var semi  = (i % 10 === 0) && !major
                        var tickLen = major ? 21 : (semi ? 13 : 5)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle) * (r - tickLen), cy + Math.sin(angle) * (r - tickLen))
                        ctx.lineTo(cx + Math.cos(angle) * (r + 1),        cy + Math.sin(angle) * (r + 1))
                        ctx.strokeStyle = major ? "#d4d4d8" : (semi ? "#505058" : "#272730")
                        ctx.lineWidth   = major ? 2.5 : (semi ? 1.4 : 0.65)
                        ctx.stroke()

                        if (major) {
                            var lr = r - 38
                            var lx = cx + Math.cos(angle) * lr
                            var ly = cy + Math.sin(angle) * lr
                            ctx.save()
                            ctx.translate(lx, ly)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#dcdce8"
                            ctx.font = "bold 21px 'Helvetica Neue'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
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
                    width: 5
                    height: speedZone.dialRad * 0.60
                    y: speedZone.dialRad - height
                    radius: 2.5
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

            // ── Бортовой компьютер — внутри круга, под колпачком ──────────
            Item {
                id: obcDisplay
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: speedZone.dialDiam * 0.055
                }
                width:  speedZone.dialDiam * 0.58
                height: 74

                // Таймер реального времени
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
                }

                // Полупрозрачная подложка
                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "#09090e"
                    opacity: 0.88
                    border { color: "#1a1a28"; width: 1 }

                    // Световой блик сверху
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: parent.height * 0.30; radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#12121c" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 0

                    // ── ПЕРЕДАЧА ──────────────────────────────────────────
                    Item {
                        width: parent.width * 0.22; height: parent.height
                        Column {
                            anchors.centerIn: parent; spacing: 1
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "GEAR"
                                color: "#303040"; font { pixelSize: 10; family: "Helvetica Neue"; letterSpacing: 0.8 }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: carController.gear
                                color: "#00d0e8"
                                font { pixelSize: 38; bold: true; family: "Helvetica Neue" }
                            }
                        }
                    }

                    // Пунктирный разделитель
                    Canvas {
                        width: 2; height: parent.height
                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0, 0, width, height)
                            c.setLineDash([3, 5])
                            c.beginPath(); c.moveTo(1, 6); c.lineTo(1, height - 6)
                            c.strokeStyle = "#20202e"; c.lineWidth = 1.5; c.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // ── ПРОБЕГ + НАПРЯЖЕНИЕ ───────────────────────────────
                    Item {
                        width: parent.width * 0.36; height: parent.height
                        Column {
                            anchors.centerIn: parent; spacing: 5
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 4
                                Text { text: "4";    color: "#b8b8c4"; font { pixelSize: 18; family: "Helvetica Neue" } }
                                Text { text: "km";   color: "#464654"; font { pixelSize: 12; family: "Helvetica Neue" }
                                    anchors.baseline: parent.children[0].baseline }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 4
                                Text { text: "13.6"; color: "#b8b8c4"; font { pixelSize: 18; family: "Helvetica Neue" } }
                                Text { text: "V";    color: "#464654"; font { pixelSize: 12; family: "Helvetica Neue" }
                                    anchors.baseline: parent.children[0].baseline }
                            }
                        }
                    }

                    Canvas {
                        width: 2; height: parent.height
                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0, 0, width, height)
                            c.setLineDash([3, 5])
                            c.beginPath(); c.moveTo(1, 6); c.lineTo(1, height - 6)
                            c.strokeStyle = "#20202e"; c.lineWidth = 1.5; c.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // ── ВРЕМЯ ─────────────────────────────────────────────
                    Item {
                        width: parent.width * 0.40; height: parent.height
                        Column {
                            anchors.centerIn: parent; spacing: 1
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "TIME"
                                color: "#303040"; font { pixelSize: 10; family: "Helvetica Neue"; letterSpacing: 0.8 }
                            }
                            Text {
                                id: clockText
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                                color: "#c0c0cc"
                                font { pixelSize: 22; bold: true; family: "Helvetica Neue" }
                            }
                        }
                    }
                }
            }
        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  ПРАВЫЙ ПРИБОР: TEMP (верхняя дуга) + FUEL (нижняя дуга)       ║
        // ║                                                                  ║
        // ║  TEMP: дуга от 9ч через 12ч до 3ч (180° через верх)            ║
        // ║   CSS: startRad=180°, sweep=180° (180→360°)                     ║
        // ║   Стрелка: rotation = 0 + fraction * 180   (0=9ч, 180=3ч)      ║
        // ║     fraction = (temp-50)/(130-50)                               ║
        // ║                                                                  ║
        // ║  FUEL: дуга от 3ч через 6ч до 9ч (180° через низ)              ║
        // ║   CSS: startRad=0°, sweep=180° (0→180°)                         ║
        // ║   Стрелка: rotation = -180 + fraction * 180  (0=9ч, 180=3ч)    ║
        // ║     Но чтобы стрелка шла снизу, rotation = fraction * 180       ║
        // ║     (при fraction=0: 0° → 3ч; fraction=1: 180° → 9ч)           ║
        // ║   Инвертируем: rotation = 180 - fraction * 180                  ║
        // ║     (при fraction=0: 180° = 9ч; fraction=1: 0° = 3ч/Full)      ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: rightZone
            x: gaugesArea.width - width - gaugesArea.width * 0.012
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real dialDiam: Math.min(width, height) * 0.87
            property real dialRad:  dialDiam * 0.5

            // Температура охлаждающей жидкости, 50..130°C, нейтраль ~90°C
            property real tempValue:    90.0
            property real tempFraction: (tempValue - 50.0) / 80.0   // (90-50)/80 = 0.5
            // Стрелка TEMP: rotation = tempFraction * 180 - 90
            // При fraction=0 (50°C): rotation=-90° (9 часов = слева)
            // При fraction=0.5 (90°C): rotation=0° (12 часов = вверх) — нейтраль
            // При fraction=1 (130°C): rotation=90° (3 часа = справа)
            property real tempNeedle: tempFraction * 180.0 - 90.0

            // Уровень топлива 0..1
            property real fuelFraction: 0.65
            // Стрелка FUEL: rotation = 90 - fuelFraction * 180
            // При fraction=0 (пусто): rotation=90° (3 часа = справа) — Empty справа
            // При fraction=0.5: rotation=0° (вниз = 6ч)
            // При fraction=1 (полный): rotation=-90° (9 часов = слева) — Full слева
            property real fuelNeedle: 90.0 - fuelFraction * 180.0

            Behavior on tempNeedle { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            Behavior on fuelNeedle { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

            ChromeWell {
                anchors.centerIn: parent
                dialSize: rightZone.dialDiam
            }

            // Горизонтальный разделитель внутри круга (визуальный)
            Rectangle {
                anchors.centerIn: parent
                width: rightZone.dialDiam * 0.72; height: 1
                color: "#1e1e2a"
            }

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
                    var r  = width * 0.41
                    var PI = Math.PI

                    // ══════════════════════════════════════════════════════
                    //  ВЕРХНЯЯ ПОЛОВИНА — ТЕМПЕРАТУРА (TEMP)
                    //  В Canvas верхняя полусфера — это углы от -PI (9 часов)
                    //  до 0 (3 часа) через верх.
                    // ══════════════════════════════════════════════════════

                    // Красная зона температуры (последние 15% шкалы перед 3 часами)
                    var redStartAngle = -PI * 0.15 // Примерно -27° (не доходя до 3 часов)
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 4, redStartAngle, 0, false) // по часовой стрелке к 0 (3 часам)
                    ctx.strokeStyle = "#7a1010"
                    ctx.lineWidth = 10
                    ctx.lineCap = "butt"
                    ctx.stroke()

                    // 8 делений температуры (равномерно распределяем по верхней дуге от -PI до 0)
                    var tempTicks = 8
                    for (var i = 0; i <= tempTicks; i++) {
                        var frac    = i / tempTicks
                        var angle   = -PI + frac * PI
                        var major   = (i % 2 === 0)
                        var tickLen = major ? 16 : 9
                        var isHot   = (frac >= 0.85)

                        // Отрисовка засечек шкал
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle) * (r - tickLen), cy + Math.sin(angle) * (r - tickLen))
                        ctx.lineTo(cx + Math.cos(angle) * (r + 1),        cy + Math.sin(angle) * (r + 1))
                        ctx.strokeStyle = isHot ? "#cc3030" : "#6c6c7a"
                        ctx.lineWidth = major ? 2.0 : 1.0
                        ctx.stroke()

                        if (major) {
                            var labels = ["50", "70", "90", "110", "130"]
                            var idx = i / 2

                            if (idx < labels.length) {
                                // Увеличили радиус (сделали r - 22 вместо r - 30), цифры встанут ближе к делениям
                                var lr = r - 22

                                ctx.save()
                                ctx.translate(
                                    cx + Math.cos(angle) * lr,
                                    cy + Math.sin(angle) * lr
                                )

                                // Улучшенный поворот: крайние цифры (50 и 130) оставляем ровными,
                                // а средние красиво наклоняем
                                if (idx === 0 || idx === 4) {
                                    ctx.rotate(0) // Строго горизонтально для 50 и 130
                                } else {
                                    ctx.rotate(angle + PI * 0.5) // Наклон по радиусу для 70, 90, 110
                                }

                                ctx.fillStyle = isHot ? "#ee4444" : "#b4b4c0"
                                ctx.font = "bold 13px sans-serif" // Сделали шрифт чуть компактнее (13px вместо 15px)
                                ctx.textAlign = "center"
                                ctx.textBaseline = "middle"

                                ctx.fillText(labels[idx], 0, 0)
                                ctx.restore()
                            }
                        }
                    }

                    // Перенесли название шкалы TEMP ниже центральной точки, чтобы она не сливалась с 90
                    ctx.fillStyle = "#6c6c7a"
                    ctx.font = "bold 11px sans-serif"
                    ctx.textAlign = "center"
                    ctx.fillText("TEMP", cx, cy - 35) // Теперь надпись аккуратно встанет НАД центром, но ПОД цифрой 90

                    ctx.fillStyle = "#2c3c48"
                    ctx.font = "11px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("TEMP", cx, cy - r * 0.73)

                    // ══════════════════════════════════════════════════════
                    //  НИЖНЯЯ ПОЛОВИНА — ТОПЛИВО
                    //  Дуга: от 0 (3ч = справа) до π (9ч = слева)
                    //  Идёт ЧЕРЕЗ НИЗ (по часовой = clockwise, anticlockwise=false)
                    //  ctx.arc(cx, cy, r, 0, PI, false)
                    // ══════════════════════════════════════════════════════
                    var fS = 0     // 3 часа = справа (Empty)
                    var fE = PI    // 9 часов = слева (Full)

                    // Оранжевая зона резерва: первые 15% от 3ч (Empty)
                    var resAngle = PI * 0.15  // 27°
                    ctx.beginPath()
                    ctx.arc(cx, cy, r - 4, fS, fS + resAngle, false)
                    ctx.strokeStyle = "#7a4000"; ctx.lineWidth = 10; ctx.lineCap = "butt"; ctx.stroke()

                    // 8 делений топлива
                    var fuelTicks = 8
                    for (var j = 0; j <= fuelTicks; j++) {
                        // frac=0 → 3ч (0°), frac=1 → 9ч (180°), идём вниз
                        var ff     = j / fuelTicks
                        var fa     = ff * PI                // CSS-угол 0°→180°
                        var fmaj   = (j % 2 === 0)
                        var flen   = fmaj ? 16 : 9
                        var isLow  = (ff <= 0.15)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(fa) * (r - flen), cy + Math.sin(fa) * (r - flen))
                        ctx.lineTo(cx + Math.cos(fa) * (r + 1),     cy + Math.sin(fa) * (r + 1))
                        ctx.strokeStyle = isLow ? "#cc7000" : "#6c6c7a"
                        ctx.lineWidth = fmaj ? 2.0 : 1.0; ctx.stroke()

                        if (fmaj) {
                            // Подписи: E, ½, F
                            var fuelLabels = ["E", "", "½", "", "F"]
                            var fuelLabelIdx = j / 2   // 0,1,2,3,4
                            var flr = r - 30
                            ctx.save()
                            ctx.translate(cx + Math.cos(fa) * flr, cy + Math.sin(fa) * flr)
                            ctx.rotate(fa + PI * 0.5)
                            ctx.fillStyle = isLow ? "#ff9922" : "#b4b4c0"
                            ctx.font = "bold 15px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(fuelLabels[fuelLabelIdx], 0, 0)
                            ctx.restore()
                        }
                    }

                    // Метка FUEL и иконка бензоколонки — нижний полукруг
                    ctx.fillStyle = "#8a6a20"
                    ctx.font = "18px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("⛽", cx, cy + r * 0.78)

                    ctx.fillStyle = "#3a2c14"
                    ctx.font = "11px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("FUEL", cx, cy + r * 0.62)
                }
                Component.onCompleted: requestPaint()
            }

            // Стрелка ТЕМПЕРАТУРЫ (верхний полукруг)
            // rotation=−90 → указывает влево (9ч = 50°C)
            // rotation=0   → указывает вверх (12ч = 90°C)
            // rotation=+90 → указывает вправо (3ч = 130°C)
            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.tempNeedle
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 3.5
                    height: rightZone.dialRad * 0.57
                    y: rightZone.dialRad - height
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ececec" }
                        GradientStop { position: 1.0; color: "#a0a0a0" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4; height: rightZone.dialRad * 0.12
                    y: rightZone.dialRad; radius: 2; color: "#b01818"
                }
            }

            // Стрелка ТОПЛИВА (нижний полукруг)
            // rotation=+90  → указывает вправо (3ч = E)
            // rotation=0    → указывает вниз  (6ч = ½)
            // rotation=−90  → указывает влево (9ч = F)
            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.fuelNeedle
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 3.5
                    height: rightZone.dialRad * 0.42

                    y: rightZone.dialRad

                    radius: 2

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ececec" }
                        GradientStop { position: 1.0; color: "#a0a0a0" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4; height: rightZone.dialRad * 0.12
                    y: rightZone.dialRad - height; radius: 2; color: "#b06010"
                }
            }

            NeedleCap { anchors.centerIn: parent; capSize: 26 }
        }
    }
}
