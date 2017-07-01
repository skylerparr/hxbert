hxbert
======

haXe implementation of the [BERT] protocol.

COPIED AND CREDIT GOES TO
=========================

[https://bitbucket.org/oneclick/hxbert]

Forked to add support for all platforms and I have a specific use for it.

Usage
-----

<code>org.hxbert.**BERT**.encode(obj: **Dynamic**): flash.utils.**ByteArray**</code>
>Encode a haXe object into BERT, return a ByteArray. The obj can be almost anything.

<code>org.hxbert.**BERT**.decode(val: flash.utils.**ByteArray**, ?raw: **Bool** = **false**): **Dynamic**</code>
>Decode a BERT encoded bytes into a haXe object.

<code>org.hxbert.**BERT**.atom(val: **String**): org.hxbert.**ErlangValue**</code>
>Create a haXe object that will be encoded to an Atom.


<code>org.hxbert.**BERT**.binary(val: **Dynamic**): org.hxbert.**ErlangValue**</code>
>Create a haXe object that will be encoded to an Binary. val must be String or Array<UInt>.

<code>org.hxbert.**BERT**.tuple(val: **Array**<**Dynamic**>): org.hxbert.**ErlangValue**</code>
>Create a haXe object that will be encoded to a Tuple.

  [BERT]: http://bert-rpc.org/

