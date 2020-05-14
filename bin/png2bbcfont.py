#!/usr/bin/python
import png,argparse,sys,math,bbc

##########################################################################
##########################################################################

def save_file(header,data,path,options):
    if path is not None:
        with open(path,'wb') as f:
            if header is not None:
                f.write(''.join([chr(x) for x in header]))

            f.write(''.join([chr(x) for x in data]))

        if options.inf:
            with open('%s.inf'%path,'wt') as f: pass

##########################################################################
##########################################################################

def main(options):
    if options.mode<0 or options.mode>6:
        print>>sys.stderr,'FATAL: invalid mode: %d'%options.mode
        sys.exit(1)

    if options.glyph_dim is None:
        print>>sys.stderr,'FATAL: glyph dimensions are required'
        sys.exit(1)

    if options.mode in [0,3,4,6]:
        palette=[0,7]
        pixels_per_byte=8
        pack=bbc.pack_1bpp
    elif options.mode in [1,5]:
        palette=[0,1,3,7]
        pixels_per_byte=4
        pack=bbc.pack_2bpp
    elif options.mode==2:
        # this palette is indeed only 8 entries...
        palette=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        pixels_per_byte=2
        pack=bbc.pack_4bpp
    
    if options.palette is not None:
        if len(options.palette)!=len(palette):
            print>>sys.stderr,'FATAL: invalid mode %d palette - must have %d entries'%(options.mode,n)
            sys.exit(1)

        palette=[]
        for i in range(len(options.palette)):
            if options.palette[i] not in "01234567":
                print>>sys.stderr,'FATAL: invalid BBC colour: %s'%options.palette[i]
                sys.exit(1)

            for j in range(len(options.palette)):
                if i!=j and options.palette[i]==options.palette[j]:
                    print>>sys.stderr,'FATAL: duplicate BBC colour: %s'%options.palette[i]
                    sys.exit(1)

            palette.append(int(options.palette[i]))

    image=bbc.load_png(options.input_path,
                       options.mode,
                       options._160,
                       -1 if options.transparent_output else None,
                       options.transparent_rgb,
                       not options.quiet,
                       options.use_fixed_16)

    #if len(image[0])%pixels_per_byte!=0:
    #    print>>sys.stderr,'FATAL: Mode %d image width must be a multiple of %d'%(options.mode,pixels_per_byte)
    #    sys.exit(1)
        
    #if len(image)%8!=0:
    #    print>>sys.stderr,'FATAL: image height must be a multiple of 8'
    #    sys.exit(1)

    # print '%d x %d'%(len(image[0]),len(image))

    # Convert into BBC physical indexes: 0-7, and -1 for transparent
    # (going by the alpha channel value).
    bbc_lidxs=[]
    bbc_mask=[]
    for y in range(len(image)):
        bbc_lidxs.append([])
        bbc_mask.append([])
        for x in range(len(image[y])):
            if image[y][x]==-1:
                bbc_lidxs[-1].append(options.transparent_output)
                bbc_mask[-1].append(len(palette)-1)
            else:
                try:
                    bbc_lidxs[-1].append(palette.index(image[y][x]))
                except ValueError:
                    # print>>sys.stderr,'(NOT) FATAL: (%d,%d): colour %d not in BBC palette'%(x,y,image[y][x])
                    bbc_lidxs[-1].append(0)
                    # sys.exit(1)

                bbc_mask[-1].append(0)

        assert len(bbc_lidxs[-1])==len(image[y])
        assert len(bbc_mask[-1])==len(image[y])

    assert len(bbc_lidxs)==len(image)
    assert len(bbc_mask)==len(image)
    for y in range(len(image)):
        assert len(bbc_lidxs[y])==len(image[y])
        assert y==0 or len(bbc_lidxs[y])==len(bbc_lidxs[y-1])
        assert len(bbc_mask[y])==len(image[y])

    glyph_widths=[]
    for sx in range(0,len(bbc_lidxs[0]),options.glyph_dim[0]):
        if sx+options.glyph_dim[0] > len(bbc_lidxs[0]):
            break
        
        w=options.glyph_dim[0]
        for x in range(0,w):
            if image[0][sx+x]==-1:
                w=x+1
                break

        glyph_widths.append(w)
    
    print glyph_widths

    pixel_data=[]
    data_offsets=[]
    glyphs=0
    assert len(bbc_lidxs)==len(bbc_mask)
    # Arranged as single line of glyphs, not a grid
    for sx in range(0,len(bbc_lidxs[0]),options.glyph_dim[0]):
        if sx+options.glyph_dim[0] > len(bbc_lidxs[0]):
            break
        
        if options.rle:
            dupes=0
            existing_line=[]
            data_offsets.append(len(pixel_data))

        # Saved as a line of bytes, not in screen format
        for y in range(0,options.glyph_dim[1]):
            pixel_line=[]
            for x in range(0,glyph_widths[glyphs],pixels_per_byte):
                assert y<len(bbc_lidxs)
                assert sx+x<len(bbc_lidxs[y]),(sx,x,len(bbc_lidxs[y]),y)
                xs=bbc_lidxs[y][sx+x:sx+x+pixels_per_byte]
                assert len(xs)==pixels_per_byte,(xs,pixels_per_byte,sx,x,y)
                pixel_line.append(pack(xs))

            if options.rle:
                if existing_line==pixel_line:
                    dupes+=1
                else:
                    if dupes > 0:
                        # Hack balls!
                        if glyph_widths[glyphs] < options.glyph_dim[0]:
                            pixel_data.append(dupes | 0x80)
                        else:
                            pixel_data.append(dupes)

                        pixel_data.extend(existing_line)
                    existing_line=pixel_line
                    dupes=1
            else:
                pixel_data.extend(pixel_line)

        # Flush last line.
        if options.rle:
            # But only if not blanks.
            if sum(existing_line) != 0:
                if glyph_widths[glyphs] < options.glyph_dim[0]:
                    pixel_data.append(dupes | 0x80)
                else:
                    pixel_data.append(dupes)
                pixel_data.extend(existing_line)

            # Mark end of data.
            pixel_data.append(255)

        glyphs+=1
        if options.max_glyphs is not None and glyphs>=options.max_glyphs:
            break

    print '%d glyphs at %d bytes BBC data'%(glyphs,len(pixel_data))

    header_data = []
    if options.rle:
        for offset in data_offsets:
            a=offset + glyphs*2
            header_data.append(a % 256)
            header_data.append(a / 256)
        print 'plus %d bytes header'%(len(header_data))

    save_file(header_data,pixel_data,options.output_path,options)

##########################################################################
##########################################################################

if __name__=='__main__':
    parser=argparse.ArgumentParser()

    parser.add_argument('-o',dest='output_path',metavar='FILE',help='output BBC data to %(metavar)s')
    parser.add_argument('--inf',action='store_true',help='if -o specified, also produce a 0-byte .inf file')
    parser.add_argument('--160',action='store_true',dest='_160',help='double width (Mode 5/2) aspect ratio')
    parser.add_argument('-p','--palette',help='specify BBC palette')
    parser.add_argument('--transparent-output',
                        default=None,
                        type=int,
                        help='specify output index to use for transparent PNG pixels')
    parser.add_argument('--transparent-rgb',
                        default=None,
                        type=int,
                        nargs=3,
                        help='specify opaque RGB to be interpreted as transparent')
    parser.add_argument('--fixed-16',action='store_true',dest='use_fixed_16',
                        help='use fixed palette when converting 16 colours')
    parser.add_argument('--glyph-dim',
                        default=None,
                        type=int,
                        nargs=2,
                        help='specify dimensions of a single glyph')
    parser.add_argument('--max-glyphs',
                        default=None,
                        type=int,
                        help='maximum number of glyphs to save')
    parser.add_argument('--rle',action='store_true',help='use simple per-line RLE encoding to save space')
    parser.add_argument('-q','--quiet',action='store_true',help='don\'t print warnings')
    parser.add_argument('input_path',metavar='FILE',help='load PNG data fro %(metavar)s')
    parser.add_argument('mode',type=int,help='screen mode')
    main(parser.parse_args())
