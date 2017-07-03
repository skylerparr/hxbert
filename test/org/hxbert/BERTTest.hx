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

    @Test
    public function testDecodeString() {
        Assert.areEqual(
            BERT.decode(arrayToBytes([131, 107, 0, 6, 115, 116, 114, 105, 110, 103]), true),
            'string');
    }

    @Test
    public function testEncodeBinary() {
        Assert.areEqual(
            str(BERT.encode(BERT.binary([234, 35, 67]))),
            '<<131,109,0,0,0,3,234,35,67>>');
    }

    @Test
    public function testDecodeBinary() {
        Assert.areEqual(
            Std.string(BERT.decode(arrayToBytes([131, 109, 0, 0, 0, 3, 234, 35, 67]), true)),
            Std.string(BERT.binary([234, 35, 67])));
    }

    @Test
    public function testEncodeTuple() {
        Assert.areEqual(
            str(BERT.encode(BERT.tuple([1, 'second', -50000]))),
            '<<131,104,3,97,1,107,0,6,115,101,99,111,110,100,98,255,255,60,176>>');
    }

    @Test
    public function testDecodeTuple() {
        Assert.areEqual(
            Std.string(BERT.decode(arrayToBytes([131, 104, 3, 97, 1, 107, 0, 6, 115, 101,
            99, 111, 110, 100, 98, 255, 255, 60, 176]), true)),
            Std.string(BERT.tuple([1, 'second', -50000])));
    }

    @Test
    public function testEncodeList() {
        Assert.areEqual(
            str(BERT.encode(['haXe', 'Erlang', 2011])),
            '<<131,108,0,0,0,3,107,0,4,104,97,88,101,107,0,6,69,114,108,97,110,103,98,0,0,7,219,106>>');
    }

    @Test
    public function testEncodeZeroLengthList() {
        Assert.areEqual(
            str(BERT.encode([])),
            '<<131,108,0,0,0,0,106>>');
    }

    @Test
    public function testDecodeList() {
        Assert.areEqual(
            Std.string(BERT.decode(arrayToBytes([131, 108, 0, 0, 0, 3, 107, 0, 4, 104, 97,
            88, 101, 107, 0, 6, 69, 114, 108, 97, 110, 103, 98, 0, 0, 7, 219, 106]), true)),
            Std.string(['haXe', 'Erlang', 2011]));
    }

    @Test
    public function testEncodeNull() {
        Assert.areEqual(
            str(BERT.encode(null)),
            '<<131,104,2,100,0,4,98,101,114,116,100,0,3,110,105,108>>'); // {bert, nil}
    }

    @Test
    public function testDecodeNull() {
        Assert.areEqual(
            BERT.decode(arrayToBytes([131, 104, 2, 100, 0, 4, 98, 101, 114, 116, 100, 0, 3,
            110, 105, 108])),
            null);
    }

    @Test
    public function testEncodeBool() {
        Assert.areEqual(
            str(BERT.encode(true)),
            '<<131,104,2,100,0,4,98,101,114,116,100,0,4,116,114,117,101>>'); // {bert, true}
    }

    @Test
    public function testDecodeBool() {
        Assert.areEqual(
            BERT.decode(arrayToBytes([131, 104, 2, 100, 0, 4, 98, 101, 114, 116, 100, 0, 5,
            102, 97, 108, 115, 101])), // {bert, false}
            false);
    }

    @Test
    public function testComplex() {
        var array: Array<Dynamic> = [100, -32000, { x:'hello' } ];
        var complexObj: Dynamic = { a: 3.5, b: array, c: true };
        var decodedObj = BERT.decode(BERT.encode(complexObj));
        Assert.isTrue(decodedObj.a == 3.5 && decodedObj.c == true && decodedObj.b[2].x == 'hello');
    }

    private function arrayToBytes(ba:Array<Int>):Bytes {
        var bytes:Bytes = Bytes.alloc(ba.length);
        for (i in 0...ba.length) {
            bytes.set(i, ba[i]);
        }
        return bytes;
    }
}