import QtQuick
import QtQuick.Window
import "key_conversions.js" as KeyConversions

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    Text {
        id: pressedNoteText
        anchors {
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        font.pixelSize: 60
        color: 'black'
    }

    Keyboard {
        id: keyboard
        anchors.centerIn: parent
        onPressedKeysChanged: {
            console.log('onPressedKeysChanged')
            var numKeys = pressedKeys.length
            console.log('num keys', numKeys)
            var text = ''
            if (numKeys === 1) {
                text = KeyConversions.keyIdxToNoteName(pressedKeys[0].keyIdx)
            }
            else if (numKeys > 1) {
                text = 'TODO - more than one pressed'
            }
            pressedNoteText.text = text
        }
    }
}
