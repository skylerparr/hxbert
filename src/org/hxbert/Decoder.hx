package org.hxbert;
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
    var tagStart = mBytes.get(0);
    if (tagStart != Tag.START) {
      error('Incorrect start tag');
    }

    var tag:Int = mBytes.get(1);

    return switch (tag)
    {
      case Tag.SMALL_ATOM, Tag.ATOM:
        readAtom(mBytes, tag);
//      case Tag.BINARY:
////        return readBinary();
      case Tag.SMALL_INTEGER, Tag.INTEGER:
        readInteger(mBytes, tag);
//      case Tag.SMALL_BIG, Tag.LARGE_BIG:
//        return readBigIneger(tag);
//      case Tag.FLOAT:
//        readFloat(mBytes);
      case Tag.NEW_FLOAT:
        readNewFloat(mBytes);
//      case Tag.STRING:
////        return readString();
//      case Tag.LIST:
////        return readArray();
//      case Tag.SMALL_TUPLE, Tag.LARGE_TUPLE:
////        return readTuple(tag);
//      case Tag.NIL:
//        [];
      default:
        error('Unexpected tag ' + tag + ' at pos 1');
        {};
    }
  }

  private static inline function readAtom(mBytes:Bytes, type:UInt):ErlangValue {
    var length = switch (type)
    {
      case Tag.SMALL_ATOM:
        mBytes.get(2);
      case Tag.ATOM:
        mBytes.get(3);
      default:
        null;
    }

    return BERT.atom(mBytes.readString(4, mBytes.length - 4));
  }
//
//  private function readBinary(): ErlangValue
//  {
//    var length = mBytes.readUnsignedInt();
//    var array = [];
//    for (i in 0...length)
//      array.push(mBytes.readUnsignedByte());
//
//    return BERT.binary(array);
//  }
//
  private static inline function readInteger(mBytes: Bytes, type:UInt):Int {
    return switch (type)
    {
      case Tag.SMALL_INTEGER:
        mBytes.get(2);
      case Tag.INTEGER:
        var input: BytesInput = new BytesInput(mBytes, 2);
        input.bigEndian = true;
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

  private static inline function readNewFloat(bytes:Bytes):Float {
    var input:BytesInput = new BytesInput(bytes, 2, 8);
    input.bigEndian = true;
    return input.readDouble();
  }
//
//  private function readString(): String
//  {
//    var length = mBytes.readUnsignedShort();
//    var str = new StringBuf();
//    while (length-- > 0)
//      str.addChar(mBytes.readUnsignedByte());
//
//    return str.toString();
//  }
//
//  private function readArray(): Array<Dynamic>
//  {
//    var length = mBytes.readUnsignedInt();
//    var array = [];
//    while (length-- > 0)
//      array.push(read());
//
//    if (Tag.NIL != mBytes.readUnsignedByte())
//      error('Invalid end of list at pos' + (mBytes.position - 1));
//
//    return array;
//  }
//
//  private function readTuple(type: UInt): ErlangValue
//  {
//    var length = switch (type)
//    {
//      case Tag.SMALL_TUPLE:
//        mBytes.readUnsignedByte();
//      case Tag.LARGE_TUPLE:
//        mBytes.readUnsignedInt();
//    }
//
//    var array = [];
//    while (length-- > 0)
//      array.push(read());
//
//    return BERT.tuple(array);
//  }
}