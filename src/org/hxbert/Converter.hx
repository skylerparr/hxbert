package org.hxbert;
import org.hxbert.BERT;

/**
 * ...
 * @author oneclick
 */

class Converter
{

  public static function expand(obj: Dynamic): Dynamic
  {
    if (obj == null)
      return BERT.tuple([BERT.atom('bert'), BERT.atom('nil')]);

    if (Std.is(obj, Bool))
      return BERT.tuple([BERT.atom('bert'), BERT.atom(Std.string(obj))]);

    if (Std.is(obj, Array))
      return Lambda.map(obj, expand);

    if (isErlangValue(obj))
      return obj;

    if (Reflect.fields(obj).length > 0)
    {
      var list = [];
      for (field in Reflect.fields(obj))
      {
        if (!Reflect.isFunction(Reflect.field(obj, field)))
          list.push(BERT.tuple([field, expand(Reflect.field(obj, field))]));
      }

      return BERT.tuple([BERT.atom('bert'), BERT.atom('dict'), list]);
    }

    return obj;
  }

  public static function fold(obj: Dynamic): Dynamic
  {
    if (Std.is(obj, Int) || Std.is(obj, Float) || Std.is(obj, String))
      return obj;

    if (isErlangValue(obj))
    {
      if (obj.type == ErlangType.ATOM)
        return obj.value;

      if (obj.type == ErlangType.TUPLE && isAtom(obj.value[0], 'bert'))
      {
        if (isAtom(obj.value[1], 'nil'))
          return null;

        if (isAtom(obj.value[1], 'true'))
          return true;

        if (isAtom(obj.value[1], 'false'))
          return false;

        if (isAtom(obj.value[1], 'dict'))
        {
          return getDict(obj.value[2]);
          /*if (fields != null)
					{
						var val = { };
						for (field in fields.keys())
							Reflect.setField(val, field, fold(fields.get(field)));

						return val;
					}*/
        }
      }

      return obj; // BINARY, BIG_INTEGER
    }

    if (!Std.is(obj, Array))
      return obj;

    return Lambda.array(Lambda.map(obj, fold));
  }

  private static function isErlangValue(obj: Dynamic, type: Null<ErlangType> = null): Bool
  {
    if (Reflect.hasField(obj, 'type') && Type.getEnum(obj.type) == ErlangType)
      return (type != null) ? (obj.type == type) : true;

    return false;
  }

  private static function isAtom(obj: Dynamic, name: String): Bool
  {
    return isErlangValue(obj, ErlangType.ATOM) && obj.value == name;
  }

  private static function getDict(obj: Array<Dynamic>): Dynamic
  {
    var val = {};

    for (item in obj)
    {
      if (!(isErlangValue(item, ErlangType.TUPLE) && item.value.length == 2))
        return null;

      var fieldName = item.value[0];
      var name = Std.is(fieldName, String) ? Std.string(fieldName) : null;

      if (name == null)
      {
        if (isErlangValue(fieldName, ErlangType.ATOM))
          name = Std.string(fieldName.value);
        else if (isErlangValue(fieldName, ErlangType.BINARY))
          name = binaryToString(fieldName.value);
      }

      if (name == null)
        return null;

      Reflect.setField(val, name, fold(item.value[1]));
    }

    return val;
  }

  private static function binaryToString(obj: Array<Dynamic>): String
  {
    for (item in obj)
    {
      if (!Std.is(item, Int) || item < 0 || item >= 256)
        return null;
    }

    var buf = new StringBuf();
    for (char in obj)
      buf.addChar(char);

    return buf.toString();
  }
}