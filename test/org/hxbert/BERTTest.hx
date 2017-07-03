package org.hxbert;

import haxe.io.Bytes;
import org.hxbert.BERT;
import massive.munit.Assert;


class BERTTest {

  public function new() {

  }

  private static function str(byteArray:Bytes):String {
    var i:Int = 0;
    var arr:Array<String> = [];
    for (i in 0...byteArray.length) {
      arr.push(Std.string(byteArray.get(i)));
    }

    return '<<' + arr.join(",") + '>>';
  }

  @Test
  public function shouldEncodeAtom():Void {
    Assert.areEqual(
      str(BERT.encode(BERT.atom('bert'))),
      '<<131,100,0,4,98,101,114,116>>');
  }

  @Test
  public function testDecodeAtom() {
    var ba:Array<Int> = [131, 100, 0, 4, 98, 101, 114, 116];

    Assert.areEqual(
      Std.string(BERT.decode(arrayToBytes(ba), true)),
      Std.string(BERT.atom('bert')));
  }

  @Test
  public function testEncodeFloat() {
    Assert.areEqual(
      str(BERT.encode(1.3)),
      '<<131,70,63,244,204,204,204,204,204,205>>');
  }

  @Test
  public function testDecodeFloat() {
    Assert.areEqual(
      BERT.decode(arrayToBytes([131, 70, 63, 244, 204, 204, 204, 204, 204, 205]), true),
      1.3);
  }
//
//  @Test
//  public function testDecodeOldFloat() {
//    Assert.areEqual(
//      BERT.decode(arrayToBytes([131, 99, 52, 46, 50, 53, 48, 48, 48, 48,
//      48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 101, 43, 48, 48, 49, 0, 0, 0, 0]), true),
//      42.5);
//  }

  @Test
  public function testEncodeSmallInt() {
    Assert.areEqual(
      str(BERT.encode(42)),
      '<<131,97,42>>');
  }

  @Test
  public function testDecodeSmallInt() {
    Assert.areEqual(
      BERT.decode(arrayToBytes([131, 97, 17]), false),
      17);
  }

  @Test
  public function testEncodeLargeInt() {
    Assert.areEqual(
      str(BERT.encode(-56323)),
      '<<131,98,255,255,35,253>>');
  }

  @Test
  public function testDecodeLargeInt() {
    Assert.areEqual(
      BERT.decode(arrayToBytes([131, 98, 0, 11, 138, 7]), true),
      756231);
  }

  @Test
  public function testEncodeString() {
    Assert.areEqual(
      str(BERT.encode('string')),
      '<<131,107,0,6,115,116,114,105,110,103>>');
  }

  private function arrayToBytes(ba:Array<Int>):Bytes {
    var bytes:Bytes = Bytes.alloc(ba.length);
    for (i in 0...ba.length) {
      bytes.set(i, ba[i]);
    }
    return bytes;
  }
}