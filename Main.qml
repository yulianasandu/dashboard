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
            else if (event.key === Qt.Key_Tab) {
                    tachZone.useExternalData = !tachZone.useExternalData
                    console.log("Режим изменен! Внешние данные (ESP32): " + tachZone.useExternalData)
            }
            else if ("cс".includes(key)) {
                    speedZone.obcPage = (speedZone.obcPage + 1) % 4
            }
            else if ("vм".includes(key)) {
                    speedZone.obcTotalFuelUsedL = 0
                    speedZone.obcTotalDistanceKm = 0
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
        console.log("HB =", CanReceiver.highBeam)
        console.log("LB =", CanReceiver.lowBeam)
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  ЗОНА ПРИБОРОВ
    // ═══════════════════════════════════════════════════════════════════════
    Item {
        id: gaugesArea
        anchors {
            top: parent.top; bottom: parent.bottom
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
            x: gaugesArea.width * 0.5 - speedZone.dialDiam * 0.5 + tachZone.dialDiam * 0.25 - tachZone.width
            y: 0
            width: gaugesArea.width * 0.35
            height: gaugesArea.height
            z: 0

            property bool useExternalData: true
            property bool oilWarning: false
            property bool engineWarning: false
            property bool batteryWarning: false

            property real dialDiam: Math.min(width, height) * 0.94
            property real dialRad:  dialDiam * 0.5
            property real rpmFraction: Math.min((useExternalData ? CanReceiver.rpm : carController.rpm) / 7000.0, 1.0)
            property real needleAngle: -170.0 + rpmFraction * 243.0

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
                    var r  = width * 0.40
                    var startRad = 130.0 * Math.PI / 180.0
                    var totalRad = 180.0 * Math.PI / 180.0

                    var stepCount = 70

                    for (var i = 0; i <= stepCount; i += 5) {
                        var frac  = i / parseFloat(stepCount)
                        var angle = startRad + frac * totalRad

                        var major = (i % 10 === 0)
                        var semi  = (i % 5 === 0) && !major

                        var tlen = major ? 28 : 18
                        var baseWidth = major ? 18.0 : 10.0

                        var isRed = (frac > 6.0/7.0 - 0.005)
                        var perpAngle = angle + Math.PI * 0.5

                        // Вычисляем координаты трех точек
                        var tipX = cx + Math.cos(angle) * (r - tlen)
                        var tipY = cy + Math.sin(angle) * (r - tlen)

                        var baseLeftX = cx + Math.cos(angle) * (r + 1) - Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseLeftY = cy + Math.sin(angle) * (r + 1) - Math.sin(perpAngle) * (baseWidth * 0.5)

                        var baseRightX = cx + Math.cos(angle) * (r + 1) + Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseRightY = cy + Math.sin(angle) * (r + 1) + Math.sin(perpAngle) * (baseWidth * 0.5)

                        // 1. ОТРИСОВКА ОТКРЫТОЙ V-ОБРАЗНОЙ СТРЕЛКИ (без основания)
                        ctx.beginPath()
                        ctx.moveTo(baseLeftX, baseLeftY)   // Начинаем с левого угла на линии шкалы
                        ctx.lineTo(tipX, tipY)             // Ведем линию к кончику (внутрь)
                        ctx.lineTo(baseRightX, baseRightY) // Ведем линию к правому углу на линии шкалы
                        // ctx.closePath() -> УБРАНО, чтобы не рисовалось дно треугольника

                        ctx.strokeStyle = isRed ? "#ff3030" : "#d8d8d8"
                        ctx.lineWidth = major ? 2.0 : 1.2
                        ctx.stroke()

                        // 2. ОТРИСОВКА ПРЕРЫВИСТОЙ ЛИНИИ ШКАЛЫ
                        if (i < stepCount) {
                            var nextI = i + 5
                            var nextFraction = nextI / parseFloat(stepCount)

                            // Делаем зазор минимальным (1 пиксель), чтобы линия шкалы подходила встык к «ушкам» стрелок
                            var currentGap = (baseWidth * 0.5 + 1.0) / r

                            var nextMajor = (nextI % 10 === 0)
                            var nextBaseWidth = nextMajor ? 18.0 : 10.0
                            var nextGap = (nextBaseWidth * 0.5 + 1.0) / r

                            var arcStartAngle = angle + currentGap
                            var arcEndAngle = (startRad + nextFraction * totalRad) - nextGap

                            if (arcStartAngle < arcEndAngle) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r + 1, arcStartAngle, arcEndAngle, false)
                                ctx.strokeStyle = isRed ? "#ff3030" : "#f0f0f0"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        // 3. ВЫВОД ЦИФР ШКАЛЫ
                        if (major) {
                            var num = i / 10
                            var lr = r + 32

                            ctx.save()
                            ctx.translate(cx + Math.cos(angle) * lr, cy + Math.sin(angle) * lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#f5f5f5"
                            ctx.font = "bold 23px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(num, 0, 0)
                            ctx.restore()
                        }
                    }
                }
                Component.onCompleted: requestPaint()
            }

            Item {
                id: tachIcons

                width: tachZone.dialDiam
                height: tachZone.dialDiam
                anchors.centerIn: parent

                // Размер иконок жестко зависит от диаметра прибора (10%)
                property real iconSize: tachZone.dialDiam * 0.10

                // РАДИУСЫ ЭТАЖЕЙ:
                property real topArcRadius: tachZone.dialRad * 0.30     // Верхний этаж (Масло, Чек, Аккумулятор)
                property real bottomArcRadius: tachZone.dialRad * 0.58  // Нижний этаж (ABS, Ручник, Руль)

                // ИСПРАВЛЕНО: Радиус для верхних иконок уменьшен с 0.76 до 0.60,
                // чтобы они опустились ниже, ближе к шкале
                property real upperArcRadius: tachZone.dialRad * 0.60

                // СМЕЩЕНИЕ ГРУППЫ:
                property real shiftXFrac: 0.12
                property real shiftYFrac: 0.26

                // Вспомогательные адаптивные функции тригонометрии
                function posX(angleDeg, radius) {
                    return width / 2
                           + Math.cos(angleDeg * Math.PI / 180) * radius
                           + (tachZone.dialRad * tachIcons.shiftXFrac)
                }
                function posY(angleDeg, radius) {
                    return height / 2
                           + Math.sin(angleDeg * Math.PI / 180) * radius
                           + (tachZone.dialRad * tachIcons.shiftYFrac)
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/oil_pressure.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(170, tachIcons.topArcRadius) - width / 2
                    y: tachIcons.posY(120, tachIcons.topArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.oilPressure    : tachZone.oilWarning
                }

                // 2. Чек двигателя
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/check_engine.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(95, tachIcons.topArcRadius) - width / 2
                    y: tachIcons.posY(100, tachIcons.topArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.checkEngine    : tachZone.engineWarning
                }

                // 3. Аккумулятор
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/battery.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(25, tachIcons.topArcRadius) - width / 2
                    y: tachIcons.posY(45, tachIcons.topArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.batteryWarning : tachZone.batteryWarning
                }
                // 4. ABS тормозов
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/abs.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(140, tachIcons.bottomArcRadius) - width / 2
                    y: tachIcons.posY(120, tachIcons.bottomArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.absWarning     : tachZone.batteryWarning
                }

                // 5. тормоза
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/brake_system.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(95, tachIcons.bottomArcRadius) - width / 2
                    y: tachIcons.posY(110, tachIcons.bottomArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.handBrake      : tachZone.batteryWarning
                }

                // 6. ЭУР / Руль
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/power_steering.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    x: tachIcons.posX(55, tachIcons.bottomArcRadius) - width / 2
                    y: tachIcons.posY(55, tachIcons.bottomArcRadius) - height / 2
                    visible: tachZone.useExternalData ? CanReceiver.steeringWarning: tachZone.batteryWarning
                }

                // ========================================================================= //
                // ВЕРХНИЙ БЛОК ИКОНОК (ИСПРАВЛЕНО: СИНХРОННЫЕ УГЛЫ И РАДИУС ВЫШЕ К ШКАЛЕ)    //
                // ========================================================================= //

                // 7. НАЖАТИЕ НА ТОРМОЗ (Зеленая иконка) — левее, под цифрой 3-4
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/auto_hold.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    visible: tachZone.useExternalData ? CanReceiver.pressBrakePedal : false

                    // ИСПРАВЛЕНО: Углы синхронизированы на 210°
                    x: tachIcons.posX(290, tachZone.dialRad * 0.85) - width / 2
                    y: tachIcons.posY(350, tachZone.dialRad * 0.85) - height / 2
                }

                // 8. РУЧНИК (Красная иконка)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/hand_brake.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    visible: tachZone.useExternalData ? CanReceiver.handBrake : false

                    x: tachIcons.posX(270, tachZone.dialRad * 0.85) - width / 2
                    y: tachIcons.posY(320, tachZone.dialRad * 0.85) - height / 2
                }

                // 9. РЕМЕНЬ БЕЗОПАСНОСТИ — строго по центру вверху, под цифрой 5
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/seatbelt.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    visible: tachZone.useExternalData ? CanReceiver.seatbelt : tachZone.oilWarning

                    // ИСПРАВЛЕНО: Углы синхронизированы на 270° (строгий верх окружности)
                    x: tachIcons.posX(270, tachZone.dialRad * 0.85) - width / 2
                    y: tachIcons.posY(270, tachZone.dialRad * 0.85) - height / 2
                }

                // 10. КРУИЗ-КОНТРОЛЬ (Зеленый спидометр) — правее центра, под цифрой 5-6
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/cruise.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    visible: tachZone.useExternalData ? (CanReceiver.cruiseSetSpeed > 0) : false

                    // ИСПРАВЛЕНО: Углы синхронизированы на 300°
                    x: tachIcons.posX(290, tachZone.dialRad * 0.85) - width / 2
                    y: tachIcons.posY(305, tachZone.dialRad * 0.85) - height / 2
                }

                // 11. ПОДУШКА БЕЗОПАСНОСТИ — правее, у начала красной зоны (цифра 6)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/airbag.svg"
                    width: tachIcons.iconSize; height: width
                    fillMode: Image.PreserveAspectFit
                    visible: tachZone.useExternalData ? CanReceiver.airbagFault : false

                    // ИСПРАВЛЕНО: Углы синхронизированы на 330°
                    x: tachIcons.posX(290, tachZone.dialRad * 0.85) - width / 2
                    y: tachIcons.posY(330, tachZone.dialRad * 0.85) - height / 2
                }
            }
            // Стрелка тахометра
            Item {
                id: tachNeedleContainer
                anchors.centerIn: parent
                width: tachZone.dialDiam; height: tachZone.dialDiam
                rotation: tachZone.needleAngle
                transformOrigin: Item.Center
                Behavior on rotation { NumberAnimation { duration: 120; easing.type: Easing.Linear } }

                Shape {
                    id: tachNeedleShape
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 50
                    height: tachZone.dialRad * 0.65 // Оптимальный вылет для шкалы оборотов двигателя
                    y: tachZone.dialRad - height   // Позиционирование от центра вращения вверх

                    layer.enabled: true
                    layer.samples: 4 // Идеальное сглаживание вектора при движении по кругу

                    ShapePath {
                        strokeColor: "#ffffff"
                        strokeWidth: 2.5 // Толщина белой границы стрелки
                        fillColor: "#0c0c0e"
                        joinStyle: ShapePath.RoundJoin // Аккуратные скругленные углы

                        // Старт с кончика стрелки (сверху по центру)
                        startX: tachNeedleShape.width / 2
                        startY: 0

                        // Рисуем грани треугольника по контуру
                        PathLine { x: tachNeedleShape.width; y: tachNeedleShape.height }
                        PathLine { x: 0; y: tachNeedleShape.height }
                        PathLine { x: tachNeedleShape.width / 2; y: 0 }
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

        }

        // ╔══════════════════════════════════════════════════════════════════╗
        // ║  СПИДОМЕТР  (центральный)                                        ║
        // ╚══════════════════════════════════════════════════════════════════╝
        Item {
            id: speedZone
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: gaugesArea.width * 0.44
            height: gaugesArea.height
            z: 1

            property bool useExternalData: tachZone.useExternalData

            property real dialDiam: Math.min(width, height) * 0.94
            property real dialRad:  dialDiam * 0.5
            property real speedFraction: (useExternalData ? CanReceiver.speed : carController.speed) / 200.0
            property real needleAngle: -120.0 + speedFraction * 240.0

            // ── Бортовой компьютер (считается на стороне Qt, из уже полученных сигналов) ──
            property real obcTankCapacityL: 55.0

            property real obcCurrentSpeed: useExternalData ? CanReceiver.speed : carController.speed
            property real obcCurrentRpm:   useExternalData ? CanReceiver.rpm   : carController.rpm
            property real obcFuelPercent:  useExternalData ? Number(CanReceiver.fuel || 0) : 65.0
            property real obcFuelLiters:   obcFuelPercent / 100.0 * obcTankCapacityL

            property real obcInstLph:  0.55 + (obcCurrentRpm / 1000.0) * 0.42
            property real obcInstL100: obcCurrentSpeed > 5 ? (obcInstLph / obcCurrentSpeed * 100.0) : 0

            property real obcTotalFuelUsedL: 0
            property real obcTotalDistanceKm: 0
            property real obcAvgL100: obcTotalDistanceKm > 0.1
                ? (obcTotalFuelUsedL / obcTotalDistanceKm * 100.0)
                : 0
            property real obcRangeKm: obcAvgL100 > 0.1
                ? (obcFuelLiters / obcAvgL100 * 100.0)
                : 999

            property int  obcPage: 0        // 0=часы, 1=мгн.расход, 2=ср.расход, 3=запас хода
            property date obcNow: new Date()

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: {
                    speedZone.obcTotalFuelUsedL  += speedZone.obcInstLph / 3600.0
                    speedZone.obcTotalDistanceKm += speedZone.obcCurrentSpeed / 3600.0
                    speedZone.obcNow = new Date()
                }
            }

            ChromeWell { anchors.centerIn: parent; dialSize: speedZone.dialDiam }

            Canvas {
                id: speedCanvas
                anchors.centerIn: parent
                width: speedZone.dialDiam; height: speedZone.dialDiam
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var cx = width * 0.5, cy = height * 0.5
                    var r  = width * 0.42
                    var startRad = 150.0 * Math.PI / 180.0
                    var totalRad = 240.0 * Math.PI / 180.0

                    var stepCount = 200

                    // Шаг i += 10 убирает мелкую нарезку. Остаются только цифры (0, 20, 40...) и половинки (10, 30, 50...)
                    for (var i = 0; i <= stepCount; i += 10) {
                        var frac  = i / parseFloat(stepCount)
                        var angle = startRad + frac * totalRad

                        var major = (i % 20 === 0) // Крупная риска на цифре (0, 20, 40...)
                        var semi  = (i % 10 === 0) && !major // Промежуточная риска между цифрами (10, 30, 50...)

                        // Пропорциональные размеры рисок-галочек
                        var tlen = major ? 28 : 18
                        var baseWidth = major ? 18.0 : 10.0

                        var perpAngle = angle + Math.PI * 0.5

                        // Вычисляем координаты трех точек для разомкнутой V-стрелочки
                        var tipX = cx + Math.cos(angle) * (r - tlen)
                        var tipY = cy + Math.sin(angle) * (r - tlen)

                        var baseLeftX = cx + Math.cos(angle) * (r + 1) - Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseLeftY = cy + Math.sin(angle) * (r + 1) - Math.sin(perpAngle) * (baseWidth * 0.5)

                        var baseRightX = cx + Math.cos(angle) * (r + 1) + Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseRightY = cy + Math.sin(angle) * (r + 1) + Math.sin(perpAngle) * (baseWidth * 0.5)

                        // 1. ОТРИСОВКА ОТКРЫТОЙ V-ОБРАЗНОЙ СТРЕЛКИ (без основания)
                        ctx.beginPath()
                        ctx.moveTo(baseLeftX, baseLeftY)   // Начинаем с левого «ушка» на линии шкалы
                        ctx.lineTo(tipX, tipY)             // Ведем линию к кончику (внутрь)
                        ctx.lineTo(baseRightX, baseRightY) // Ведем линию к правому «ушка» на линии шкалы
                        // ctx.closePath() убран, чтобы дно треугольника не рисовалось

                        ctx.strokeStyle = "#d8d8d8"
                        ctx.lineWidth = major ? 2.0 : 1.2
                        ctx.stroke()

                        // 2. ОТРИСОВКА ПРЕРЫВИСТОЙ ЛИНИИ ШКАЛЫ (кусочками до следующей риски)
                        if (i < stepCount) {
                            var nextI = i + 10
                            var nextFraction = nextI / parseFloat(stepCount)

                            // Минимальный зазор в 1 пиксель, чтобы линия подходила ровно встык к краям V-галочек
                            var currentGap = (baseWidth * 0.5 + 1.0) / r

                            var nextMajor = (nextI % 20 === 0)
                            var nextBaseWidth = nextMajor ? 18.0 : 10.0
                            var nextGap = (nextBaseWidth * 0.5 + 1.0) / r

                            var arcStartAngle = angle + currentGap
                            var arcEndAngle = (startRad + nextFraction * totalRad) - nextGap

                            if (arcStartAngle < arcEndAngle) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r + 1, arcStartAngle, arcEndAngle, false)
                                ctx.strokeStyle = "#f0f0f0"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        // 3. ВЫВОД ЦИФР ШКАЛЫ СКОРОСТИ
                        if (major) {
                            // Изменили отступ lr (было r + 17 -> стало r + 32),
                            // так как риски стали длиннее и шире, чтобы шрифт не накладывался на них
                            var lr = r + 32

                            ctx.save()
                            ctx.translate(cx + Math.cos(angle) * lr, cy + Math.sin(angle) * lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#dcdce8"
                            ctx.font = "bold 25px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(i, 0, 0)
                            ctx.restore()
                        }
                    }
                }
                Component.onCompleted: requestPaint()
            }

            // =========================================================================
            // ЗОНА ИКОНОК ПРЕДУПРЕЖДЕНИЙ В ВЕРХНЕЙ ЧАСТИ СПИДОМЕТРА
            // =========================================================================
            Item {
                id: speedIcons
                anchors.centerIn: parent
                width: speedZone.dialDiam
                height: speedZone.dialDiam

                // Адаптивный размер иконок (10% от диаметра прибора)
                property real iconSize: speedZone.dialDiam * 0.10

                // РАДИУС ИЗМЕНЕН: Увеличили с 0.42 до 0.58, чтобы поднять иконки выше от центра к цифрам
                property real arcRadius: speedZone.dialRad * 0.58

                // Вспомогательные тригонометрические функции для размещения по углам
                function posX(angleDeg) {
                    return (width / 2) + Math.cos(angleDeg * Math.PI / 180) * arcRadius - (iconSize / 2)
                }
                function posY(angleDeg) {
                    return (height / 2) + Math.sin(angleDeg * Math.PI / 180) * arcRadius - (iconSize / 2)
                }

                // 1. Иконка открытого капота (Крайняя слева)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/hood_open.svg"
                    width: speedIcons.iconSize
                    height: speedIcons.iconSize * 0.8
                    fillMode: Image.PreserveAspectFit
                    x: speedIcons.posX(-140) // Раздвинули сильнее влево (в район цифры 60)
                    y: speedIcons.posY(-140)
                    visible: speedZone.useExternalData ? CanReceiver.hoodWarning : true
                }

                // 2. Иконка открытых дверей (Левее центра)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/door_open.svg"
                    width: speedIcons.iconSize
                    height: speedIcons.iconSize * 1.0
                    fillMode: Image.PreserveAspectFit
                    x: speedIcons.posX(-115) // Встает под цифру 80-100
                    y: speedIcons.posY(-115)
                    visible: speedZone.useExternalData ? CanReceiver.driverDoor : true
                }

                // 3. Иконка аварийки / общего предупреждения (СТРОГО ПО СЕРЕДИНЕ)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/master_warning.svg"
                    width: speedIcons.iconSize
                    height: speedIcons.iconSize * 0.85
                    fillMode: Image.PreserveAspectFit
                    x: speedIcons.posX(-90) // Строго по центру вверху (под цифрой 100)
                    y: speedIcons.posY(-90)
                    visible: speedZone.useExternalData
                            ? (CanReceiver.driverDoor || CanReceiver.hoodWarning || CanReceiver.trunkWarning)
                            : true
                }

                // 4. Иконка открытого багажника (Правее центра)
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/trunk_open.svg"
                    width: speedIcons.iconSize
                    height: speedIcons.iconSize * 0.8
                    fillMode: Image.PreserveAspectFit
                    x: speedIcons.posX(-65) // Сдвинули правее (под цифру 120)
                    y: speedIcons.posY(-65)
                    visible: speedZone.useExternalData ? CanReceiver.trunkWarning : true
                }
            }

            // Стрелка спидометра
            Item {
                id: needleContainer
                anchors.centerIn: parent
                width: speedZone.dialDiam; height: speedZone.dialDiam
                rotation: speedZone.needleAngle
                transformOrigin: Item.Center
                Behavior on rotation { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

                // Контейнер для векторной графики
                Shape {
                    id: needleShape
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 50
                    height: speedZone.dialRad * 0.70 // Слегка увеличили высоту, так как полая стрелка визуально должна быть длиннее

                    // Позиционируем основание стрелки точно в центр вращения
                    y: speedZone.dialRad - height

                    layer.enabled: true
                    layer.samples: 4 // Сглаживание краев контура (антиалиасинг)

                    ShapePath {
                        // Белый цвет контура и прозрачность внутри
                        strokeColor: "#ffffff"
                        strokeWidth: 2.5 // Толщина белой линии стрелки
                        fillColor: "#0c0c0e"
                        joinStyle: ShapePath.RoundJoin // Скругленные аккуратные углы

                        // Начинаем рисовать с кончика стрелки (сверху по центру)
                        startX: needleShape.width / 2
                        startY: 0

                        // Линия к правому нижнему углу основания
                        PathLine { x: needleShape.width; y: needleShape.height }

                        // Линия к левому нижнему углу основания
                        PathLine { x: 0; y: needleShape.height }

                        // Замыкаем треугольник обратно на кончик
                        PathLine { x: needleShape.width / 2; y: 0 }
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

            // Поворотники — над информационным окном, между ступицей и OBC.
            // Размер и позиция считаются от dialDiam, чтобы масштабировались с окном.
            Row {
                id: turnSignalsRow
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: speedZone.dialRad * 0.50
                }
                spacing: speedZone.dialDiam * 0.30

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/turn_left.svg"
                    width: speedZone.dialDiam * 0.23; height: width
                    fillMode: Image.PreserveAspectFit
                    opacity: CanReceiver.turnLeft ? 1.0 : 0.05
                    Behavior on opacity { NumberAnimation { duration: 30 } }
                }
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/turn_right.svg"
                    width: speedZone.dialDiam * 0.23; height: width
                    fillMode: Image.PreserveAspectFit
                    opacity: CanReceiver.turnRight ? 1.0 : 0.05
                    Behavior on opacity { NumberAnimation { duration: 30 } }
                }
            }

            // Компоновка: верхняя строка [GEAR | ODO | VOLT] + нижняя строка [часы]
            Item {
                id: obcDisplay
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    // Смещение вниз в долях от dialRad — с запасом ниже уровня,
                    // на котором заканчивается шкала (см. правку шкалы выше),
                    // чтобы между дугой и полем оставался зазор.
                    verticalCenterOffset: speedZone.dialRad * 0.77
                }
                width:  speedZone.dialDiam * 0.53
                height: speedZone.dialDiam * 0.19


                // ── ВЕРХНЯЯ СТРОКА: GEAR | ODO | VOLT (без подписей) ─────────
                Item {
                    height: parent.height * 0.58
                    anchors { left: parent.left; right: parent.right
                              top: parent.top; topMargin: parent.height * 0.06 }

                    // GEAR
                    Item {
                        id: gearCell
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: parent.width * 0.26

                        Text {
                            anchors.centerIn: parent
                            text: {
                               var currentGear = speedZone.useExternalData ? CanReceiver.gear : carController.gear
                               var currentSpeed = speedZone.useExternalData ? CanReceiver.speed : carController.speed
                               var isThrottling = speedZone.useExternalData ? false : carController.throttle // на ESP32 педаль определяет сама машина

                               if (currentGear && currentGear !== "" && currentGear !== "0" && currentGear !== 0) return currentGear
                               if (isThrottling || currentSpeed > 0) return "D"
                               return "P"
                            }
                            color: {
                               var currentGear = speedZone.useExternalData ? CanReceiver.gear : carController.gear
                               var currentSpeed = speedZone.useExternalData ? CanReceiver.speed : carController.speed
                               var isThrottling = speedZone.useExternalData ? false : carController.throttle

                               var displayGear = (currentGear && currentGear !== "" && currentGear !== "0" && currentGear !== 0) ? currentGear
                                   : (isThrottling || currentSpeed > 0 ? "D" : "P")
                               if (displayGear === "P") return "#808090"
                               if (displayGear === "R") return "#ff6644"
                               return "#00d0ea"
                            }
                            font { pixelSize: speedZone.dialDiam * 0.050; bold: true; family: eurostileFont.name }
                        }
                    }

                    // ODO (пробег)
                    Item {
                        id: odoCell
                        anchors { left: gearCell.right
                                  top: parent.top; bottom: parent.bottom }
                        width: parent.width * 0.37

                        Row {
                            anchors.centerIn: parent; spacing: 3
                            Text {
                                text: speedZone.useExternalData
                                    ? Math.round(CanReceiver.odometer)
                                    : "4"
                                color: "#b8b8c8"
                                font { pixelSize: speedZone.dialDiam * 0.027; family: eurostileFont.name }
                            }
                            Text {
                                text: "km"
                                color: "#404050"
                                font { pixelSize: speedZone.dialDiam * 0.016; family: eurostileFont.name }
                                anchors.baseline: parent.children[0].baseline
                            }
                        }
                    }

                    // VOLT (напряжение)
                    Item {
                        anchors { left: odoCell.right
                                  right: parent.right
                                  top: parent.top; bottom: parent.bottom }

                        Row {
                            anchors.centerIn: parent; spacing: 3
                            Text {
                                text: "13.6"
                                color: "#b8b8c8"
                                font { pixelSize: speedZone.dialDiam * 0.027; family: eurostileFont.name }
                            }
                            Text {
                                text: "V"
                                color: "#404050"
                                font { pixelSize: speedZone.dialDiam * 0.016; family: eurostileFont.name }
                                anchors.baseline: parent.children[0].baseline
                            }
                        }
                    }
                }

                // ── НИЖНЯЯ СТРОКА: цифровые часы ─────────────────────────────
                Item {
                    anchors { left: parent.left; right: parent.right
                              bottom: parent.bottom; top: parent.top; topMargin: parent.height * 0.60 }

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        text: {
                            switch (speedZone.obcPage) {
                                case 1:  return speedZone.obcInstL100.toFixed(1) + " л/100"
                                case 2:  return speedZone.obcAvgL100.toFixed(1)  + " л/100"
                                case 3:  return Math.round(speedZone.obcRangeKm) + " км"
                                default: return Qt.formatDateTime(speedZone.obcNow, "hh:mm")
                            }
                        }
                        color: "#c8c8d8"
                        font { pixelSize: speedZone.dialDiam * 0.041; bold: true; family: eurostileFont.name }
                    }
                }
            }
        }

        Item {
            id: rightZone
            x: gaugesArea.width * 0.5 + speedZone.dialDiam * 0.5 - rightZone.dialDiam * 0.25
            y: 0
            width: gaugesArea.width * 0.35
            height: gaugesArea.height
            z: 0

            //property real dialDiam: Math.min(width, height) * 0.94
            property real dialDiam: Math.min(width, height) * 0.94
            property real dialRad:  dialDiam * 0.5
            property real scaleOffset: 20.0

            // ── значения физики ───────────────────────────────────────────
            // Автоматически синхронизируем режим с общим флагом тахометра
            property bool useExternalData: tachZone.useExternalData

            // Температура охлаждающей жидкости 50..130°C
            // Если от ESP32 — берем из сети, иначе — константа 90.0 (или ваше старое свойство)
            property real tempVal:
                useExternalData
                ? Number(CanReceiver.coolant || 90)
                : 90.0

            property real tempFraction: Math.max(
                0,
                Math.min(
                    (tempVal - 50.0) / 80.0,
                    1.0
                )
            )

            property real tempNeedle: -40 + tempFraction * 105
            Behavior on tempNeedle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            // Уровень топлива 0..1
            // ВАЖНО: делим CanReceiver.fuel на 100.0, так как прошивка шлет проценты (0..100)
            property real fuelVal:
                useExternalData
                ? Math.max(0, Math.min(Number(CanReceiver.fuel || 0), 100)) / 100.0
                : 0.65



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
                    var r  = width * 0.40   // оригинальный радиус шкалы
                    var PI = Math.PI
                    var toRad = PI / 180.0

                    // Математика углов температуры
                    var tCSSstart = (210.0 + rightZone.scaleOffset) * toRad
                    var tSweep    = 80.0 * toRad
                    var tTicks    = 9 // 0..9 шагов (каждые 3 шага — крупная риска на цифре)

                    // 1. ─── ШКАЛА ТЕМПЕРАТУРЫ (Отрисовка V-рисок и прерывистых дуг) ───
                    for (var i = 0; i <= tTicks; i++) {
                        var frac  = i / parseFloat(tTicks)
                        var angle = tCSSstart + frac * tSweep

                        var major = (i === 0 || i === 3 || i === 6 || i === 9)
                        var tlen  = major ? 24 : 14 // Пропорционально масштабу правого блока шкал
                        var baseWidth = major ? 15.0 : 8.0

                        var isHot = (frac >= 0.80)
                        var perpAngle = angle + Math.PI * 0.5

                        // Координаты точек для открытой V-образной стрелочки температуры
                        var tipX = cx + Math.cos(angle) * (r - 3 - tlen)
                        var tipY = cy + Math.sin(angle) * (r - 3 - tlen)

                        var baseLeftX = cx + Math.cos(angle) * (r - 3 + 1) - Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseLeftY = cy + Math.sin(angle) * (r - 3 + 1) - Math.sin(perpAngle) * (baseWidth * 0.5)

                        var baseRightX = cx + Math.cos(angle) * (r - 3 + 1) + Math.cos(perpAngle) * (baseWidth * 0.5)
                        var baseRightY = cy + Math.sin(angle) * (r - 3 + 1) + Math.sin(perpAngle) * (baseWidth * 0.5)

                        ctx.beginPath()
                        ctx.moveTo(baseLeftX, baseLeftY)
                        ctx.lineTo(tipX, tipY)
                        ctx.lineTo(baseRightX, baseRightY)

                        ctx.strokeStyle = isHot ? "#ff3030" : "#d8d8d8"
                        ctx.lineWidth = major ? 1.8 : 1.1
                        ctx.stroke()

                        // Прерывистая белая/красная дуга шкалы температуры
                        if (i < tTicks) {
                            var nextI = i + 1
                            var nextFraction = nextI / parseFloat(tTicks)

                            var currentGap = (baseWidth * 0.5 + 1.0) / (r - 3)
                            var nextMajor = (nextI === 0 || nextI === 3 || nextI === 6 || nextI === 9)
                            var nextBaseWidth = nextMajor ? 15.0 : 8.0
                            var nextGap = (nextBaseWidth * 0.5 + 1.0) / (r - 3)

                            var arcStartAngle = angle + currentGap
                            var arcEndAngle = (tCSSstart + nextFraction * tSweep) - nextGap

                            if (arcStartAngle < arcEndAngle) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r - 3, arcStartAngle, arcEndAngle, false)
                                // Если следующий шаг или текущий в горячей зоне — красим дугу в красный
                                ctx.strokeStyle = (frac >= 0.80) ? "#ff3030" : "#f0f0f0"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        // Вывод цифр температуры (30, 50, 90, 130)
                        if (major) {
                            var labels = ["30", "50", "90", "130"]
                            var li = i / 3
                            var lr = r + 26 // Отодвинули, чтобы более широкие риски не накладывались на шрифт

                            ctx.save()
                            ctx.translate(cx + Math.cos(angle) * lr, cy + Math.sin(angle) * lr)
                            ctx.rotate(angle + Math.PI * 0.5)
                            ctx.fillStyle = "#d8d8d8"
                            ctx.font = "bold 23px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(labels[li], 0, 0)
                            ctx.restore()
                        }
                    }

                    // 2. ─── СОЕДИНИТЕЛЬНЫЙ МОСТ (Правая дуга между шкалами) ───
                    var bridgeStart = tCSSstart + tSweep;
                    var bridgeEnd   = (30.0 - rightZone.scaleOffset + 40) * toRad; // Начало шкалы топлива

                    ctx.beginPath()
                    // Уменьшили радиус дуги с r - 20 до r - 28, чтобы увести её глубже внутрь к кончикам
                    ctx.arc(cx, cy, r - 28, bridgeStart, bridgeEnd, false)
                    ctx.strokeStyle = "#f0f0f0"
                    ctx.lineWidth = 2
                    ctx.stroke()


                    // Математика углов топлива
                    var fCSSstart = bridgeEnd
                    var fSweep    = 80.0 * toRad
                    var fTicks    = 4 // 0..4 шагов (наша оригинальная нарезка без мелкого забора)

                    // 3. ─── ШКАЛА ТОПЛИВА (Отрисовка V-рисок и прерывистых дуг) ───
                    for (var j = 0; j <= fTicks; j++) {
                        var ff     = j / parseFloat(fTicks)
                        var fa     = fCSSstart + ff * fSweep

                        var fmaj   = (j === 0 || j === 2 || j === 4)
                        var flen2  = fmaj ? 24 : 14
                        var fWidth = fmaj ? 15.0 : 8.0

                        var isLow  = (ff >= 0.75)
                        var fPerp  = fa + Math.PI * 0.5

                        // Координаты точек для открытой V-образной стрелочки топлива
                        var fTipX = cx + Math.cos(fa) * (r - 3 - flen2)
                        var fTipY = cy + Math.sin(fa) * (r - 3 - flen2)

                        var fBaseLeftX = cx + Math.cos(fa) * (r - 3 + 1) - Math.cos(fPerp) * (fWidth * 0.5)
                        var fBaseLeftY = cy + Math.sin(fa) * (r - 3 + 1) - Math.sin(fPerp) * (fWidth * 0.5)

                        var fBaseRightX = cx + Math.cos(fa) * (r - 3 + 1) + Math.cos(fPerp) * (fWidth * 0.5)
                        var fBaseRightY = cy + Math.sin(fa) * (r - 3 + 1) + Math.sin(fPerp) * (fWidth * 0.5)

                        ctx.beginPath()
                        ctx.moveTo(fBaseLeftX, fBaseLeftY)
                        ctx.lineTo(fTipX, fTipY)
                        ctx.lineTo(fBaseRightX, fBaseRightY)

                        ctx.strokeStyle = isLow ? "#ff3030" : "#d8d8d8"
                        ctx.lineWidth = fmaj ? 1.8 : 1.1
                        ctx.stroke()

                        // Прерывистая белая/красная дуга шкалы топлива
                        if (j < fTicks) {
                            var nextJ = j + 1
                            var nextFFraction = nextJ / parseFloat(fTicks)

                            var fCurrentGap = (fWidth * 0.5 + 1.0) / (r - 3)
                            var nextFMajor = (nextJ === 0 || nextJ === 2 || nextJ === 4)
                            var nextFWidth = nextFMajor ? 15.0 : 8.0
                            var fNextGap = (nextFWidth * 0.5 + 1.0) / (r - 3)

                            var fArcStartAngle = fa + fCurrentGap
                            var fArcEndAngle = (fCSSstart + nextFFraction * fSweep) - fNextGap

                            if (fArcStartAngle < fArcEndAngle) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r - 3, fArcStartAngle, fArcEndAngle, false)
                                ctx.strokeStyle = (ff >= 0.75) ? "#ff3030" : "#f0f0f0"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        // Вывод подписей уровня топлива (1, 0.5, 0)
                        if (fmaj) {
                            var fLabels = ["1", "0.5", "0"]
                            var fli = j / 2
                            var flr = r + 26

                            ctx.save()
                            ctx.translate(cx + Math.cos(fa) * flr, cy + Math.sin(fa) * flr)
                            ctx.rotate(fa - Math.PI * 0.5)
                            ctx.fillStyle = "#d8d8d8"
                            ctx.font = "bold 23px '" + eurostileFont.name + "'"
                            ctx.textAlign = "center"; ctx.textBaseline = "middle"
                            ctx.fillText(fLabels[fli], 0, 0)
                            ctx.restore()
                        }
                    }
                }

                Component.onCompleted: requestPaint()
            }


            // ── Стрелка ТЕМПЕРАТУРЫ ───────────────────────────────────────
            // fraction=0(50°C) → Qt rotation=-60°; fraction=1(130°C) → Qt rotation=+60°
            // tempNeedle = -60 + fraction*120 ✓
            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.tempNeedle
                transformOrigin: Item.Center

                Shape {
                    id: tempNeedleShape
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 50
                    height: rightZone.dialRad * 0.65 // Оптимальная длина вылета из-под диска
                    y: rightZone.dialRad - height   // Позиционирование от центра вверх

                    layer.enabled: true
                    layer.samples: 4 // Сглаживание краев при вращении

                    ShapePath {
                        strokeColor: "#ffffff"
                        strokeWidth: 2.5 // Толщина белой границы
                        fillColor: "#0c0c0e"
                        joinStyle: ShapePath.RoundJoin

                        // Начинаем с кончика (сверху по центру)
                        startX: tempNeedleShape.width / 2
                        startY: 0

                        // Рисуем линии по контуру треугольника
                        PathLine { x: tempNeedleShape.width; y: tempNeedleShape.height }
                        PathLine { x: 0; y: tempNeedleShape.height }
                        PathLine { x: tempNeedleShape.width / 2; y: 0 }
                    }
                }
            }

            // ── Стрелка ТОПЛИВА ───────────────────────────────────────────
            // Full (fuelVal=1) -> canvas 50° -> rotation 140°
            // Empty (fuelVal=0) -> canvas 130° -> rotation 220°
            property real fuelNeedleCorrect: 220.0 - fuelVal * 80.0
            Behavior on fuelNeedleCorrect { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

            Item {
                anchors.centerIn: parent
                width: rightZone.dialDiam; height: rightZone.dialDiam
                rotation: rightZone.fuelNeedleCorrect
                transformOrigin: Item.Center

                Shape {
                    id: fuelNeedleShape
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 50
                    height: rightZone.dialRad * 0.65 // Такой же вылет из-под центрального диска
                    y: rightZone.dialRad - height   // Рисуется вверх, углы вращения QML сами развернут её вниз

                    layer.enabled: true
                    layer.samples: 4 // Сглаживание пикселей

                    ShapePath {
                        strokeColor: "#ffffff"
                        strokeWidth: 2.5 // Толщина белой границы
                        fillColor: "#0c0c0e"
                        joinStyle: ShapePath.RoundJoin

                        // Кончик треугольника сверху по центру
                        startX: fuelNeedleShape.width / 2
                        startY: 0

                        // Контур полой стрелки
                        PathLine { x: fuelNeedleShape.width; y: fuelNeedleShape.height }
                        PathLine { x: 0; y: fuelNeedleShape.height }
                        PathLine { x: fuelNeedleShape.width / 2; y: 0 }
                    }
                }
            }


            // Центральный колпак поверх диска и хвостов стрелок
            NeedleCap {
                id: needleCap
                anchors.centerIn: parent
                capSize: 120

                // Задаем контейнеру тот же размер, что и у колпака, чтобы anchors внутри него работали корректно
                width: capSize
                height: capSize

                Item {
                    id: central_Icons
                    anchors.fill: parent // Растягиваем зону под иконки на весь размер колпака

                    // Верхняя иконка (Температура)
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 12

                        source: "qrc:/qt/qml/dashboard/icons/coolant_temp.svg"
                        width: 40
                        height: width
                        fillMode: Image.PreserveAspectFit
                    }

                    // Нижняя иконка (Топливо) — ДОБАВЛЕНА СНИЗУ
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12 // Отступ от нижнего края колпака

                        source: "qrc:/qt/qml/dashboard/icons/fuel.svg"
                        width: 40
                        height: width
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }


            Item {
                id: temp_fuelIcons

                width: rightZone.dialDiam
                height: rightZone.dialDiam
                anchors.centerIn: parent

                // Вернули свет ОБРАТНО НАРУЖУ (радиус орбиты снова 1.15)
                property real lightRadius: rightZone.dialRad * 1.15
                property real carRadius: rightZone.dialRad * 0.65

                property int lightIconSize: 48
                property int carIconSize: 55

                // =========================================================================
                // 1. ИКОНКИ СВЕТА СНАРУЖИ (Снова справа, идеальной дугой вдоль круга)
                // =========================================================================
                Repeater {
                    model: [
                        { src: "side_lamps.svg", angle: -24, prop: "position" },
                        { src: "low_beam.svg",   angle: -12, prop: "lowBeam" },
                        { src: "high_beam.svg",  angle: 0,   prop: "highBeam" },
                        { src: "fog_front.svg",  angle: 12,  prop: "fogFront" },
                        { src: "fog_rear.svg",   angle: 24,  prop: "fogRear" }
                    ]

                    Image {
                        source: "qrc:/qt/qml/dashboard/icons/" + modelData.src
                        width: temp_fuelIcons.lightIconSize
                        height: width
                        fillMode: Image.PreserveAspectFit

                        x: (temp_fuelIcons.width / 2) + Math.cos(modelData.angle * Math.PI / 180) * temp_fuelIcons.lightRadius - width / 2 - 100
                        y: (temp_fuelIcons.height / 2) + Math.sin(modelData.angle * Math.PI / 180) * temp_fuelIcons.lightRadius - height / 2

                        visible: modelData.prop !== ""
                                 ? CanReceiver[modelData.prop]
                                 : false
                    }
                }

                Image {
                    id: escIcon
                    source: "qrc:/qt/qml/dashboard/icons/esc_off.svg"
                    width: temp_fuelIcons.carIconSize
                    height: width
                    fillMode: Image.PreserveAspectFit

                    property real angleY: 30
                    property real angleX: 50

                    x: (temp_fuelIcons.width / 2)
                       + Math.cos(angleX * Math.PI / 180) * temp_fuelIcons.carRadius
                       - width / 2
                    y: (temp_fuelIcons.height / 2)
                       + Math.sin(angleY * Math.PI / 180) * temp_fuelIcons.carRadius
                       - height / 2

                    visible: rightZone.useExternalData ? CanReceiver.escWarning : rightZone.lightWarning
                }

                Image {
                    id: espIcon
                    source: "qrc:/qt/qml/dashboard/icons/esp_off.svg"
                    width: temp_fuelIcons.carIconSize
                    height: width
                    fillMode: Image.PreserveAspectFit

                    property real angleY: 10
                    property real angleX: 40

                    x: (temp_fuelIcons.width / 2)
                       + Math.cos(angleX * Math.PI / 180) * temp_fuelIcons.carRadius
                       - width / 2
                    y: (temp_fuelIcons.height / 2)
                       + Math.sin(angleY * Math.PI / 180) * temp_fuelIcons.carRadius
                       - height / 2

                    visible: rightZone.useExternalData ? CanReceiver.espOff : rightZone.lightWarning
                }

                Image {
                    source: "qrc:/qt/qml/dashboard/icons/coolant_overheat.svg"
                    width: temp_fuelIcons.carIconSize
                    height: width
                    fillMode: Image.PreserveAspectFit

                    // Настройки положения: угол 330 градусов (верхний правый сектор)
                    property real angleDeg: 330
                    property real radiusFrac: 0.58 // Равномерный отступ от центра, как у топлива

                    x: (temp_fuelIcons.width / 2) + Math.cos(angleDeg * Math.PI / 180) * (rightZone.dialRad * radiusFrac) - width / 2
                    y: (temp_fuelIcons.height / 2) + Math.sin(angleDeg * Math.PI / 180) * (rightZone.dialRad * radiusFrac) - height / 2

                    visible: rightZone.useExternalData ? CanReceiver.coolantOverheat : false
                }


                // =========================================================================
                // 3. КРИТИЧЕСКИЙ УРОВЕНЬ ТОПЛИВА (На своем законном месте)
                // =========================================================================
                Image {
                    source: "qrc:/qt/qml/dashboard/icons/fuel_low.svg"
                    width: 50
                    height: width
                    fillMode: Image.PreserveAspectFit

                    property real angleDeg: 150
                    property real radiusFrac: 0.58

                    x: (temp_fuelIcons.width / 2)
                       + Math.cos(angleDeg * Math.PI / 180) * (rightZone.dialRad * radiusFrac)
                       - width / 2
                    y: (temp_fuelIcons.height / 2)
                       + Math.sin(angleDeg * Math.PI / 180) * (rightZone.dialRad * radiusFrac)
                       - height / 2

                    visible: rightZone.useExternalData
                        ? CanReceiver.fuelLowWarning
                        : rightZone.lightWarning
                }
            }

        }
    }
}
