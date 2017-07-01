package org.hxbert;
import flash.utils.ByteArray;
import org.hxbert.BERT;

/**
 * ...
 * @author oneclick
 */

class Decoder
{
  var mResult: Dynamic;
  var mBytes: ByteArray;

  public function new(bytes: ByteArray)
  {
    mBytes = bytes;
    mBytes.position = 0;

    var tag = mBytes.readUnsignedByte();
    if (tag != Tag.START)
      error('Incorrect start tag');

    mResult = read();
  }

  public function getValue(): Dynamic
  {
    return mResult;
  }

  private static function error(message: String): Void
  {
    throw ('BERT Decoder error: ' + message);
  }

  private function read(): Dynamic
  {
    var tag = mBytes.readUnsignedByte();

    switch (tag)
    {
      case Tag.SMALL_ATOM, Tag.ATOM:
        return readAtom(tag);
      case Tag.BINARY:
        return readBinary();
      case Tag.SMALL_INTEGER, Tag.INTEGER:
        return readInteger(tag);
      case Tag.SMALL_BIG, Tag.LARGE_BIG:
        return readBigIneger(tag);
      case Tag.FLOAT:
        return readFloat();
      case Tag.NEW_FLOAT:
        return readNewFloat();
      case Tag.STRING:
        return readString();
      case Tag.LIST:
        return readArray();
      case Tag.SMALL_TUPLE, Tag.LARGE_TUPLE:
        return readTuple(tag);
      case Tag.NIL:
        return [];
      default:
        error('Unexpected tag ' + tag + ' at pos ' + (mBytes.position - 1));
    }

    return null;
  }

  private function readAtom(type: UInt): ErlangValue
  {
    var length = switch (type)
    {
      case Tag.SMALL_ATOM:
        mBytes.readUnsignedByte();
      case Tag.ATOM:
        mBytes.readUnsignedShort();
    }

    return BERT.atom(mBytes.readMultiByte(length, 'us-ascii'));
  }

  private function readBinary(): ErlangValue
  {
    var length = mBytes.readUnsignedInt();
    var array = [];
    for (i in 0...length)
      array.push(mBytes.readUnsignedByte());

    return BERT.binary(array);
  }

  private function readInteger(type: UInt): Int
  {
    switch (type)
    {
      case Tag.SMALL_INTEGER:
        return mBytes.readUnsignedByte();
      case Tag.INTEGER:
        return mBytes.readInt();
    }

    return 0;
  }

  private function readBigIneger(type: UInt): Dynamic
  {
    // TODO: add attempt to read simple integer value, if it's not so big for haXe
    var length = 1 + switch (type)
    {
      case Tag.SMALL_BIG:
        mBytes.readUnsignedByte();
      case Tag.LARGE_BIG:
        mBytes.readUnsignedInt();
    }

    var array = [];
    while (length-- > 0)
      array.push(mBytes.readUnsignedByte());

    return BERT.bigInteger(array);
  }

  private function readFloat(): Float
  {
    return Std.parseFloat(mBytes.readMultiByte(31, 'us-ascii'));
  }

  private function readNewFloat(): Float
  {
    return mBytes.readDouble();
  }

  private function readString(): String
  {
    var length = mBytes.readUnsignedShort();
    var str = new StringBuf();
    while (length-- > 0)
      str.addChar(mBytes.readUnsignedByte());

    return str.toString();
  }

  private function readArray(): Array<Dynamic>
  {
    var length = mBytes.readUnsignedInt();
    var array = [];
    while (length-- > 0)
      array.push(read());

    if (Tag.NIL != mBytes.readUnsignedByte())
      error('Invalid end of list at pos' + (mBytes.position - 1));

    return array;
  }

  private function readTuple(type: UInt): ErlangValue
  {
    var length = switch (type)
    {
      case Tag.SMALL_TUPLE:
        mBytes.readUnsignedByte();
      case Tag.LARGE_TUPLE:
        mBytes.readUnsignedInt();
    }

    var array = [];
    while (length-- > 0)
      array.push(read());

    return BERT.tuple(array);
  }
}