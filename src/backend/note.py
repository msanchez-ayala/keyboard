"""
Fundamental definition of a note. There are 12 notes in western music, with each one having up to 4 enharmonics. We
denote the absolute value of each note as its pitch index - a value in [0, 11].
"""
from dataclasses import dataclass
from typing import NamedTuple


DOUBLE_FLAT_SIGN = '𝄫'
FLAT_SIGN = '♭'
NATURAL_SIGN = ''
SHARP_SIGN = '♯'
DOUBLE_SHARP_SIGN = '𝄪'
NATURAL_NOTE_NAMES = ('A', 'B', 'C', 'D', 'E', 'F', 'G')


class Accidental(NamedTuple):
    """
    Kinds of accidentals and how they modify a pitch index.
    """
    idx_offset: int
    sign: str


class Accidentals:
    DOUBLE_FLAT = Accidental(-2, DOUBLE_FLAT_SIGN)
    FLAT = Accidental(-1, FLAT_SIGN)
    NATURAL = Accidental(0, NATURAL_SIGN)
    SHARP = Accidental(1, SHARP_SIGN)
    DOUBLE_SHARP = Accidental(2, DOUBLE_SHARP_SIGN)


_PITCH_INDICES = tuple([idx for idx in range(12)])
_NATURAL_NOTE_INDICES = (0, 2, 3, 5, 7, 9, 10)
_NATURAL_NOTE_INDEX_MAP = dict(zip(NATURAL_NOTE_NAMES, _NATURAL_NOTE_INDICES))
_NATURAL_INDEX_NOTE_MAP = dict(zip(_NATURAL_NOTE_INDICES, NATURAL_NOTE_NAMES))

_SHARP_SIGNS = (SHARP_SIGN, DOUBLE_SHARP_SIGN)
_FLAT_SIGNS = (FLAT_SIGN, DOUBLE_FLAT_SIGN)
_ACCIDENTAL_SIGNS = (*_SHARP_SIGNS, *_FLAT_SIGNS)

_SIGN_ACCIDENTAL_MAP = {
    DOUBLE_FLAT_SIGN: Accidentals.DOUBLE_FLAT,
    FLAT_SIGN: Accidentals.FLAT,
    NATURAL_SIGN: Accidentals.NATURAL,
    SHARP_SIGN: Accidentals.SHARP,
    DOUBLE_SHARP_SIGN: Accidentals.DOUBLE_SHARP
}


def translate_pitch_idx(pitch_idx: int, idx_offset: int) -> int:
    pitch_idx = pitch_idx + idx_offset
    min_idx, max_idx = _PITCH_INDICES[0], _PITCH_INDICES[-1]
    if pitch_idx < min_idx:
        # Min val should be 0, so we can add here
        pitch_idx += max_idx + 1
    elif pitch_idx > max_idx:
        pitch_idx -= max_idx + 1
    return pitch_idx


def _is_valid_natural_note_name(name: str) -> bool:
    return name.upper() in NATURAL_NOTE_NAMES


def _is_valid_accidental_sign(sign: str) -> bool:
    return sign in _ACCIDENTAL_SIGNS


def _is_valid_note_name(name: str) -> bool:
    if len(name) == 1:
        return _is_valid_natural_note_name(name)
    elif len(name) != 2:
        return False
    nat_note_name, acc_sign = name
    return _is_valid_natural_note_name(nat_note_name) and _is_valid_accidental_sign(acc_sign)


@dataclass(frozen=True)
class Note:
    """
    Described by a pitch index and an accidental to distinguish this note's name from its enharmonics.
    """
    pitch_idx: int
    accidental: Accidental = Accidentals.NATURAL

    def __post_init__(self):
        """
        Ensure values are within acceptable range. See dataclass for documentation.
        """
        self._validate_pitch_idx()
        self._validate_accidental()

    def _validate_pitch_idx(self):
        min_idx, max_idx = _PITCH_INDICES[0], _PITCH_INDICES[-1]
        if min_idx <= self.pitch_idx <= max_idx:
            return
        raise ValueError(f'Pitch index ({self.pitch_idx} is outside of the acceptable range [{min_idx}, {max_idx}]')

    def _validate_accidental(self):
        if not isinstance(self.accidental, Accidental):
            raise TypeError(f'Expected {self.accidental} to be an instance of Accidental, instead got {self.accidental.__class__.__name__}')
        if self.accidental is Accidentals.NATURAL and self.pitch_idx not in _NATURAL_NOTE_INDICES:
            raise ValueError(f'Accidental is natural, but pitch index ({self.pitch_idx}) is not that of a natural note')

    @classmethod
    def from_name(cls, name: str) -> 'Note':
        if not _is_valid_note_name(name):
            raise ValueError(f'{name} is an invalid note name')
        if len(name) == 1:
            pitch_idx = _NATURAL_NOTE_INDEX_MAP[name]
            accidental = Accidentals.NATURAL
        else:
            nat_note_name, acc_sign = name
            nat_pitch_idx = _NATURAL_NOTE_INDEX_MAP[nat_note_name]
            accidental = _SIGN_ACCIDENTAL_MAP[acc_sign]
            pitch_idx = translate_pitch_idx(nat_pitch_idx, accidental.idx_offset)
        return cls(pitch_idx, accidental)

    def name(self) -> str:
        if self.accidental is Accidentals.NATURAL:
            return _NATURAL_INDEX_NOTE_MAP[self.pitch_idx]

        # Multiply by -1 to trace back to the natural note
        idx_offset = -1 * self.accidental.idx_offset
        natural_idx = translate_pitch_idx(self.pitch_idx, idx_offset)
        natural_note_name = _NATURAL_INDEX_NOTE_MAP[natural_idx]
        return natural_note_name + self.accidental.sign
