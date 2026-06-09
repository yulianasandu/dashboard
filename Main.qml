import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick
import QtQuick.Controls
import QtQuick.Window

import Automotive.Core 1.0

Window {
    id: root
    width: 1920
    height: 720
    visible: true
    title: "Lada Vesta Dashboard"
    color: "#0d0d0f"

    CarController {
        id: carController
    }

    // ── Захват фокуса сразу при запуске ─────────────────────────────────────
    Component.onCompleted: keyHandler.forceActiveFocus()

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: true

        // Клик по окну тоже возвращает фокус
        MouseArea {
            anchors.fill: parent
            onClicked: keyHandler.forceActiveFocus()
            propagateComposedEvents: true
        }

        Keys.onPressed: function(event) {
            if (event.isAutoRepeat) return

            switch (event.key) {
            case Qt.Key_W:
                carController.setThrottle(true)
                break

            case Qt.Key_S:
                carController.setBrake(true)
                break

            case Qt.Key_A:
                carController.toggleLeftBlinker()
                break

            case Qt.Key_D:
                carController.toggleRightBlinker()
                break

            case Qt.Key_F:
                carController.toggleHazard()
                break
            }
        }

        Keys.onReleased: function(event) {
            if (event.isAutoRepeat) return

            switch (event.key) {
            case Qt.Key_W:
                carController.setThrottle(false)
                break

            case Qt.Key_S:
                carController.setBrake(false)
                break
            }
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  ВЕРХНЯЯ ПОЛОСА — поворотники
    // ════════════════════════════════════════════════════════════════
    Item {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 56

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 60 }
            spacing: -4
            Repeater {
                model: 2
                Text {
                    text: "◀"
                    font.pixelSize: 28 - index
                    color: "#00e676"
                    opacity: carController.leftBlinkerOn ? (1.0 - index * 0.25) : 0.05
                    Behavior on opacity { NumberAnimation { duration: 60 } }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            text: "W — газ    S — тормоз    A — ◀    D — ▶    F — аварийка"
            color: "#383838"
            font { pixelSize: 15; family: "Helvetica Neue, Helvetica" }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 6
            text: "⚠  АВАРИЙНАЯ"
            color: "#ff6d00"
            font { pixelSize: 17; bold: true; family: "Helvetica Neue" }
            visible: carController.leftBlinker && carController.rightBlinker
            opacity: carController.leftBlinkerOn ? 1.0 : 0.15
            Behavior on opacity { NumberAnimation { duration: 60 } }
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 60 }
            spacing: -4
            Repeater {
                model: 2
                Text {
                    text: "▶"
                    font.pixelSize: 28 + index
                    color: "#00e676"
                    opacity: carController.rightBlinkerOn ? (0.5 + index * 0.25) : 0.05
                    Behavior on opacity { NumberAnimation { duration: 60 } }
                }
            }
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: "#1c1c1e"
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  ОСНОВНАЯ ОБЛАСТЬ — 3 ЦИФЕРБЛАТА
    // ════════════════════════════════════════════════════════════════
    Row {
        anchors {
            top: topBar.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
            topMargin: 10; bottomMargin: 10
            leftMargin: 40; rightMargin: 40
        }
        spacing: 0

        // ── ТАХОМЕТР (левый) ─────────────────────────────────────────────
        Item {
            id: tachZone
            width: parent.width * 0.28
            height: parent.height

            property real dialSize: Math.min(width, height) * 0.88

            Rectangle {
                anchors.centerIn: parent
                width: tachZone.dialSize; height: tachZone.dialSize; radius: width / 2
                color: "#141418"; border { color: "#2a2a30"; width: 3 }
            }

            Canvas {
                id: tachCanvas
                anchors.centerIn: parent
                width: tachZone.dialSize; height: tachZone.dialSize

                property real rpmFraction: (carController.rpm - 800) / (6000 - 800)
                onRpmFractionChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width / 2, cy = height / 2
                    var R = width * 0.42
                    var startRad = 225 * Math.PI / 180
                    var totalRad = 270 * Math.PI / 180

                    ctx.beginPath()
                    ctx.arc(cx, cy, R, startRad, startRad + totalRad)
                    ctx.strokeStyle = "#222228"; ctx.lineWidth = 16; ctx.stroke()

                    var steps = 14
                    for (var i = 0; i <= steps; i++) {
                        var frac = i / steps
                        var angle = startRad + frac * totalRad
                        var isMajor = (i % 2 === 0)
                        var r1 = R - (isMajor ? 18 : 10)
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle) * r1, cy + Math.sin(angle) * r1)
                        ctx.lineTo(cx + Math.cos(angle) * (R + 2), cy + Math.sin(angle) * (R + 2))
                        ctx.strokeStyle = (i >= 12) ? "#c62828" : "#555560"
                        ctx.lineWidth = isMajor ? 3 : 1.5; ctx.stroke()
                        if (isMajor) {
                            var labelR = R - 30
                            ctx.fillStyle = (i >= 12) ? "#ef5350" : "#aaaaaa"
                            ctx.font = "bold 18px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(i / 2, cx + Math.cos(angle) * labelR, cy + Math.sin(angle) * labelR)
                        }
                    }

                    ctx.fillStyle = "#555560"; ctx.font = "13px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.fillText("×1000 об/мин", cx, cy + R * 0.55)

                    var sweep = totalRad * rpmFraction
                    if (sweep > 0.01) {
                        var grad = ctx.createLinearGradient(0, 0, width, 0)
                        if (rpmFraction > 0.8) {
                            grad.addColorStop(0, "#0288d1"); grad.addColorStop(0.7, "#f57c00"); grad.addColorStop(1.0, "#c62828")
                        } else {
                            grad.addColorStop(0, "#0288d1"); grad.addColorStop(1, "#00bcd4")
                        }
                        ctx.beginPath(); ctx.arc(cx, cy, R, startRad, startRad + sweep)
                        ctx.strokeStyle = grad; ctx.lineWidth = 6; ctx.lineCap = "round"; ctx.stroke()
                    }

                    var needleAngle = startRad + rpmFraction * totalRad
                    var nLen = R - 22
                    ctx.save(); ctx.translate(cx, cy); ctx.rotate(needleAngle)
                    ctx.beginPath(); ctx.moveTo(-12, 0); ctx.lineTo(nLen, 0)
                    ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 2.5; ctx.lineCap = "round"; ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(-12, 0); ctx.lineTo(-28, 0)
                    ctx.strokeStyle = "#ef5350"; ctx.lineWidth = 2; ctx.stroke()
                    ctx.restore()

                    ctx.beginPath(); ctx.arc(cx, cy, 8, 0, Math.PI * 2)
                    ctx.fillStyle = "#0d0d0f"; ctx.fill()
                    ctx.beginPath(); ctx.arc(cx, cy, 3, 0, Math.PI * 2)
                    ctx.fillStyle = "#555"; ctx.fill()
                }
            }

            Text {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 20 }
                text: Math.round(carController.rpm)
                color: carController.rpm > 5200 ? "#ef5350" : "#cccccc"
                font { pixelSize: 28; bold: true; family: "Helvetica Neue, Helvetica" }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        // ── СПИДОМЕТР (центральный) ───────────────────────────────────────
        Item {
            id: speedZone
            width: parent.width * 0.44
            height: parent.height

            property real dialSize: Math.min(width, height) * 0.94

            Rectangle {
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -16 }
                width: speedZone.dialSize; height: speedZone.dialSize; radius: width / 2
                color: "#141418"; border { color: "#2a2a30"; width: 3 }
            }

            Canvas {
                id: speedCanvas
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -16 }
                width: speedZone.dialSize; height: speedZone.dialSize

                property real speedFraction: carController.speed / 200.0
                onSpeedFractionChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width / 2, cy = height / 2
                    var R = width * 0.42
                    var startRad = 225 * Math.PI / 180
                    var totalRad = 270 * Math.PI / 180

                    ctx.beginPath(); ctx.arc(cx, cy, R, startRad, startRad + totalRad)
                    ctx.strokeStyle = "#222228"; ctx.lineWidth = 18; ctx.stroke()

                    var stepCount = 20
                    for (var i = 0; i <= stepCount; i++) {
                        var frac = i / stepCount
                        var angle = startRad + frac * totalRad
                        var isMajor = (i % 2 === 0)
                        var r1 = R - (isMajor ? 22 : 12)
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(angle) * r1, cy + Math.sin(angle) * r1)
                        ctx.lineTo(cx + Math.cos(angle) * (R + 2), cy + Math.sin(angle) * (R + 2))
                        ctx.strokeStyle = "#555560"; ctx.lineWidth = isMajor ? 3 : 1.5; ctx.stroke()
                        if (isMajor) {
                            var labelR = R - 36
                            ctx.fillStyle = "#bbbbbb"; ctx.font = "bold 20px 'Helvetica Neue'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(i * 10, cx + Math.cos(angle) * labelR, cy + Math.sin(angle) * labelR)
                        }
                    }

                    ctx.fillStyle = "#555560"; ctx.font = "16px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.fillText("km/h", cx, cy + R * 0.52)

                    var sweep = totalRad * speedFraction
                    if (sweep > 0.01) {
                        ctx.beginPath(); ctx.arc(cx, cy, R, startRad, startRad + sweep)
                        ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 5; ctx.lineCap = "round"; ctx.stroke()
                    }

                    var needleAngle = startRad + speedFraction * totalRad
                    var nLen = R - 18
                    ctx.save(); ctx.translate(cx, cy); ctx.rotate(needleAngle)
                    ctx.beginPath(); ctx.moveTo(-14, 0); ctx.lineTo(nLen, 0)
                    ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 3; ctx.lineCap = "round"; ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(-14, 0); ctx.lineTo(-32, 0)
                    ctx.strokeStyle = "#ef5350"; ctx.lineWidth = 2.5; ctx.stroke()
                    ctx.restore()

                    ctx.beginPath(); ctx.arc(cx, cy, 8, 0, Math.PI * 2); ctx.fillStyle = "#0d0d0f"; ctx.fill()
                    ctx.beginPath(); ctx.arc(cx, cy, 3, 0, Math.PI * 2); ctx.fillStyle = "#333"; ctx.fill()

                }
            }

            // Цифровой дисплей снизу
            Item {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
                width: 360; height: 80

                Rectangle {
                    anchors.fill: parent; radius: 6
                    color: "#0a0a0c"; border { color: "#222"; width: 1 }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 24

                    Text {
                        text: carController.gear
                        color: "#00e5ff"
                        font { pixelSize: 44; bold: true; family: "Helvetica Neue, Helvetica" }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle { width: 1; height: 60; color: "#2a2a2a"; anchors.verticalCenter: parent.verticalCenter }

                    Column {
                        spacing: 6; anchors.verticalCenter: parent.verticalCenter
                        Row {
                            spacing: 8
                            Text { width: 100; horizontalAlignment: Text.AlignHCenter; text: "13.6"; color: "#aaaaaa"; font { pixelSize: 18; family: "Helvetica Neue" } }
                        }
                        Row {
                            spacing: 8
                            Text { width: 100; horizontalAlignment: Text.AlignHCenter; text: "02:54"; color: "#aaaaaa"; font { pixelSize: 18; bold: true; family: "Helvetica Neue" } }
                        }
                    }

                    Rectangle { width: 1; height: 60; color: "#2a2a2a"; anchors.verticalCenter: parent.verticalCenter }

                    Column {
                        spacing: 2; anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(carController.speed)
                            color: "#ffffff"
                            font { pixelSize: 40; bold: true; family: "Helvetica Neue" }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "км/ч"; color: "#555"
                            font { pixelSize: 13; family: "Helvetica Neue" }
                        }
                    }
                }
            }
        }

        // ── ПРАВАЯ ПАНЕЛЬ: температура + топливо ─────────────────────────
        Item {
            id: rightZone
            width: parent.width * 0.28
            height: parent.height

            property real dialSize: Math.min(width, height) * 0.88

            Rectangle {
                anchors.centerIn: parent
                width: rightZone.dialSize; height: rightZone.dialSize; radius: width / 2
                color: "#141418"; border { color: "#2a2a30"; width: 3 }
            }

            Canvas {
                id: rightCanvas
                anchors.centerIn: parent
                width: rightZone.dialSize; height: rightZone.dialSize

                property real tempFrac: 0.62
                property real fuelFrac: 0.65

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width / 2, cy = height / 2
                    var R = width * 0.40
                    var startRad = 225 * Math.PI / 180
                    var totalRad = 270 * Math.PI / 180
                    var midRad = startRad + totalRad * 0.5

                    // Фон обеих дуг
                    ctx.beginPath(); ctx.arc(cx, cy, R, startRad, startRad + totalRad)
                    ctx.strokeStyle = "#222228"; ctx.lineWidth = 14; ctx.stroke()

                    // Деления температуры
                    var tempLabels = [0, 50, 90, 130]
                    for (var i = 0; i < tempLabels.length; i++) {
                        var f = tempLabels[i] / 130
                        var ang = startRad + f * (totalRad * 0.5)
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(ang) * (R - 14), cy + Math.sin(ang) * (R - 14))
                        ctx.lineTo(cx + Math.cos(ang) * (R + 2), cy + Math.sin(ang) * (R + 2))
                        ctx.strokeStyle = "#555560"; ctx.lineWidth = 2; ctx.stroke()
                        ctx.fillStyle = "#888"; ctx.font = "14px 'Helvetica Neue'"
                        ctx.textAlign = "center"; ctx.textBaseline = "middle"
                        ctx.fillText(tempLabels[i], cx + Math.cos(ang) * (R - 28), cy + Math.sin(ang) * (R - 28))
                    }

                    // Активная дуга температуры
                    var tempSweep = totalRad * 0.5 * tempFrac
                    if (tempSweep > 0.01) {
                        var tg = ctx.createLinearGradient(0, cy, width, cy)
                        tg.addColorStop(0, "#1565c0"); tg.addColorStop(0.6, "#2196f3"); tg.addColorStop(1.0, "#ef5350")
                        ctx.beginPath(); ctx.arc(cx, cy, R, startRad, startRad + tempSweep)
                        ctx.strokeStyle = tg; ctx.lineWidth = 5; ctx.lineCap = "round"; ctx.stroke()
                    }

                    // Стрелка температуры
                    var tAngle = startRad + tempFrac * totalRad * 0.5
                    ctx.save(); ctx.translate(cx, cy); ctx.rotate(tAngle)
                    ctx.beginPath(); ctx.moveTo(-10, 0); ctx.lineTo(R - 16, 0)
                    ctx.strokeStyle = "#90caf9"; ctx.lineWidth = 2; ctx.lineCap = "round"; ctx.stroke()
                    ctx.restore()

                    // Деления топлива
                    var fuelMarks = [0, 0.5, 1]
                    var fuelLabels2 = ["0", "0.5", "1"]
                    for (var j = 0; j < fuelMarks.length; j++) {
                        var fa = midRad + fuelMarks[j] * totalRad * 0.5
                        ctx.beginPath()
                        ctx.moveTo(cx + Math.cos(fa) * (R - 14), cy + Math.sin(fa) * (R - 14))
                        ctx.lineTo(cx + Math.cos(fa) * (R + 2), cy + Math.sin(fa) * (R + 2))
                        ctx.strokeStyle = "#555560"; ctx.lineWidth = 2; ctx.stroke()
                        ctx.fillStyle = "#888"; ctx.font = "14px 'Helvetica Neue'"
                        ctx.textAlign = "center"; ctx.textBaseline = "middle"
                        ctx.fillText(fuelLabels2[j], cx + Math.cos(fa) * (R - 28), cy + Math.sin(fa) * (R - 28))
                    }

                    // Активная дуга топлива
                    var fuelSweep = totalRad * 0.5 * fuelFrac
                    if (fuelSweep > 0.01) {
                        ctx.beginPath(); ctx.arc(cx, cy, R, midRad, midRad + fuelSweep)
                        ctx.strokeStyle = "#4caf50"; ctx.lineWidth = 5; ctx.lineCap = "round"; ctx.stroke()
                    }

                    // Стрелка топлива
                    var fAngle = midRad + fuelFrac * totalRad * 0.5
                    ctx.save(); ctx.translate(cx, cy); ctx.rotate(fAngle)
                    ctx.beginPath(); ctx.moveTo(-10, 0); ctx.lineTo(R - 16, 0)
                    ctx.strokeStyle = "#a5d6a7"; ctx.lineWidth = 2; ctx.lineCap = "round"; ctx.stroke()
                    ctx.restore()

                    // Центральный болт
                    ctx.beginPath(); ctx.arc(cx, cy, 8, 0, Math.PI * 2); ctx.fillStyle = "#0d0d0f"; ctx.fill()
                    ctx.beginPath(); ctx.arc(cx, cy, 3, 0, Math.PI * 2); ctx.fillStyle = "#333"; ctx.fill()

                    // Текстовые иконки
                    ctx.fillStyle = "#90caf9"; ctx.font = "20px 'Helvetica Neue'"
                    ctx.textAlign = "center"; ctx.textBaseline = "middle"
                    ctx.fillText("T°", cx - R * 0.38, cy + R * 0.35)
                    ctx.fillStyle = "#a5d6a7"
                    ctx.fillText("E/F", cx + R * 0.38, cy + R * 0.35)
                }
            }

            // Значения под циферблатом
            Row {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 16 }
                spacing: 30

                Column {
                    spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "80°C"; color: "#90caf9"; font { pixelSize: 22; bold: true; family: "Helvetica Neue" } }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "двигатель"; color: "#444"; font { pixelSize: 12; family: "Helvetica Neue" } }
                }

                Rectangle { width: 1; height: 40; color: "#222"; anchors.verticalCenter: parent.verticalCenter }

                Column {
                    spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "65%"; color: "#a5d6a7"; font { pixelSize: 22; bold: true; family: "Helvetica Neue" } }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "топливо"; color: "#444"; font { pixelSize: 12; family: "Helvetica Neue" } }
                }
            }
        }
    }
}
