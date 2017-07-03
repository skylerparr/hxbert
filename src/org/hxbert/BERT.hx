package org.hxbert;
import haxe.io.Bytes;

/**
 * ...
 * @author oneclick
 */

enum ErlangType {
  ATOM;
  TUPLE;
  BINARY;
  BIG_INTEGER;
}

typedef ErlangValue =
{
  type:ErlangType,
  value:Dynamic
}

class BERT {
  public static inline function encode(obj:Dynamic):Bytes {
    return Encoder.encode(Converter.expand(obj));
  }

  public static inline function decode(bytes:Bytes, raw:Bool = false):Dynamic {
    var value: Dynamic = Decoder.decode(bytes);
    return raw ? value : Converter.fold(value);
  }

  public static inline function atom(val:String):ErlangValue {
    return { type: ErlangType.ATOM, value: val };
  }

  public static inline function tuple(val:Array<Dynamic>):ErlangValue {
    return { type: ErlangType.TUPLE, value: val };
  }

  public static inline function binary(val:Dynamic):ErlangValue {
    return { type: ErlangType.BINARY, value: val };
  }

  public static inline function bigInteger(val:Array<UInt>):ErlangValue {
    return { type: ErlangType.BIG_INTEGER, value: val };
  }
}