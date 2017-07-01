package org.hxbert;
import flash.utils.ByteArray;

/**
 * ...
 * @author oneclick
 */

enum ErlangType
{
  ATOM;
  TUPLE;
  BINARY;
  BIG_INTEGER;
}

typedef ErlangValue =
{
  type: ErlangType,
  value: Dynamic
}

class BERT
{
  public static function encode(obj: Dynamic): ByteArray
  {
    return new Encoder(Converter.expand(obj)).getBytes();
  }

  public static function decode(bytes: ByteArray, ?raw: Bool = false): Dynamic
  {
    var value = new Decoder(bytes).getValue();
    return raw ? value : Converter.fold(value);
  }

  public static function atom(val: String): ErlangValue
  {
    return { type: ErlangType.ATOM, value: val };
  }

  public static function tuple(val: Array<Dynamic>): ErlangValue
  {
    return { type: ErlangType.TUPLE, value: val };
  }

  public static function binary(val: Dynamic): ErlangValue
  {
    return { type: ErlangType.BINARY, value: val };
  }

  public static function bigInteger(val: Array<UInt>): ErlangValue
  {
    return { type: ErlangType.BIG_INTEGER, value: val };
  }
}