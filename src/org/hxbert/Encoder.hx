package org.hxbert;
import org.hxbert.BERT.ErlangValue;
import haxe.ds.ObjectMap;
import haxe.io.Output;
import haxe.io.BytesOutput;
import org.hxbert.BERT;
import haxe.io.Bytes;


/**
 * ...
 * @author oneclick
 */

class Encoder {

    public static inline function encode(obj:Dynamic):Bytes {
        var output:BytesOutput = new BytesOutput();
        output.bigEndian = true;
        output.writeByte(Tag.START);

        write(obj, output);
        return output.getBytes();
    }

    private static inline function write(obj:Dynamic, output:Output):Void {
        if (Std.is(obj, String)) {
            writeString(obj, output);
        } else if (Std.is(obj, Int)) {
            writeInteger(obj, output);
        } else if (Std.is(obj, Float)) {
            writeFloat(obj, output);
        } else if (Std.is(obj, Array)) {
            writeList(obj, output);
        } else if (Std.is(obj, List)) {
            writeList(Lambda.array(obj), output);
        } else {
            writeErlangValue(obj, output);
        }
    }

    private static inline function writeString(obj:String, output:Output):Void {
//    if (obj.length >= 65535) {
//      var list = [];
//      for (i in 0...obj.length) {
//        list.push(obj.charCodeAt(i));
//      }
//
//      writeList(list);
//      return;
//    }

        output.writeByte(Tag.STRING);
        output.writeInt16(obj.length);
        output.writeFullBytes(Bytes.ofString(obj), 0, obj.length);
    }

    private static inline function writeAtom(obj:String, output:Output):Void {
        output.writeByte(Tag.ATOM);
        output.writeInt16(obj.length);
        output.writeString(obj);
    }

    private static inline function writeInteger(obj:Int, output:Output):Void {
        if (obj >= 0 && obj < 256) {
            output.writeByte(Tag.SMALL_INTEGER);
            output.writeByte(obj);
        } else if (obj >= -134217728 && obj <= 134217727) {
            output.writeByte(Tag.INTEGER);
            output.writeInt32(obj);

//    } else {
//      var num = Bytes.alloc(100);
//      num.writeByte(obj < 0 ? 1 : 0);
//      obj *= obj < 0 ? -1 : 1;
//      while (obj != 0) {
//        num.writeByte(obj % 256);
//        obj = Math.floor(obj / 256);
//      }
//
//      // LARGE_BIG cannot be represented as a haxe integer value
//      mResult.writeByte(Tag.SMALL_BIG);
//      mResult.writeByte(num.length - 1);
//      mResult.writeBytes(num);
        }
    }

    private static inline function writeFloat(obj:Float, output:Output):Void {
        output.writeByte(Tag.NEW_FLOAT);
        output.writeDouble(obj);
    }

    private static inline function writeList(obj:Array<Dynamic>, output:Output):Void {
        output.writeByte(Tag.LIST);
        output.writeInt32(obj.length);
        for (item in obj) {
            write(item, output);
        }
        output.writeByte(Tag.NIL);
    }

    private static inline function writeErlangValue(obj:ErlangValue, output:Output):Void {
        switch (obj.type)
        {
            case ErlangType.ATOM:
                writeAtom(obj.value, output);
            case ErlangType.TUPLE:
                writeTuple(obj.value, output);
            case ErlangType.BINARY:
                writeBinary(obj.value, output);
            case ErlangType.MAP:
                writeMap(obj.value, output);
            case ErlangType.BIG_INTEGER:
//        writeBigInteger(obj.value);
            default:
        }
    }

    private static inline function writeTuple(obj:Array<Dynamic>, output:Output):Void {
        if (obj.length < 256) {
            output.writeByte(Tag.SMALL_TUPLE);
            output.writeByte(obj.length);
        } else {
            output.writeByte(Tag.LARGE_TUPLE);
            output.writeInt32(obj.length);
        }

        for (item in obj)
            write(item, output);
    }
//
//  private function writeBigInteger(obj:Array<UInt>):Void {
//    if (obj.length <= 256) {
//      mResult.writeByte(Tag.SMALL_BIG);
//      mResult.writeByte(obj.length - 1);
//    }
//    else {
//      mResult.writeByte(Tag.LARGE_BIG);
//      mResult.writeUnsignedInt(obj.length - 1);
//    }
//
//    for (byte in obj)
//      mResult.writeByte(byte);
//  }
//

    private static inline function writeMap(obj: ObjectMap<Dynamic, Dynamic>, output: Output): Void {
        var length: Int = 0;
        for(key in obj.keys()) {
            length++;
        }
        output.writeByte(Tag.MAP);
        output.writeInt32(length);
        for(key in obj.keys()) {
            write(key, output);
            write(obj.get(key), output);
        }
    }

    private static inline function writeBinary(obj:Dynamic, output:Output):Void {
        output.writeByte(Tag.BINARY);
        output.writeInt32(obj.length);
        if (Std.is(obj, String)) {
            writeString(obj, output);
        } else {
            var byteList:Array<Dynamic> = cast(obj, Array<Dynamic>);
            for (byte in byteList) {
                output.writeByte(byte);
            }
        }
    }
}