


module.exports = (robot) ->

  fromCharCode = String.fromCharCode
  CHARACTERS ='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  INVALID_CHARACTERS = /[^a-z\d\+\=\/]/ig
  CHARMAP = {}
  CHARMAP[char] = i for char, i in CHARACTERS.split('')

  class InvalidSequenceError extends Error
    name: 'InvalidSequence'
    constructor: (char) ->
      if char
        @message = """"#{char}" is an invalid Base64 character"""
      else
        @message = 'Invalid bytes sequence'

  encode = @btoa ?= (input) ->
    output = ''
    i = 0

    while i < input.length

      chr1 = input.charCodeAt(i++)
      chr2 = input.charCodeAt(i++)
      chr3 = input.charCodeAt(i++)

      if invalidChar = Math.max(chr1, chr2, chr3) > 0xFF
        throw new InvalidSequenceError(invalidChar)

      enc1 = chr1 >> 2
      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
      enc4 = chr3 & 63

      if isNaN(chr2)
        enc3 = enc4 = 64
      else if isNaN(chr3)
        enc4 = 64

      for char in [ enc1, enc2, enc3, enc4 ]
        output += CHARACTERS.charAt(char)

    output

  decode = @atob ?= (input) ->
    output = ''
    i = 0
    length = input.length

    throw new InvalidSequenceError if length % 4

    while i < length

      enc1 = CHARMAP[input.charAt(i++)]
      enc2 = CHARMAP[input.charAt(i++)]
      enc3 = CHARMAP[input.charAt(i++)]
      enc4 = CHARMAP[input.charAt(i++)]

      chr1 = (enc1 << 2) | (enc2 >> 4)
      chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
      chr3 = ((enc3 & 3) << 6) | enc4

      output += fromCharCode(chr1)

      if enc3 != 64
        output += fromCharCode(chr2)

      if enc4 != 64
        output += fromCharCode(chr3)

    output

  unpack = (utfstring) ->
    utfstring = utfstring.replace(/\r\n/g, '\n')
    string = ''

    for i in [0 .. utfstring.length-1]
      c = utfstring.charCodeAt(i)

      if c < 128
        string += fromCharCode(c)
      else if c > 127 and c < 2048
        string += fromCharCode((c >> 6) | 192)
        string += fromCharCode((c & 63) | 128)
      else
        string += fromCharCode((c >> 12) | 224)
        string += fromCharCode(((c >> 6) & 63) | 128)
        string += fromCharCode((c & 63) | 128)

    string

  pack = (string) ->
    utfstring = ''
    i = c = c1 = c2 = 0

    while i < string.length

      c = string.charCodeAt(i)

      if c < 128
        utfstring += fromCharCode(c)
        i++
      else if (c > 191) && (c < 224)
        c2 = string.charCodeAt(i+1)
        utfstring += fromCharCode(((c & 31) << 6) | (c2 & 63))
        i += 2
      else
        c2 = string.charCodeAt(i+1)
        c3 = string.charCodeAt(i+2)
        utfstring += fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63))
        i += 3

    utfstring

  robot.Base64 =
    encode64: (str) -> encode(unpack(str))
    decode64: (str) -> pack(decode(str.replace(INVALID_CHARACTERS, '')))

  greetings = [
    "check out this cool video I found",
    "you owe him something!!!!!",
    "THIS AD IS SPONSORED BY PORNHUB INC",
    "I dare you, I double dare you, watch this: ",
    "speaking of which, I found this: ",
    "most of the time I wonder why I love this dude so much: "
  ]

  urls = [
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9oYi14R3h1Y0w0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTd1UFBWOUF3VENz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFhRnk5ekVHbHdF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU9qMlI0c3lrZ0ZV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWFmSHoyZEx2MVRN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUJubzkyaWhpSFpZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNNeE1uY1V2RnV3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV8xWXF0WWhDazFz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZ2bF9IdGtVWVpF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhtdFgyVzdhN1B3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUQ3UjhzM3BJRXdN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTVLZl9JSHBXbWdN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1LVlllWXg0aV9r',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUxwQzJtRVlhWVRv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUlncjhTV0Fja1Fj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTY3Rnd5dGtGdmhr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1LSEJNV1JyaVJj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThpeG1yUlI4ZXh3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTU5RXdRQUZfRWlF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTI3WVVNN3kwQ0xv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWtwQUprWVFBaVg4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWFYVXBDZ0duU2FF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtfbFVmR0F5MkxB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWdqcDNrMjQ5NnRB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1mNGJzUzFmS0RV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVU1OC0xbjdueldB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWlRMFVCOFgyTFNJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXVmUThHVXowTUZv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVFNZTJOQ0JoSmJj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUo4b19xdTVpVUxv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUQyRjY5NktQeDd3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXhHbnM2TEtrTkFN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXlLT1h2NnNHeTNB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZwZEtkbmlTRVRJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNZeGF3NXlFbW9j',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVIwNEJiNDZRUkFj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWVtVU01angtOHZz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThrS0g5bjh3QVBn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFXNTR4N2pCSkVN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTItTmt0U19fMHVJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTdQQ3A3MUpTTTA4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTlibm5aRkJFZWlF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTIxOEdoQU5iMVZ3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJvbXpPUzdxbkE0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWdqWU1tVEluc1Vj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUczS09uSXBocVBz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVB2QWJXcHFyWUhR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVZ3eUZPNUxLMXQ0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURiUEd3amZMN3VF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTgtVG55QWJSVnVV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXJsLVJYOUg1Rk5n',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWN4Z1pXTkVXWlg4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUN1cjdHSVdBRmhZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXg5Ui0zUjZTZ3Rr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTk1QVdlYWFoSV9N',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFBdGRscG9pdlJR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVZaNDhhaEFneS1J',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTBNNm9pLUIxaVJv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFMVnNIUGtXM0Ew',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9rV21lb2tabzFZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhPc2Z5dWVib1dZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUdFN2E1N0Zzbkx3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtQbGt3TkNiT1lB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUcxU1NGVUFSN0ln',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU4tWk9MQm9CN0JV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUxuVTY1M2t1cUJZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVFGMWJpdGJIY084',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXExZHBsR1BlRW13',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWdTSF8tcUMyYkpV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXBEeEF0cGhWeWRF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUE3enJmaExnRUR3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1xX0JteHZSbnpB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVRaWkZYTnp5aTM0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWRaSVNxbF85Wk5j',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWNtVWZNSzlmMWVr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXVxUEJUd1hzWjJZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTk2NEd5bGFHMU1R',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXE3VUR3UUx3UTkw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVdERW9ybDVpb293',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhqYUpSdXo4a0Nv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThVbDVLWHMxZ0FJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVpJeGxSRm1INVVz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtKTThlQkFxenpJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1kcFhhc1Jwa2VJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXRyOFM5Z3owTHJR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVlhRHBPRDYzaDU4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVBGeHdVVWFWS2o0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNEbkpFc3MxSFcw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVZUY21BQTBFMUpv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWY2Vmk0UENKTUNn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTBMSG44YjdMTlk4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVdXdDNYMFEwcEd3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURvYTBsM3Bkc05N',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXEteG5lNGFRc0lv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZvU2U1VTF3RDEw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUdzOTRoTF9lbmE4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTBNekIzTlRYcEhr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhsbTVzYkhUSXNn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThwMk1SbEU2VWxZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWlqNzZCQU1vR1ow',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXc5WVFjYzlwT2w4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXR5dGpTTHg3ZGF3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWZWcnNWV1MxNXBF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUpnbVB2eUg5a2Nr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVk3eDk3M2tNYkdJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1VSE1RazFwSGxJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZYQWQ4bmk0dnlZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWpnNFpZUnZtWU0w',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNyQ0Ztc0EycldV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFmQVRHMUsxSk9N',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXdHa0RITk5VS3Nr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZ0WGxoOVdaaE44',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWRzdGpaMFlLb0pz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXJFN0JORzN3czI0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVFjUFBpNDZiMWlr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXhBaWtWNHBwcU5V',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJUaDB3Y3E0MDY4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9TaHhJQ2poU3c4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUgxNDRoVWg5WDZj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUFBc2RfcmZIeHJJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXV4enRreUxIc0ww',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTdKV1A4RGozeFFz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVZkT0xmazF1VWFN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXo5T2U5anBjT0FN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1NTWdmXzJyN0E0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTA5OHZHYXhlUXVj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW8wQ2I3RHJQdnVJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9KTmRUMDhKY01n',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWdYRHRjLTNGbzBB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtYdHp2R1ZxZll3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVRibmpvblppZTh3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWIxY01vZUVfc2Zz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXRMbmZjaGhuNElN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWFQY3ZNZnV4U1Bv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUhXMTBVY0xyQTRN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUt5UDdvOUdMQUpR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU0tQlB3UDc4Nmtv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVY4RUw1bkloM1ZJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9DajY0Z0hDWkFV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTdJazdsNjh6SVZv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNCTTFwX1pZWXJ3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRibnltS3FxUU9B',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVdqcW5lZ3pIRmNr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1KQnR3Y0FGaENB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVFJV3J3UzNrREdZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRnTlo5dnh4Y0tv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWh2TUdEbzdJdEtB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWN0d2UyLVh0N3Rj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTJmUG5wNmtodklV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVVOQWhPUXBxLUtz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXl2UlhPRHJ5aElr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXhydVZqTkVZbks0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW5qbTI5WEJTcFM4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUxXamNGSWdNUi1F',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJkaGhmenJ2TXdR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZzU1dGWWhncTg4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1za1hKOFVjQ1lR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWpjSUNSc3A5N0Yw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWxsQ1ZQZjRTRTRN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWR5RkxHOVBSelk0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFWZkJqVy02SDhV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhFQ090YUo1QW9Z',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXdBa1B6NTUzZXp3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFqeW4tczJBeV9B',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1IVk5jUVNHSlpR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV8yUGZUc0pIMUJr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1XcWNOa3VkS0RZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUVBdVNFV0lMaWtn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTcxVVduOUhYODJ3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVVCa3E2NmtNdGRv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUhWSUZoOXFlcmhR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXBoVzNLZ2h1Z3hF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXlla2VqOUhEb0k0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhfb1pfbFBuMVNj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVNfcDBPT0NoOGJV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUxpMW5jMlNGRENF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXV2aThWLWN5UW9j',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUFISTV5VDNIWjRz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUVyM3VFOFFkbTZF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUlrMnY5S1REUHgw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVFTNGswakh3dGhF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRKcHJ4c21wa29V',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRHT0FLSGc1TUg4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZMSEI0dHZwUWkw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWt3ZXA1N2lSbzRZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVlnTEwwaFhxcGFR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhOQzBObk5UWkJn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTV3N01xYWp6bXVJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1oR2NtSFhuZnRz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVRLV29EYUZxcXpZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXRmQzFTQU4yNHBN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW80WTk1U0hEWl80',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1aSE1abnQzV1B3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUgxZVRlbDFPLUxv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXJsaXgxUDA4Zk5v',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUJ5RXVZVXlCY2Y0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFqc3Q2aktEODBj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVNJYTUwUFF4c2lB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTd6X3pDc2s0aE1r',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1GRmhhTzRSZEtF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1FMkxsWjBJNWpv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUt5RVFtTjM1MHA0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTBFaHduRmIxazBZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZlMk5qMXRBZXpF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXV5U213ZjRoemZN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhnN0ljMVN6MjJF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNFRGs2Y1ZmUlQ0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTA4cFM3SXh1b1ZV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWctVmxsOWpvekVn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVktcU1nMHp6MTg0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFTMEsxbGlIREhv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW5UTHRJamNJVXB3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXN0bXpPMnJ5MUp3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTd1QkI3VG9DNUpv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURERjVxUDc0SG13',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWVoamNNc0RMYS1j',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWp0b1RtVDMydHJN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWl5Q21JWnBKTmxv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXJnYXB4aHhLeWtj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1MN0k2MzdEdXlF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWF1Y21HVWl4WGkw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTlOZk9RejBrMUlv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWQ2UHN3WV85eHpj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1RZVZITGNONjZz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFiRkNkVXROOFlZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVBMWnRoaU01Unlv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU12Q2k1WUZaOU9n',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNWQmd2aDlpQnRJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTJ5dkFOQkYtMjRF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVpCeDE5cjdzdTlZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUJhc3NQMGZIRlUw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVpDbmlSVGhrSVdF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9Ld3NBU0NXamlJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtiM0M1eWlQam0w',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUhXOUdnUzAxeWFR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU95RUxBd0JZVXJF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURQemxVbGpFdGNV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhVcXJTVGJsd1Q4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWlfUU5SZWw4RHlZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXpJcHkyWm9pdWVn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRaa3c0RTR0akJv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtTZ09WY3RDX3pJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXgweUZ4bWxMbHl3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVd5aVBremVaQ3Nr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWN1UEVPWnlUTzhV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXEyZGZTZUNPR0hB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVdCbnM4a0RpYVZj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVJqRzBLODFwcnhB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVNmWnZSM0gtdmVJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXBBLTE1SnZJUHFv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTVJUi1oVUhndE5F',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXh2ZjlfeU4tdG1J',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWRleDA5SE9LSFhn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFubW5BR0pFc2h3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTJZQktzRmtjSWNZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTlrdjZQUGRiYzNj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUhRcjhoUURmOW5F',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVJQb3AwdUdlUzcw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU50c21QYUhrWnZV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURILU80clFwWVRB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTlJUGFXVXAwdWlJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVdXVlNQazFKNUVv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWtNREtwTm5mUUZn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXZnLU5GdkhXYlBn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWtDcWdYdUxEbG5N',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUw2Z0hQMjlfZWow',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWNVX0V6WHhMNXpJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVI3d3ZhMnAtSjFn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUVSM1FGdWVrZHVJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVMzWXRLZHA1Qkcw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTJFSmhEUFBQUWZj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1oUl95Wlh3RC1v',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZYS2k5QlZZODU0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUpIY3hMX1dJdGRZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVJyS3I2Y1BtVUZv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1lRk8xVkJRVHZn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUtjakI2aHp6VnJv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVNJZDBRQzNwRjdJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWZscThoOWd5Zm5B',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWpWdjFmSlhXcmJr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNrQ0ZRMlB3MThB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThlc19aRXlOM24w',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU5ZMnkwTzJmWUpV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUlGYTItTlBDUWtZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU40cFpNVFRCQXJB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXUyWnpDdVlya1NZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUxScTlieU5fZmRR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTktaHdzQkpTdXBv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTlFNEEtaWZIal9v',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTdESW1MRlJDcTFj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUE0b1FVOXNkeXVV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVpuWUFGZ0V6eTcw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWw4Mi1NcG1MVjl3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVEyU2ZzLVhnd3ow',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PS1LWF9QNDlVSlFF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9DUU12TDZ0Ujdj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVpKbEVqbXBEaGxJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVVUNnVNQ1Z2dmlF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVBGYkhlZDV4N1c0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWV3OS05R1ktaFc4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXh6VS1RcVpzQU1j',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWVNclpnaHVIdkFJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXdabGV3bTFBRndr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNQT3dmdUcyREg0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUF4Yl9EM3UtdVlF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXlESG5teFdMSXNV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTNlbktiSEdjY0xF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVp2cVhITmdzNkxn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVp5Tm0wMFpWclRz',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJOMkE4eU9DNzIw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU05RS02bG9OWnBr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNUNzdLVjVoQlpF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZPN1Frdmxpcmdn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXRGUzVOZThOVGcw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUo4ZXFEVlVFRnMw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUZ0eFBxNmR2TWF3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWY0aHR3MjMxRjVR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXc5RTdwTDIzV2ZB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWlYRWVTOVJYSXg4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTBFRzJ3N09ydU1n',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVItWEVVVEs3V1Aw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJ0d0tLRlIzMWhv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVhrbFNHOThvOEpr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWtXbkNVV29mN2dB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXhSY09yUS1NSmY4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1Fekcwem1WUTJZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVBBTFA0clZJbXdj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWZ6QndmbUtWZkxR',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVNTODhfNTlwT2w0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXkya085RHh6UkVj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWgtZGlKNHdTWkZn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWYwVWNmNVlVWFE4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJIbEoxdGxnc25n',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVJTZ2JuSkZJZi04',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PV9fYWNoZFR5M3dZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFNd2JpOTkwMUNF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXFMWHdzNGh3aURF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVJ5cWhhLUFwZlE0',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWItd1NTRmtaZXln',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1mN3hZOUVkTFFv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1zbGd3MGNhZkdj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW92VVkwcUJJdVd3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUVxZ2hyeHpoWkxv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW1fVWtHcnMzelFB',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWR2RUl6ZXQtNGFZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXNBT2V0UE5PYWdF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXhIZ2JVemM2aTBj',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWlMSThWcmkzQVdJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU05bk9Ic01aT0NV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PVRKOWpUeXVxOVRN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTVMVEZGMy1WUE00',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUJha1pSNnYtQU5F',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTFxbllWS0VfN1hr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXA0THZjdnB4Nk9z',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PThKX08ybGdTTmtZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWtwbUplT21RX2ZN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXpqLVJtTEt6VzMw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTZLRmgzV01Rd0s4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUEyUmowZl95a1Yw',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWJtdEIwMHhUa3pv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWpWbzFEUEl0dnB3',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXRKTW9XZEdFSmVr',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTRkTUhDRXNvaXlN',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUNnOGJxT3ozM2NV',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PW9YaEtYdDVFQ1dZ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PU1heTFZcDBzcjJJ',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWZtRW8xUGtxRklv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUhtVmVaMUxlS1Y4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXN3dEJtN2ZmbEJv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PURJVERDUVpVNHZF',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUdoajV1TGFkZXk4',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PUdpTVRDb2daV29z',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PWhza05FWmFYemVn',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PXBpN000NGlxdkRv',
    'aHR0cDovL3lvdXR1YmUuY29tLy93YXRjaD92PTkwallCa2xRaUh3'
  ]

  robot.hear /(nahom|vankash)/i, (msg) ->
    msg.send "Hey @vankash, #{msg.random(greetings)} #{robot.Base64.decode64(msg.random(urls))}"
