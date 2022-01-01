import pytest

from src.backend import note


def test__is_valid_note_name():
    assert note._is_valid_note_name('A')
    assert not note._is_valid_note_name('H')
    assert note._is_valid_note_name(f'A{note.SHARP_SIGN}')
    assert not note._is_valid_note_name(f'A{note.FLAT_SIGN}{note.FLAT_SIGN}')
    assert note._is_valid_note_name(f'A{note.DOUBLE_FLAT_SIGN}')


class TestNote:

    def test_name(self):
        a_natural = note.Note(0, note.Accidentals.NATURAL)
        assert a_natural.name() == 'A'

        b_flat = note.Note(1, note.Accidentals.FLAT)
        assert b_flat.name() == f'B{note.FLAT_SIGN}'

        a_sharp = note.Note(1, note.Accidentals.SHARP)
        assert a_sharp.name() == f'A{note.SHARP_SIGN}'

        a_double_flat = note.Note(10, note.Accidentals.DOUBLE_FLAT)
        assert a_double_flat.name() == f'A{note.DOUBLE_FLAT_SIGN}'

        with pytest.raises(TypeError):
            note.Note(1, None)

    def test_from_name(self):
        a_natural = note.Note.from_name('A')
        assert a_natural.pitch_idx == 0
        assert a_natural.accidental == note.Accidentals.NATURAL

        a_sharp = note.Note.from_name(f'A{note.SHARP_SIGN}')
        assert a_sharp.pitch_idx == 1
        assert a_sharp.accidental == note.Accidentals.SHARP
        #
        a_flat = note.Note.from_name(f'A{note.FLAT_SIGN}')
        assert a_flat.pitch_idx == 11
        assert a_flat.accidental == note.Accidentals.FLAT

        a_double_flat = note.Note.from_name(f'A{note.DOUBLE_FLAT_SIGN}')
        assert a_double_flat.pitch_idx == 10
        assert a_double_flat.accidental == note.Accidentals.DOUBLE_FLAT

        g_double_sharp = note.Note.from_name(f'G{note.DOUBLE_SHARP_SIGN}')
        assert g_double_sharp.pitch_idx == 0
        assert g_double_sharp.accidental == note.Accidentals.DOUBLE_SHARP




