package org.hxbert;
import flash.utils.ByteArray;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

/**
 * ...
 * @author oneclick
 */

class Test extends TestCase
{
  public static function run()
  {
    var runner = new TestRunner();
    runner.add(new Test());
    runner.run();
  }

  private static function str(byteArray: ByteArray): String
  {
    byteArray.position = 0;
    var str = new StringBuf();
    while (byteArray.bytesAvailable > 0)
    {
      str.add(Std.string(byteArray.readUnsignedByte()));
      if (byteArray.bytesAvailable != 0)
        str.add(',');
    }

    return '[' + str.toString() + ']';
  }

  private static function byteArray(bytes: Array<UInt>): ByteArray
  {
    var array = new ByteArray();
    for (byte in bytes)
      array.writeByte(byte);

    return array;
  }

  // "raw" Erlang values
  public function testEncodeAtom()
  {
    assertEquals(
      str(BERT.encode(BERT.atom('bert'))),
      '[131,100,0,4,98,101,114,116]');
  }

  public function testDecodeAtom()
  {
    assertEquals(
      Std.string(BERT.decode(byteArray([131,100,0,4,98,101,114,116]), true)),
      Std.string(BERT.atom('bert')));
  }

  public function testEncodeFloat()
  {
    assertEquals(
      str(BERT.encode(1.3)),
      '[131,70,63,244,204,204,204,204,204,205]');
  }

  public function testDecodeFloat()
  {
    assertEquals(
      BERT.decode(byteArray([131,70,63,244,204,204,204,204,204,205]), true),
      1.3);
  }

  public function testDecodeOldFloat()
  {
    assertEquals(
      BERT.decode(byteArray([131, 99, 52, 46, 50, 53, 48, 48, 48, 48,
      48,48,48,48,48,48,48,48,48,48,48,48,48,48,101,43,48,48,49,0,0,0,0]), true),
      42.5);
  }

  public function testEncodeSmallInt()
  {
    assertEquals(
      str(BERT.encode(42)),
      '[131,97,42]');
  }

  public function testDecodeSmallInt()
  {
    assertEquals(
      BERT.decode(byteArray([131,97,17]), false),
      17);
  }

  public function testEncodeLargeInt()
  {
    assertEquals(
      str(BERT.encode(-56323)),
      '[131,98,255,255,35,253]');
  }

  public function testDecodeLargeInt()
  {
    assertEquals(
      BERT.decode(byteArray([131,98,0,11,138,7]), true),
      756231);
  }

  public function testEncodeString()
  {
    assertEquals(
      str(BERT.encode('string')),
      '[131,107,0,6,115,116,114,105,110,103]');
  }

  public function testDecodeString()
  {
    assertEquals(
      BERT.decode(byteArray([131,107,0,6,115,116,114,105,110,103]), true),
      'string');
  }

  public function testEncodeBinary()
  {
    assertEquals(
      str(BERT.encode(BERT.binary([234,35,67]))),
      '[131,109,0,0,0,3,234,35,67]');
  }

  public function testDecodeBinary()
  {
    assertEquals(
      Std.string(BERT.decode(byteArray([131,109,0,0,0,3,234,35,67]), true)),
      Std.string(BERT.binary([234,35,67])));
  }

  public function testEncodeTuple()
  {
    assertEquals(
      str(BERT.encode(BERT.tuple([1, 'second', -50000]))),
      '[131,104,3,97,1,107,0,6,115,101,99,111,110,100,98,255,255,60,176]');
  }

  public function testDecodeTuple()
  {
    assertEquals(
      Std.string(BERT.decode(byteArray([131, 104, 3, 97, 1, 107, 0, 6, 115, 101,
      99,111,110,100,98,255,255,60,176]), true)),
      Std.string(BERT.tuple([1, 'second', -50000])));
  }

  public function testEncodeList()
  {
    assertEquals(
      str(BERT.encode(['haXe', 'Erlang', 2011])),
      '[131,108,0,0,0,3,107,0,4,104,97,88,101,107,0,6,69,114,108,97,110,103,98,0,0,7,219,106]');
  }

  public function testDecodeList()
  {
    assertEquals(
      Std.string(BERT.decode(byteArray([131, 108, 0, 0, 0, 3, 107, 0, 4, 104, 97,
      88,101,107,0,6,69,114,108,97,110,103,98,0,0,7,219,106]), true)),
      Std.string(['haXe', 'Erlang', 2011]));
  }

  // BERT values
  public function testEncodeNull()
  {
    assertEquals(
      str(BERT.encode(null)),
      '[131,104,2,100,0,4,98,101,114,116,100,0,3,110,105,108]'); // {bert, nil}
  }

  public function testDecodeNull()
  {
    assertEquals(
      BERT.decode(byteArray([131,104,2,100,0,4,98,101,114,116,100,0,3,
      110,105,108])),
      null);
  }

  public function testEncodeBool()
  {
    assertEquals(
      str(BERT.encode(true)),
      '[131,104,2,100,0,4,98,101,114,116,100,0,4,116,114,117,101]'); // {bert, true}
  }

  public function testDecodeBool()
  {
    assertEquals(
      BERT.decode(byteArray([131,104,2,100,0,4,98,101,114,116,100,0,5,
      102,97,108,115,101])), // {bert, false}
      false);
  }

  public function testComplex()
  {
    var complexObj = { a: 3.5, b: [100, -32000, { x:'hello' } ], c: true };
    var decodedObj = BERT.decode(BERT.encode(complexObj));
    assertTrue(decodedObj.a == 3.5 && decodedObj.c == true && decodedObj.b[2].x == 'hello');
  }
}