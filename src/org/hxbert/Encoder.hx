package org.hxbert;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import org.hxbert.BERT;
import haxe.io.Bytes;


/**
 * ...
 * @author oneclick
 */

class Encoder {

  public static inline function encode(obj:Dynamic):Bytes {
    var retVal:Bytes = null;
    if (Std.is(obj, String)) {
      retVal = writeString(obj);
    } else if (Std.is(obj, Int)) {
      retVal = writeInteger(obj);
    } else if (Std.is(obj, Float)) {
      retVal = writeFloat(obj);
    }
//    else if (Std.is(obj, Array))
//      writeList(obj);
//    else if (Std.is(obj, List))
//      writeList(Lambda.array(obj));
    else {
      retVal = writeErlangValue(obj);
    }
    return retVal;
  }

  private static inline function writeString(obj:String):Bytes {
//    if (obj.length >= 65535) {
//      var list = [];
//      for (i in 0...obj.length) {
//        list.push(obj.charCodeAt(i));
//      }
//
//      writeList(list);
//      return;
//    }

    var mResult: Bytes = Bytes.alloc(obj.length + 4);
    mResult.set(0, Tag.START);
    mResult.set(1, Tag.STRING);
    mResult.set(3, obj.length);
    mResult.blit(4, Bytes.ofString(obj), 0, obj.length);

    return mResult;
  }

  private static function writeAtom(obj:String):Bytes {
    var mResult:Bytes = Bytes.alloc(obj.length + 4);
    mResult.set(0, Tag.START);

    mResult.set(1, Tag.ATOM);
    mResult.set(3, obj.length);
    var b:Bytes = Bytes.ofString(obj);
    mResult.blit(4, b, 0, obj.length);
    return mResult;
  }

  private static function writeInteger(obj:Int):Bytes {
    var output:BytesOutput = new BytesOutput();
    output.bigEndian = true;

    var bytes = null;

    if (obj >= 0 && obj < 256) {
      output.writeInt8(obj);

      bytes = Bytes.alloc(3);
      bytes.set(0, Tag.START);
      bytes.set(1, Tag.SMALL_INTEGER);
      bytes.blit(2, output.getBytes(), 0, 1);
    } else if (obj >= -134217728 && obj <= 134217727) {
      output.writeInt32(obj);

      bytes = Bytes.alloc(6);
      bytes.set(0, Tag.START);
      bytes.set(1, Tag.INTEGER);
      bytes.blit(2, output.getBytes(), 0, 4);
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
    return bytes;
  }

  private static inline function writeFloat(obj:Float):Bytes {
    var output:BytesOutput = new BytesOutput();
    output.bigEndian = true;
    output.prepare(8);
    output.writeDouble(obj);

    var bytes:Bytes = Bytes.alloc(10);
    bytes.set(0, Tag.START);
    bytes.set(1, Tag.NEW_FLOAT);
    bytes.blit(2, output.getBytes(), 0, 8);
    return bytes;
  }

//  private static inline function writeList(mResult: Bytes, obj:Array<Dynamic>):Void {
//    if (obj.length == 0) {
//      mResult.writeByte(Tag.NIL);
//      return;
//    }
//
//    mResult.writeByte(Tag.LIST);
//    mResult.writeUnsignedInt(obj.length);
//    for (item in obj) {
//      write(item);
//    }
//    mResult.writeByte(Tag.NIL);
//  }


  private static inline function writeErlangValue(obj:ErlangValue):Bytes {
    return switch (obj.type)
    {
      case ErlangType.ATOM:
        writeAtom(obj.value);
      case ErlangType.TUPLE:
        Bytes.alloc(0);
//        writeTuple(obj.value);
      case ErlangType.BINARY:
        Bytes.alloc(0);
//        writeBinary(obj.value);
      case ErlangType.BIG_INTEGER:
        Bytes.alloc(0);
//        writeBigInteger(obj.value);
      default:
        Bytes.alloc(0);
    }
  }
//
//  private function writeTuple(obj:Array<Dynamic>):Void {
//    if (obj.length < 256) {
//      mResult.writeByte(Tag.SMALL_TUPLE);
//      mResult.writeByte(obj.length);
//    }
//    else {
//      mResult.writeByte(Tag.LARGE_TUPLE);
//      mResult.writeUnsignedInt(obj.length);
//    }
//
//    for (item in obj)
//      write(item);
//  }
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
//  private function writeBinary(obj:Dynamic):Void {
//    mResult.writeByte(Tag.BINARY);
//    mResult.writeUnsignedInt(obj.length);
//    if (Std.is(obj, String)) {
//      mResult.writeMultiByte(obj, 'us-ascii');
//    }
//    else {
//      var byteList = cast(obj, Array<Dynamic>);
//      for (byte in byteList)
//        mResult.writeByte(byte);
//    }
//  }
}