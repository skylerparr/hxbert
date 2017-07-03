package org.hxbert;
import haxe.ds.ObjectMap;
import haxe.io.Input;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import org.hxbert.BERT;

/**
 * ...
 * @author oneclick
 */

class Decoder {
    private static function error(message:String):Void {
        throw ('BERT Decoder error: ' + message);
    }

    public static function decode(mBytes:Bytes):Dynamic {
        var input:BytesInput = new BytesInput(mBytes, 0, mBytes.length);
        input.bigEndian = true;

        var tagStart = input.readByte();
        if (tagStart != Tag.START) {
            error('Incorrect start tag');
        }
        return read(input);
    }

    private static function read(input:Input):Dynamic {
        var tag:Int = input.readByte();

        return switch (tag)
        {
            case Tag.SMALL_ATOM, Tag.ATOM:
                readAtom(input, tag);
            case Tag.BINARY:
                readBinary(input);
            case Tag.SMALL_INTEGER, Tag.INTEGER:
                readInteger(input, tag);
//      case Tag.SMALL_BIG, Tag.LARGE_BIG:
//        return readBigIneger(tag);
//      case Tag.FLOAT:
//        readFloat(mBytes);
            case Tag.NEW_FLOAT:
                readNewFloat(input);
            case Tag.STRING:
                readString(input);
            case Tag.LIST:
                readArray(input);
            case Tag.MAP:
                readMap(input);
            case Tag.SMALL_TUPLE, Tag.LARGE_TUPLE:
                readTuple(tag, input);
            default:
                error('Unexpected tag ' + tag + ' at pos 1');
                {};
        }
    }

    private static inline function readAtom(input:Input, type:UInt):ErlangValue {
        var length = switch (type)
        {
            case Tag.SMALL_ATOM:
                input.readByte();
            case Tag.ATOM:
                input.readUInt16();
            default:
                null;
        }
        return BERT.atom(input.readString(length));
    }

    private static inline function readBinary(input:Input):ErlangValue {
        var length = input.readInt32();
        var array = [];
        for (i in 0...length) {
            array.push(input.readByte());
        }

        return BERT.binary(array);
    }

    private static inline function readInteger(input:Input, type:UInt):Int {
        return switch (type)
        {
            case Tag.SMALL_INTEGER:
                input.readByte();
            case Tag.INTEGER:
                input.readInt32();
            default:
                0;
        }

    }
//
//  private function readBigIneger(type: UInt): Dynamic
//  {
//    // TODO: add attempt to read simple integer value, if it's not so big for haXe
//    var length = 1 + switch (type)
//    {
//      case Tag.SMALL_BIG:
//        mBytes.readUnsignedByte();
//      case Tag.LARGE_BIG:
//        mBytes.readUnsignedInt();
//    }
//
//    var array = [];
//    while (length-- > 0)
//      array.push(mBytes.readUnsignedByte());
//
//    return BERT.bigInteger(array);
//  }
//

//  private static inline function readFloat(bytes:Bytes):Float {
//    return Std.parseFloat(bytes.readMultiByte(31, 'us-ascii'));
//  }

    private static inline function readNewFloat(input:Input):Float {
        return input.readDouble();
    }

    private static inline function readString(input:Input):String {
        var length:Int = input.readInt16();
        return input.readString(length);
    }

    private static inline function readArray(input: Input):Array<Dynamic> {
        var length = input.readInt32();
        var array: Array<Dynamic> = [];
        while (length-- > 0) {
            array.push(read(input));
        }

        if (Tag.NIL != input.readByte()) {
            error('Invalid end of list at pos ' + (cast(input, BytesInput).position - 1));
        }

        return array;
    }

    private static inline function readMap(input: Input): ErlangValue {
        var length = input.readInt32();

        var map: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        while (length-- > 0) {
            map.set(read(input), read(input));
            length--;
        }

        return BERT.map(map);
    }

    private static inline function readTuple(type:UInt, input:Input):ErlangValue {
        var length = switch (type)
        {
            case Tag.SMALL_TUPLE:
                input.readByte();
            case Tag.LARGE_TUPLE:
                input.readInt32();
            default:
                0;
        }

        var array = [];
        while (length-- > 0) {
            array.push(read(input));
        }

        return BERT.tuple(array);
    }
}