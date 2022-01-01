function computerKeyToKeyIndex(name) {
    switch (name) {
    case Qt.Key_A:
        return 0
    case Qt.Key_W:
        return 1
    case Qt.Key_S:
        return 2
    case Qt.Key_D:
        return 3
    case Qt.Key_R:
        return 4
    case Qt.Key_F:
        return 5
    case Qt.Key_T:
        return 6
    case Qt.Key_G:
        return 7
    case Qt.Key_H:
        return 8
    case Qt.Key_U:
        return 9
    case Qt.Key_J:
        return 10
    case Qt.Key_I:
        return 11
    case Qt.Key_K:
        return 12
    case Qt.Key_O:
        return 13
    case Qt.Key_L:
        return 14
    case Qt.Key_Semicolon:
        return 15
    case Qt.Key_BracketLeft:
        return 16
    case Qt.Key_Comma:
        return 17
    case Qt.Key_BracketRight:
        return 18
    default:
        return null
    }
}

function keyIdxToNoteName(keyIdx) {
    switch (keyIdx % 12) {
    case 0:
        return 'A'
    case 1:
        return 'B♭ / A♯'
    case 2:
        return 'B'
    case 3:
        return 'C'
    case 4:
        return 'D♭ / C♯'
    case 5:
        return 'D'
    case 6:
        return 'E♭ / D♯'
    case 7:
        return 'E'
    case 8:
        return 'F'
    case 9:
        return 'G♭ / F♯'
    case 10:
        return 'G'
    case 11:
        return 'A♭ / G♯'
    default:
        throw 'ERROR'
    }
}
