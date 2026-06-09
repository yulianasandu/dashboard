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

    // ─── фон ────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#18181e" }
            GradientStop { position: 0.6; color: "#0c0c10" }
            GradientStop { position: 1.0; color: "#080809" }
        }
    }

    // ─── фокус + клавиши ────────────────────────────────────────────────────
    // Углы поворота стрелок:
    //   Шкала начинается в 7 часов (225° от 12 часов по ч.стрелке).
    //   Qt rotation: 0 = вверх (12 часов), положительное = по часовой.
    //   7 часов = 225° от 12ч = rotation -135° относительно 12ч.
    //   Но стрелка нарисована указывающей вверх (к 12ч).
    //   Значит начальный угол стрелки на 0 ед. = -135°.
    //   Формула: rotation = -135 + fraction * 270

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

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 70 }
            spacing: 3
            Repeater {
                model: 2
                Text {
                    text: "◄"
                    font { pixelSize: 28 - index * 6; bold: true }
                    color: "#22dd55"
                    opacity: carController.leftBlinkerOn ? 1.0 : 0.06
                    Behavior on opacity { NumberAnimation { duration: 55 } }
                }
            }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 4 }
            text: "▲  АВАРИЙНАЯ"
            color: "#ff3a1a"
            font { pixelSize: 17; bold: true; family: "Helvetica Neue" }
            visible: carController.leftBlinker && carController.rightBlinker
            opacity: carController.leftBlinkerOn ? 1.0 : 0.08
            Behavior on opacity { NumberAnimation { duration: 55 } }
        }

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 4 }
            text: "W — ГАЗ    S — ТОРМОЗ    A — ◄    D — ►    F — АВАРИЙКА"
            color: "#282830"
            font { pixelSize: 13; family: "Helvetica Neue"; letterSpacing: 1.5 }
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 70 }
            spacing: 3
            Repeater {
                model: 2
                Text {
                    text: "►"
                    font { pixelSize: 22 + index * 6; bold: true }
                    color: "#22dd55"
                    opacity: carController.rightBlinkerOn ? 1.0 : 0.06
                    Behavior on opacity { NumberAnimation { duration: 55 } }
                }
            }
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: "#181820"
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  3 ПРИБОРА
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: gaugesArea
        anchors {
            top: topBar.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
            topMargin: 4; bottomMargin: 4
        }

        // ──────────────────────────────────────────────────────────────────
        //  Утилиты: хромированное кольцо (переиспользуемый компонент)
        // ──────────────────────────────────────────────────────────────────
        component ChromeRing: Item {
            property real dialSize: 300
            // Внешнее хромовое кольцо
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 26; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: parent.width * 0.36; centerY: parent.height * 0.25
                    centerRadius: parent.width * 0.52
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#909098" }
                    GradientStop { position: 0.30; color: "#383840" }
                    GradientStop { position: 0.58; color: "#d0d0d8" }
                    GradientStop { position: 0.80; color: "#252530" }
                    GradientStop { position: 1.0;  color: "#787882" }
                }
            }
            // Тонкий чёрный паз
            Rectangle {
                anchors.centerIn: parent
                width: dialSize + 8; height: width; radius: width / 2
                color: "#060608"
            }
            // Чаша циферблата
            Rectangle {
                anchors.centerIn: parent
                width: dialSize; height: width; radius: width / 2
                gradient: RadialGradient {
                    centerX: parent.width * 0.50; centerY: parent.height * 0.40
                    centerRadius: parent.width * 0.55
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0;  color: "#23232e" }
                    GradientStop { position: 0.50; color: "#111118" }
                    GradientStop { position: 1.0;  color: "#050507" }
                }
            }
        }

        // ──────────────────────────────────────────────────────────────────
        //  ТАХОМЕТР  (левый)
        //  Диапазон: 0..7 (x1000 rpm). Шкала 225°→-45° (270° охват).
        //  rotation = -135 + (rpm/7000) * 270
        // ──────────────────────────────────────────────────────────────────
        Item {
            id: tachZone
            x: gaugesArea.width * 0.015
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real d: Math.min(width, height) * 0.88   // диаметр
            property real r: d / 2

            // Формула угла: -135 + fraction * 270
            property real rpmFraction: carController.rpm / 7000.0
            property real needleAngle: -135.0 + rpmFraction * 270.0
            Behavior on needleAngle { NumberAnimation { duration: 75; easing.type: Easing.OutCubic } }

            ChromeRing {
                anchors.centerIn: parent
                dialSize: tachZone.d
            }

            // Шкала тахометра
            Canvas {
                id: tachCanvas
                anchors.centerIn: parent
                width: tachZone.d; height: width
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width/2, cy = height/2
                    var R  = width * 0.435
                    // 225° от 12ч по ч.стрелке = (225-90)=135° в CSS-координатах (от +X оси)
                    var startRad = 135 * Math.PI / 180
                    var totalRad = 270 * Math.PI / 180

                    // Красная зона: последние ~14% (6..7 тысяч)
                    var redFrac = 6/7
                    ctx.beginPath()
                    ctx.arc(cx, cy, R - 5, startRad + redFrac * totalRad, startRad + totalRad)
                    ctx.strokeStyle = "#991818"; ctx.lineWidth = 10; ctx.stroke()

                    // Деления: 7 главных (0..7) × 10 = 70 тиков
                    var totalTicks = 70
                    for (var i = 0; i <= totalTicks; i++) {
                        var frac  = i / totalTicks
                        var angle = startRad + frac * totalRad
                        var major = (i % 10 === 0)
                        var semi  = (i %  5 === 0) && !major
                        var len   = major ? 20 : (semi ? 13 : 7)
                        var isRed = (frac >= 6/7)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(R - len), cy + Math.sin(angle)*(R - len))
                        ctx.lineTo(cx + Math.cos(angle)*(R + 1),   cy + Math.sin(angle)*(R + 1))
                        ctx.strokeStyle = isRed ? (major ? "#ff4444" : "#772222") : (major ? "#d8d8d8" : (semi ? "#606068" : "#343438"))
                        ctx.lineWidth   = major ? 2.5 : (semi ? 1.5 : 0.8)
                        ctx.stroke()

                        if (major) {
                            var num = i / 10
                            var lr  = R - 36
                            var lx  = cx + Math.cos(angle) * lr
                            var ly  = cy + Math.sin(angle) * lr
                            ctx.save()
                            ctx.translate(lx, ly)
                            ctx.rotate(angle + Math.PI / 2)
                            ctx.fillStyle = isRed ? "#ff5555" : "#dcdce8"
                            ctx.font = "bold 21px 'Helvetica Neue'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(num, 0, 0)
                            ctx.restore()
                        }
                    }

                    // Метка
                    ctx.fillStyle = "#44444e"
                    ctx.font = "13px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("x1000 rpm", cx, cy - R * 0.26)
                }
                Component.onCompleted: requestPaint()
            }

            // Предупреждения
            Row {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: tachZone.d * 0.17 }
                spacing: 16
                Text { text: "🛢"; font.pixelSize: 22; opacity: 0.10 }
                Text { text: "⚙";  font.pixelSize: 22; color: "#ff9800"; opacity: 0.10 }
                Text { text: "🔋"; font.pixelSize: 22; opacity: 0.10 }
            }

            // Стрелка тахометра
            Item {
                id: tachNeedle
                anchors.centerIn: parent
                width: tachZone.d; height: width
                rotation: tachZone.needleAngle
                transformOrigin: Item.Center

                // тело стрелки (от центра вверх)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4
                    height: tachZone.r * 0.60
                    // нижний край стрелки = центр Item, т.е. y = R - height
                    y: tachZone.r - height
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f0" }
                        GradientStop { position: 0.8; color: "#d0d0d0" }
                        GradientStop { position: 1.0; color: "#888888" }
                    }
                }
                // хвост
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 5; height: tachZone.r * 0.13
                    y: tachZone.r
                    radius: 2; color: "#bb2020"
                }
            }

            // Колпак
            Rectangle {
                anchors.centerIn: parent
                width: 26; height: 26; radius: 13
                gradient: RadialGradient {
                    centerX: width*0.35; centerY: height*0.30; centerRadius: width*0.55
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0; color: "#606068" }
                    GradientStop { position: 1.0; color: "#0a0a0c" }
                }
                border { color: "#1e1e26"; width: 1 }
            }
        }

        // ──────────────────────────────────────────────────────────────────
        //  СПИДОМЕТР  (центральный)
        //  Диапазон: 0..200 км/ч. rotation = -135 + (speed/200)*270
        // ──────────────────────────────────────────────────────────────────
        Item {
            id: speedZone
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: gaugesArea.width * 0.44
            height: gaugesArea.height

            // Жёстко фиксированный диаметр, строго квадратный
            property real d: Math.min(width, height) * 0.96
            property real r: d / 2

            property real speedFraction: carController.speed / 200.0
            property real needleAngle: -135.0 + speedFraction * 270.0
            Behavior on needleAngle { NumberAnimation { duration: 75; easing.type: Easing.OutCubic } }

            // Хромовое кольцо — строго по центру, без offset
            ChromeRing {
                id: speedChrome
                anchors.centerIn: parent
                dialSize: speedZone.d
            }

            // Шкала спидометра
            Canvas {
                id: speedCanvas
                anchors.centerIn: parent
                width: speedZone.d
                height: speedZone.d   // строго квадратный
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width/2, cy = height/2
                    var R  = width * 0.435
                    var startRad = 135 * Math.PI / 180
                    var totalRad = 270 * Math.PI / 180

                    // 200 делений (каждые 1 км/ч), главные каждые 20
                    var totalTicks = 200
                    for (var i = 0; i <= totalTicks; i++) {
                        var frac  = i / totalTicks
                        var angle = startRad + frac * totalRad
                        var major = (i % 20 === 0)
                        var semi  = (i % 10 === 0) && !major
                        var len   = major ? 22 : (semi ? 14 : 6)

                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(R - len), cy + Math.sin(angle)*(R - len))
                        ctx.lineTo(cx + Math.cos(angle)*(R + 1),   cy + Math.sin(angle)*(R + 1))
                        ctx.strokeStyle = major ? "#d4d4d4" : (semi ? "#585862" : "#2c2c32")
                        ctx.lineWidth   = major ? 2.5 : (semi ? 1.5 : 0.7)
                        ctx.stroke()

                        if (major) {
                            var lr  = R - 40
                            var lx  = cx + Math.cos(angle) * lr
                            var ly  = cy + Math.sin(angle) * lr
                            ctx.save()
                            ctx.translate(lx, ly)
                            ctx.rotate(angle + Math.PI / 2)
                            ctx.fillStyle = "#e0e0e8"
                            ctx.font = "bold 22px 'Helvetica Neue'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(i, 0, 0)
                            ctx.restore()
                        }
                    }

                    // km/h
                    ctx.fillStyle = "#404048"
                    ctx.font = "15px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("km/h", cx, cy - R * 0.20)
                }
                Component.onCompleted: requestPaint()
            }

            // Стрелка спидометра
            Item {
                id: speedNeedle
                anchors.centerIn: parent
                width: speedZone.d
                height: speedZone.d
                rotation: speedZone.needleAngle
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 5
                    height: speedZone.r * 0.60
                    y: speedZone.r - height
                    radius: 2.5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ffffff" }
                        GradientStop { position: 0.80; color: "#e0e0e0" }
                        GradientStop { position: 1.0;  color: "#888888" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 6; height: speedZone.r * 0.14
                    y: speedZone.r
                    radius: 3; color: "#cc2020"
                }
            }

            // Колпак
            Rectangle {
                anchors.centerIn: parent
                width: 34; height: 34; radius: 17
                gradient: RadialGradient {
                    centerX: width*0.35; centerY: height*0.30; centerRadius: width*0.55
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0; color: "#686870" }
                    GradientStop { position: 1.0; color: "#080808" }
                }
                border { color: "#1e1e26"; width: 1 }
            }

            // ── Дисплей бортового компьютера — внутри спидометра ──────────
            Item {
                id: obcDisplay
                anchors {
                    bottom: parent.bottom
                    bottomMargin: speedZone.d * 0.04
                    horizontalCenter: parent.horizontalCenter
                }
                width: speedZone.d * 0.60
                height: 76

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "#07070c"
                    border { color: "#1c1c28"; width: 1 }

                    // Бликовая полоса сверху
                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: parent.height * 0.32; radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#13131e" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                Row {
                    anchors.fill: parent

                    // Передача
                    Item {
                        width: parent.width * 0.22; height: parent.height
                        Text {
                            anchors.centerIn: parent
                            text: carController.gear
                            color: "#00d4ea"
                            font { pixelSize: 40; bold: true; family: "Helvetica Neue" }
                        }
                    }

                    // Пунктирный разделитель
                    Canvas {
                        id: sep1
                        width: 2; height: parent.height
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0,0,width,height)
                            ctx.setLineDash([4, 5])
                            ctx.beginPath()
                            ctx.moveTo(1, 8); ctx.lineTo(1, height - 8)
                            ctx.strokeStyle = "#252535"; ctx.lineWidth = 1.5; ctx.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // Пробег + напряжение
                    Item {
                        width: parent.width * 0.36; height: parent.height
                        Column {
                            anchors.centerIn: parent; spacing: 4
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 5
                                Text { text: "4";    color: "#c0c0c8"; font { pixelSize: 19; family: "Helvetica Neue" } }
                                Text { text: "km";   color: "#505058"; font { pixelSize: 13; family: "Helvetica Neue" } }
                            }
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter; spacing: 4
                                Text { text: "13.6"; color: "#c0c0c8"; font { pixelSize: 19; family: "Helvetica Neue" } }
                                Text { text: "V";    color: "#505058"; font { pixelSize: 13; family: "Helvetica Neue" } }
                            }
                        }
                    }

                    Canvas {
                        id: sep2
                        width: 2; height: parent.height
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0,0,width,height)
                            ctx.setLineDash([4, 5])
                            ctx.beginPath()
                            ctx.moveTo(1, 8); ctx.lineTo(1, height - 8)
                            ctx.strokeStyle = "#252535"; ctx.lineWidth = 1.5; ctx.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }

                    // Время
                    Item {
                        width: parent.width * 0.40; height: parent.height
                        Text {
                            anchors.centerIn: parent
                            text: "02:54"
                            color: "#c8c8d4"
                            font { pixelSize: 26; bold: true; family: "Helvetica Neue" }
                        }
                    }
                }
            }
        }

        // ──────────────────────────────────────────────────────────────────
        //  ПРАВЫЙ ПРИБОР: Температура (верх) + Топливо (низ)
        //
        //  Чтобы стрелки не накладывались, делаем два отдельных сектора:
        //  - Температура: шкала 50→130°C, дуга от 225° до 315° (90°)
        //    → сверху-слева циферблата
        //  - Топливо: шкала 0→1, дуга от 315° до 45° (90°)
        //    → сверху-справа циферблата
        //  Т.к. обе занимают верхний полукруг — нижняя половина пустая
        //  (как у оригинала Vesta: стрелка температуры сверху-слева,
        //   стрелка топлива сверху-справа)
        // ──────────────────────────────────────────────────────────────────
        Item {
            id: rightZone
            x: gaugesArea.width - width - gaugesArea.width * 0.015
            y: 0
            width: gaugesArea.width * 0.265
            height: gaugesArea.height

            property real d: Math.min(width, height) * 0.88
            property real r: d / 2

            // Температура: 50..130°C, сектор 225°→315° (90° охват), нейтральная ~90°C
            // fraction = (90-50)/(130-50) = 40/80 = 0.5
            property real tempValue: 90.0
            property real tempFraction: (tempValue - 50.0) / 80.0
            // rotation: начало шкалы температуры = 225° от 12ч = -135° в Qt rotation
            // Охват 90°
            property real tempNeedle: -135.0 + tempFraction * 90.0
            Behavior on tempNeedle { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

            // Топливо: 0..1, сектор 315°→45° (90° охват, через 0°/360°)
            // 315° от 12ч = -45° в Qt rotation (начало шкалы = Empty=0)
            property real fuelFraction: 0.65
            property real fuelNeedle: -45.0 + fuelFraction * 90.0
            Behavior on fuelNeedle { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

            ChromeRing {
                anchors.centerIn: parent
                dialSize: rightZone.d
            }

            // Шкала правого прибора
            Canvas {
                id: rightCanvas
                anchors.centerIn: parent
                width: rightZone.d; height: width
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width/2, cy = height/2
                    var R  = width * 0.41
                    var toRad = Math.PI / 180

                    // ── ТЕМПЕРАТУРА: 225°→315° (вверх-слева) ────────────────
                    // В CSS-угловых координатах (+X = правая, 0°):
                    // 225° от 12ч = 135° в CSS; 315° от 12ч = 225° в CSS
                    var tStart = 135 * toRad   // 225° от 12ч
                    var tSweep =  90 * toRad   // 90° охват

                    // Красная зона: последние 15% (>120°C)
                    ctx.beginPath()
                    ctx.arc(cx, cy, R - 4, tStart + 0.85 * tSweep, tStart + tSweep)
                    ctx.strokeStyle = "#882010"; ctx.lineWidth = 9; ctx.stroke()

                    // Деления температуры
                    var tempLabels  = [50, 70, 90, 110, 130]
                    var tempTicks   = 8
                    for (var i = 0; i <= tempTicks; i++) {
                        var frac  = i / tempTicks
                        var angle = tStart + frac * tSweep
                        var major = (i % 2 === 0)
                        var len   = major ? 17 : 9
                        var isHot = (frac >= 0.85)
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle)*(R - len), cy + Math.sin(angle)*(R - len))
                        ctx.lineTo(cx + Math.cos(angle)*(R + 1),   cy + Math.sin(angle)*(R + 1))
                        ctx.strokeStyle = isHot ? "#cc3333" : "#7a7a88"
                        ctx.lineWidth = major ? 2 : 1; ctx.stroke()

                        if (major && i <= 8) {
                            var li  = i / 2   // 0..4
                            var lv  = 50 + li * 20
                            var lr  = R - 31
                            var lx  = cx + Math.cos(angle) * lr
                            var ly  = cy + Math.sin(angle) * lr
                            ctx.save(); ctx.translate(lx, ly); ctx.rotate(angle + Math.PI/2)
                            ctx.fillStyle = isHot ? "#ee4444" : "#c0c0cc"
                            ctx.font = "bold 16px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(lv, 0, 0)
                            ctx.restore()
                        }
                    }

                    // Пиктограмма термометра — левее центра, повыше
                    ctx.save()
                    ctx.fillStyle = "#6090b8"
                    ctx.font = "18px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("🌡", cx - R * 0.32, cy - R * 0.14)
                    ctx.restore()

                    // ── ТОПЛИВО: 315°→45° (вверх-справа) ───────────────────
                    // 315° от 12ч = 225° CSS; 45° от 12ч (=405°) = 315° CSS
                    var fStart = 225 * toRad
                    var fSweep =  90 * toRad

                    // Оранжевая зона резерва: первые 15% (=Empty)
                    ctx.beginPath()
                    ctx.arc(cx, cy, R - 4, fStart, fStart + fSweep * 0.15)
                    ctx.strokeStyle = "#8a4400"; ctx.lineWidth = 9; ctx.stroke()

                    var fuelLabelVals = ["0", "0.5", "1"]
                    var fuelTicks     = 8
                    for (var j = 0; j <= fuelTicks; j++) {
                        var ff    = j / fuelTicks
                        var fa    = fStart + ff * fSweep
                        var fmaj  = (j % 2 === 0)
                        var flen  = fmaj ? 17 : 9
                        var isLow = (ff <= 0.15)
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(fa)*(R - flen), cy + Math.sin(fa)*(R - flen))
                        ctx.lineTo(cx + Math.cos(fa)*(R + 1),    cy + Math.sin(fa)*(R + 1))
                        ctx.strokeStyle = isLow ? "#cc6600" : "#7a7a88"
                        ctx.lineWidth = fmaj ? 2 : 1; ctx.stroke()

                        if (fmaj) {
                            var fli = j / 4   // 0, 0.5, 1  (каждые 4 тика)
                            if (fli <= 2) {
                                var flv = fuelLabelVals[fli <= 2 ? Math.round(fli) : 0]
                                // только 0, 0.5, 1 → индексы 0/2/4/6/8 → fli=0,1,2
                                var flr = R - 31
                                var flx = cx + Math.cos(fa) * flr
                                var fly = cy + Math.sin(fa) * flr
                                ctx.save(); ctx.translate(flx, fly); ctx.rotate(fa + Math.PI/2)
                                ctx.fillStyle = isLow ? "#ff9922" : "#c0c0cc"
                                ctx.font = "bold 16px 'Helvetica Neue'"
                                ctx.textAlign = "center"; ctx.textBaseline = "middle"
                                ctx.fillText(["0","0.5","1"][j/4 < 1 ? 0 : (j/4 < 1.5 ? 0 : (j <= 4 ? j/4 : 2))], 0, 0)
                                ctx.restore()
                            }
                        }
                    }

                    // Пиктограмма бензоколонки — правее центра
                    ctx.save()
                    ctx.fillStyle = "#a08030"
                    ctx.font = "18px sans-serif"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("⛽", cx + R * 0.32, cy - R * 0.14)
                    ctx.restore()

                    // Нижний разделитель (горизонтальная линия по центру)
                    ctx.beginPath()
                    ctx.moveTo(cx - R * 0.55, cy + 4)
                    ctx.lineTo(cx + R * 0.55, cy + 4)
                    ctx.strokeStyle = "#1e1e28"; ctx.lineWidth = 1; ctx.stroke()

                    // Текст снизу
                    ctx.fillStyle = "#32323c"
                    ctx.font = "12px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("TEMP           FUEL", cx, cy + R * 0.40)
                }
                Component.onCompleted: requestPaint()
            }

            // Стрелка ТЕМПЕРАТУРЫ
            Item {
                anchors.centerIn: parent
                width: rightZone.d; height: rightZone.d
                rotation: rightZone.tempNeedle
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 3.5
                    height: rightZone.r * 0.56
                    y: rightZone.r - height
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f0" }
                        GradientStop { position: 1.0; color: "#aaaaaa" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4.5; height: rightZone.r * 0.12
                    y: rightZone.r; radius: 2; color: "#bb2020"
                }
            }

            // Стрелка ТОПЛИВА
            Item {
                anchors.centerIn: parent
                width: rightZone.d; height: rightZone.d
                rotation: rightZone.fuelNeedle
                transformOrigin: Item.Center

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 3.5
                    height: rightZone.r * 0.54
                    y: rightZone.r - height
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#f0f0f0" }
                        GradientStop { position: 1.0; color: "#aaaaaa" }
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4.5; height: rightZone.r * 0.12
                    y: rightZone.r; radius: 2; color: "#bb6600"
                }
            }

            // Колпак
            Rectangle {
                anchors.centerIn: parent
                width: 26; height: 26; radius: 13
                gradient: RadialGradient {
                    centerX: width*0.35; centerY: height*0.30; centerRadius: width*0.55
                    focalX: centerX; focalY: centerY
                    GradientStop { position: 0.0; color: "#606068" }
                    GradientStop { position: 1.0; color: "#0a0a0c" }
                }
                border { color: "#1e1e26"; width: 1 }
            }
        }
    }
}
