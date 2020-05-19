# Parse AKS Channel as Events

import argparse
import binascii
import sys
import os

BASE_ADDRESS = 0x400

# Read 1 byte from our input file
def get_byte(file):
    return ord(file.read(1))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("input", help="scene1.bin STNICCC data file [input]")
    parser.add_argument("-o", "--output", metavar="<output>", help="write new data stream <output> (default is '[input].new.bin')")
    args = parser.parse_args()

    src = args.input
    dst = args.output
    if dst == None:
        dst = os.path.splitext(src)[0] + ".new.bin"

    # check for missing files
    if not os.path.isfile(src):
        print("ERROR: File '" + src + "' not found")
        sys.exit()

    input_file = open(src, 'rb')

    # Parse here

    flag_byte1 = get_byte(input_file)
    flag_byte2 = get_byte(input_file)

    pattern_offsets = []

    while True:
        offset = get_byte(input_file) | get_byte(input_file) << 8

        if offset != 0:
            pattern_offsets.append(offset - BASE_ADDRESS)
        else:
            break

    pattern_loop = get_byte(input_file) | get_byte(input_file) << 8
    pattern_loop = pattern_loop - BASE_ADDRESS

    print "Found {0} patterns.".format(len(pattern_offsets))
    print [hex(no) for no in pattern_offsets]

    tracks_data = []
    tracks_lengths = dict()
    tracks_offsets = dict()

    # Skip header.
    offset_to_track = 4 + len(pattern_offsets) * 2
    tracks = 0

    while True:
        offset = input_file.tell()
        lines = 0
        track_data = []
        track_data_length = 0

        while lines < 128:
            # print lines
            try:
                note = get_byte(input_file)
            except:
                lines = -1
                break

            if note >= 128:
                # empty cells
                lines += note - 127
                # print 'Skipping {0} lines.'.format(note-127)
                # add this as is
                track_data.append(note)
                track_data_length += 1

            elif note == 120:
                # No note
                instrument = get_byte(input_file)
                if instrument != 0:
                    raise ValueError('Unexpected instrument', instrument)

                effects = []

                while True:
                    effect_number = get_byte(input_file)
                    if effect_number == 0:
                        break

                    if effect_number != 10:
                        raise ValueError('Unexpected effect number', effect_number)

                    effect_value = get_byte(input_file) | get_byte(input_file) << 8
                    effects.append(effect_value)
                    track_data_length += 2

                track_data.append(effects)
                track_data_length += 1
                lines += 1
            else:
                raise ValueError('Unexpected note type', note)

        if lines == -1:
            break

        print 'Track with offset: {0}'.format(hex(offset))
        # print [hex(no) for no in track_data]
        print track_data

        tracks_data.append(track_data)
        tracks_lengths[offset] = track_data_length
        tracks_offsets[offset] = offset_to_track
        offset_to_track += track_data_length
        tracks += 1

    data = bytearray()

    print "Found {0} tracks.".format(tracks)

    # Output header.
    for pattern in pattern_offsets:
        offset = tracks_offsets[pattern] + BASE_ADDRESS
        data.append(offset % 256)
        data.append(offset >> 8)

    # End of linker.
    data.append(0)
    data.append(0)
    data.append(BASE_ADDRESS % 256)
    data.append(BASE_ADDRESS >> 8)

    # Output tracks.
    for track in tracks_data:
        for entry in track:
            if isinstance(entry, int):
                data.append(entry)              # emptry cells.
            else:
                data.append(len(entry))         # number of effects.
                for effect in entry:
                    data.append(effect % 256)   # event data
                    data.append(effect >> 8)    # event code

    assert(len(data) == offset_to_track)

    output_file = open(dst, 'wb')
    print "Writing {0} bytes to output.".format(len(data))
    output_file.write(data)
    output_file.close()
