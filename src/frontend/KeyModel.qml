import QtQuick

QtObject {
    property int keyIdx
    property int pitchIdx
    property int keyType
    property rect rect

    function isWhiteKey() {
        return keyType === Keyboard.KeyType.White
    }

}
