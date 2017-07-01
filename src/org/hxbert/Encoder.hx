package org.hxbert;
import flash.utils.ByteArray;
import flash.utils.Endian;
import org.hxbert.BERT;

/**
 * ...
 * @author oneclick
 */

class Encoder
{
  private var mResult: ByteArray;

  public function new(obj: Dynamic)
  {
    mResult = new ByteArray();
    mResult.endian = Endian.BIG_ENDIAN;

    mResult.writeByte(Tag.START);
    write(obj);
  }

  public function getBytes(): ByteArray
  {
    return mResult;
  }

  private function write(obj: Dynamic): Void
  {
    if (Std.is(obj, String))
      writeString(obj);
    else if (Std.is(obj, Int))
      writeInteger(obj);
    else if (Std.is(obj, Float))
      writeFloat(obj);
    else if (Std.is(obj, Array))
      writeList(obj);
    else if (Std.is(obj, List))
      writeList(Lambda.array(obj));
    else
      writeErlangValue(obj);
  }

  private function writeString(obj: String): Void
  {
    if (obj.length >= 65535)
    {
      var list = [];
      for (i in 0...obj.length)
        list.push(obj.charCodeAt(i));

      writeList(list);
      return;
    }

    mResult.writeByte(Tag.STRING);
    mResult.writeShort(obj.length);
    mResult.writeMultiByte(obj, 'us-ascii');
  }

  private function writeAtom(obj: String): Void
  {
    mResult.writeByte(Tag.ATOM);
    mResult.writeShort(obj.length);
    mResult.writeMultiByte(obj, 'us-ascii');
  }

  private function writeInteger(obj: Int): Void
  {
    if (obj >= 0 && obj < 256)
    {
      mResult.writeByte(Tag.SMALL_INTEGER);
      mResult.writeByte(obj);
    }
    else if (obj >= -134217728 && obj <= 134217727)
    {
      mResult.writeByte(Tag.INTEGER);
      mResult.writeInt(obj);
    }
    else
    {
      var num = new ByteArray();
      num.writeByte(obj < 0 ? 1 : 0);
      obj *= obj < 0 ? -1 : 1;
      while (obj != 0)
      {
        num.writeByte(obj % 256);
        obj = Math.floor(obj / 256);
      }

      // LARGE_BIG cannot be represented as a haxe integer value
      mResult.writeByte(Tag.SMALL_BIG);
      mResult.writeByte(num.length - 1);
      mResult.writeBytes(num);
    }
  }

  function writeFloat(obj: Float): Void
  {
    mResult.writeByte(Tag.NEW_FLOAT);
    mResult.writeDouble(obj);
  }

  function writeList(obj: Array<Dynamic>): Void
  {
    if (obj.length == 0)
    {
      mResult.writeByte(Tag.NIL);
      return;
    }

    mResult.writeByte(Tag.LIST);
    mResult.writeUnsignedInt(obj.length);
    for (item in obj)
      write(item);
    mResult.writeByte(Tag.NIL);
  }

  private function writeErlangValue(obj: ErlangValue): Void
  {
    switch (obj.type)
    {
      case ErlangType.ATOM:
        writeAtom(obj.value);
      case ErlangType.TUPLE:
        writeTuple(obj.value);
      case ErlangType.BINARY:
        writeBinary(obj.value);
      case ErlangType.BIG_INTEGER:
        writeBigInteger(obj.value);
    }
  }

  private function writeTuple(obj: Array<Dynamic>): Void
  {
    if (obj.length < 256)
    {
      mResult.writeByte(Tag.SMALL_TUPLE);
      mResult.writeByte(obj.length);
    }
    else
    {
      mResult.writeByte(Tag.LARGE_TUPLE);
      mResult.writeUnsignedInt(obj.length);
    }

    for (item in obj)
      write(item);
  }

  private function writeBigInteger(obj: Array<UInt>): Void
  {
    if (obj.length <= 256)
    {
      mResult.writeByte(Tag.SMALL_BIG);
      mResult.writeByte(obj.length - 1);
    }
    else
    {
      mResult.writeByte(Tag.LARGE_BIG);
      mResult.writeUnsignedInt(obj.length - 1);
    }

    for (byte in obj)
      mResult.writeByte(byte);
  }

  private function writeBinary(obj: Dynamic): Void
  {
    mResult.writeByte(Tag.BINARY);
    mResult.writeUnsignedInt(obj.length);
    if (Std.is(obj, String))
    {
      mResult.writeMultiByte(obj, 'us-ascii');
    }
    else
    {
      var byteList = cast(obj, Array<Dynamic>);
      for (byte in byteList)
        mResult.writeByte(byte);
    }
  }
}