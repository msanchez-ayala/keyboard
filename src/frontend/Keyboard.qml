import QtQuick
import "key_conversions.js" as KeyConversions
// BUGS
// 1. Ignore mouse while any computer keys are pressed
// 2. Polyphonic painting isn't happening. Multiple key presses are registered tho
// 3. Fix centering in parent widget
//
// NEW FEATURES
//
//

Item {
    id: keyboard
    height: 250
    width: height * 2.3
    focus: true

    property real whiteWidth: 55
    property real whiteHeight: keyboard.height

    property real blackWidth: (9/13) * whiteWidth
    property real blackHeight: (6/10) * whiteHeight
    property real blackKeyOffset: (blackWidth / 2)
    property int numKeysWhite: Math.floor(keyboard.width / whiteWidth)
    property int numKeysTotal: Math.floor(11/7 * numKeysWhite)

    property var keys: []
    property var pressedKeys: []  // Length in [0, 1]
    property var hoveredKeys: []  // Length in [0, 1]

    onXChanged: updatekeys()
    onYChanged: updatekeys()
    onWidthChanged: updatekeys()
//    onHoveredKeysChanged: {
//        if (hoveredKeys.length === 0) {
//            console.log('No hovered keys')
//        }
//        else {
//            var key = hoveredKeys[0]
//            console.log('Hovered key idx:', key.keyIdx, 'pitch idx:', key.pitchIdx)
//        }
//    }
//    onPressedKeysChanged: {
//        if (pressedKeys.length === 0) {
//            console.log('No pressed keys')
//        }
//        else {
//            var key = pressedKeys[0]
//            console.log('Pressed key idx:', key.keyIdx, 'pitch idx:', key.pitchIdx)
//        }
//    }

    Keys.onPressed: (event) => updateKeyoardKeysPressed(event)
    Keys.onReleased: (event) => updateKeyboardKeysReleased(event)

    enum KeyType {
        White,
        Black
    }

    function updatekeys() {
        keys = []
        // Must be nonzero so that we can have infinite number of keys
        var curX = -blackKeyOffset
        for (var idx = 0; idx < numKeysTotal; ++idx) {
            const pitchIdx = idx % 12
            switch (pitchIdx) {
            case 0:
                curX += blackKeyOffset
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 1:
                curX += (whiteWidth - blackKeyOffset)
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.Black)
                break
            case 2:
                curX += blackKeyOffset
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 3:
                curX += whiteWidth
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 4:
                curX += (whiteWidth - blackKeyOffset)
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.Black)
                break
            case 5:
                curX += blackKeyOffset
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 6:
                curX += (whiteWidth - blackKeyOffset)
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.Black)
                break
            case 7:
                curX += blackKeyOffset
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 8:
                curX += whiteWidth
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 9:
                curX += (whiteWidth - blackKeyOffset)
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.Black)
                break
            case 10:
                curX += blackKeyOffset
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.White)
                break
            case 11:
                curX += (whiteWidth - blackKeyOffset)
                pushNewKey(curX, idx, pitchIdx, Keyboard.KeyType.Black)
                break
            }
        }
    }

    function pushNewKey(curX, keyIdx, pitchIdx, keyType) {
        var width = keyType === Keyboard.KeyType.White ? whiteWidth : blackWidth
        var height = keyType === Keyboard.KeyType.White ? whiteHeight : blackHeight
        var component = Qt.createComponent('KeyModel.qml')
        if (component.status === Component.Ready) {
            var keyModel = component.createObject(keyboard)
            keyModel.keyIdx = keyIdx
            keyModel.pitchIdx = pitchIdx
            keyModel.rect = Qt.rect(curX, 0, width, height)
            keyModel.keyType= keyType
        }
        else {
            throw "Key model could not be created"
        }
        keys.push(keyModel)
    }

    function updateKeyoardKeysPressed(event) {
        var keyIdx = KeyConversions.computerKeyToKeyIndex(event.key)
        if (keyIdx === null) {
            return
        }
        else if (keyIdx >= keys.length) {
            return
        }
        var keyIsPressed = false
        pressedKeys.forEach(function(key) {
            if (keyIdx === key.keyIdx) {
                keyIsPressed = true
            }
        })
        if (keyIsPressed) {
            return
        }

        pressedKeys.push(keys[keyIdx])
        pressedKeysChanged()
        canvas.requestPaint()
    }

    function updateKeyboardKeysReleased(event) {
        var keyIdx = KeyConversions.computerKeyToKeyIndex(event.key)
        if (keyIdx === null) {
            return
        }
        else if (keyIdx >= keys.length) {
            return
        }
        var keyIsPressed = false
        pressedKeys.forEach(function(key) {
            if (keyIdx === key.keyIdx) {
                keyIsPressed = true
            }
        })
        if (!keyIsPressed) {
            return
        }

        removePressedKey(keyIdx)
        pressedKeysChanged()
        canvas.requestPaint()
    }

    function removePressedKey(keyIdx) {
        pressedKeys.forEach(function(key, idx) {
            if (key.keyIdx === keyIdx) {
                pressedKeys.splice(idx, 1)
            }
        })
    }




    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = canvas.getContext('2d')
            ctx.strokeStyle = '#000000'
            ctx.lineWidth = 1

            ctx.beginPath()
            keyboard.keys.forEach(function(key) {
                if (key.isWhiteKey()) {drawKey(ctx, key) }
            })
            ctx.stroke()
            ctx.closePath()

            // Draw black keys second so that they appear on top of white keys
            ctx.beginPath()
            keyboard.keys.forEach(function(key) {
                if (!key.isWhiteKey()) { drawKey(ctx, key) }
            })
            ctx.stroke()
            ctx.closePath()

        }

        function drawKey(ctx, key) {
            var curX = key.rect.x
            var keyType = key.keyType
            var width = key.rect.width
            var height = key.rect.height
            ctx.fillStyle = getFillStyle(key)
            ctx.fillRect(curX, 0, width, height)
            ctx.rect(curX, 0, width, height)
        }

        function getFillStyle(key) {
            var pressed
            var hovered
            if (pressedKeys.length === 0)
                pressed = false
            else
                // TODO: This needs to be adjusted to allow any pressed or hovered key nOT just first
                pressed = pressedKeys[0].keyIdx === key.keyIdx
            if (hoveredKeys.length === 0)
                hovered = false
            else
                hovered = hoveredKeys[0].keyIdx === key.keyIdx
            var keyType = key.keyType
            if (pressed)
                return "#a7ccb7"
            else if (hovered)
                return "#ccffe2"
            else if (keyType == Keyboard.KeyType.White)
                return "#ffffff"
            else
                return "#000000"
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onMouseXChanged: updatePressedAndHoveredKeys()
            onMouseYChanged: updatePressedAndHoveredKeys()
            onPositionChanged: updatePressedAndHoveredKeys()
            onContainsMouseChanged: updatePressedAndHoveredKeys()

            onPressed: updatePressedKeys()
            onReleased: updatePressedKeys()

            function keyFromMousePos(mouseX, mouseY) {
                // <= 2 since can't have more than 1 white and black key overlap
                var potentialKeys = []
                keyboard.keys.forEach(function(key) {
                    var rect = key.rect
                    var xInRange = mouseX >= rect.x && mouseX <= rect.x + rect.width
                    var yInRange = mouseY >= rect.y && mouseY <= rect.y + rect.height
                    if (xInRange && yInRange) {
                        potentialKeys.push(key)
                    }
                })
                switch (potentialKeys.length) {
                case 1:
                    return potentialKeys[0]
                case 2:
                    var blackKey = null
                    potentialKeys.forEach(function(key) {
                        if (!key.isWhiteKey()) { blackKey = key }
                    })
                    return blackKey
                default:
                    return null
                }
            }

            function updatePressedAndHoveredKeys() {
                updatePressedKeys()
                updateHoveredKeys()
            }

            function updateHoveredKeys() {
                hoveredKeys = []
                if (containsMouse) {
                    var key = keyFromMousePos(mouseX, mouseY)
                    if (key !== null) {
                        hoveredKeys = [key]
                    }
                }
                canvas.requestPaint()
            }

            function updatePressedKeys() {
                pressedKeys = []
                var key = keyFromMousePos(mouseX, mouseY)
                if (key !== null && containsPress)
                    pressedKeys = [key]
                pressedKeysChanged()
                canvas.requestPaint()
            }
        }

    }
}
