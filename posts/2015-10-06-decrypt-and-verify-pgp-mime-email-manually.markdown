---
layout: post
title:  Manually decrypt and/or verify PGP/MIME email
date:   2015-10-06 22:10:00
tags:   
- tips
- gpg
---

With gpg email client plugin like GPGMail, you can easily send encrypted and signed email. Of course, plugin like GPGMail also decrypts and verifies email signature for you automatically. GPGMail use the *offical* standard way PGP/MIME ([rfc3156](http://tools.ietf.org/html/rfc3156)) to send OpenGPG encrypted and signed emails. What if you received encrypted/signed email in PGP/MIME format while your email client or gpg plugin does not support PGP/Mime? For signed emails, you cannot verify the signature but you can still see the content. For encrypted emails, you get two attachments. I will show you how to decrypt and verify them with only `gpg` command and a text editor. 

## Signed Email ##

First you need to download the source of the signed email. In Apple Mail just click menu File -> Save As to save the message as raw message source.  In Outlook.com email web interface, right click the message on the email from the left column, and click `View message source`, and then manually copy the content to a text file. 

Open the saved the message source file in any text editor, search for "multipart/signed" and delete any lines before this line as we don't need these headers. Then we got something like the following:

    
    1 Content-Type: multipart/signed;
    2 	boundary="Apple-Mail=_7A110488-625C-4A1B-84AC-2F9F6F5BC49F";
    3 	protocol="application/pgp-signature"; micalg=pgp-sha512
    4 Subject: test sign
    5 Date: Mon, 5 Oct 2015 06:03:34 +0800
    6 Message-ID: <95DAF25D-0323-4ECA-8F3B-98D63E4C2327@icloud.com>
    7 To: Crane Jin <xxxx@xxxx..com>
    8 MIME-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
    9 X-Mailer: Apple Mail (2.3094)
    10 Return-Path: xxxx@xxxx.com
    11 X-OriginalArrivalTime: 04 Oct 2015 22:04:02.0543 (UTC) FILETIME=[942E8FF0:01D0FEF0]
    12 
    13 --Apple-Mail=_7A110488-625C-4A1B-84AC-2F9F6F5BC49F
    14 Content-Transfer-Encoding: 7bit
    15 Content-Type: text/plain;
    16 	charset=us-ascii
    17 
    18 singed message
    19 
    20 --Apple-Mail=_7A110488-625C-4A1B-84AC-2F9F6F5BC49F
    21 Content-Transfer-Encoding: 7bit
    22 Content-Disposition: attachment; filename="signature.asc"
    23 Content-Type: application/pgp-signature; name="signature.asc"
    24 Content-Description: Message signed with OpenPGP using GPGMail
    25 
    26 -----BEGIN PGP SIGNATURE-----
    27 
    28 iQIcBAEBCgAGBQJWEaJGAAoJENI21RduwrDCy04QALctCwg6epM2MVb5GtlNus7p
    29 sNr0zWnZQLHcDIAnAqqcS3yId1doYLok6YHGuVZQ4TwJ6XwtswC+QS8DBqaRsWC7
    30 RckPSbb0EK47OK4DdlmDvZnYEB+jPunPqhYCEAvyv85394J0RdkSb+P7bV/IEmNd
    31 suiFT5zt/U+aW2DQpug1ianM7GrOB1eLYLIeAexNql4mDSrRnBxRcPQq8bu3A93q
    32 ukwXJCdeNRPG0aPez6x0wvQi4Zn/Uh0gFwe7rtHzxSSatlxEPRuVGx1eHK6g/8+p
    33 J99S88KriSe2R4XGuRCUMiHhPzDSAYuEbqfc4tMmEKzvzx0dAFhcCIYmtVeoKwol
    34 Q3DBCdSk1+jDmW70N8eS1U/X7mlE8PmZ0i1MyR5XH0qDodx9EEF0phiBJG79E0u9
    35 UTvdYjv3BsK3YpDRK/HdJ8oPMntH+MtDJw8gC9P7oFBsTzKTqe4PJ8tcsBBAMD+C
    36 ZmJd/FvoiejksfgayxBfAUCNphewOoLwEzFXccTi95/c1MJ5kjhTr75cT0/zfyoL
    37 BRtxhQSdyjZsI0m6BYP7z1R8jLDufmguy3boWW6riaRYvvyGISg1PT2qjDJkY5Sr
    38 23WAdFDYltPHbDUzatA6UUh4jDcJpnSyAC4/NgNooAjyJt4cqCi5Cw5bRX2YCjOt
    39 CjV4RBDbKRbx4y0doRSy
    40 =qHUN
    41 -----END PGP SIGNATURE-----
    42 
    43 --Apple-Mail=_7A110488-625C-4A1B-84AC-2F9F6F5BC49F--
   
The email message consists of two parts: line 14 ~ 18 is what has been signed (note do not include the tail blank line), line 26 ~ 41 is the signature. Save these two parts as separate files, for example, `message.txt` and `signature.asc`.  Now you may already know how to do the rest:

    gpg --verify signature.asc message.txt

## Encrypted and Signed Email ##
For this one, we use a more complicated example. Say the email you received has an attachment and a body, and the email was signed by sender and then encrypted to you. As I mentioned at the beginning, for this case you will see the email message as two attachments and no content in the body. If the email was sent by GPGMail, the two attachments will be named as "Mail Attachment" and "encrypted.asc" which you can clearly know "encrypted.asc" is what we need. Actually, "Mail Attachment" is just a plain text
file which contains only one line "Version 1". If you received a message that was not sent by GPGMail and did not follow the name convention, you can determine which attachment should be used by examine the contents of them. 

If you open "encrypted.asc" with a text editor, you will see that it's just a armored gpg encrypted message which begins with "----BEGIN PGP MESSAGE----" and ends with "----END PGP MESSAGE----". First, we need to decrypt it:

    gpg -o decrypted -d encrypted.asc

Open decrypted in text editor, we got something like the following:

    1 Content-Type: multipart/signed;
    2 	boundary="Apple-Mail=_61F7F512-9AAD-4F60-9462-F35CCAC90ED1";
    3 	protocol="application/pgp-signature";
    4 	micalg=pgp-sha512
    5 
    6 
    7 --Apple-Mail=_61F7F512-9AAD-4F60-9462-F35CCAC90ED1
    8 Content-Type: multipart/mixed;
    9 	boundary="Apple-Mail=_91F869CE-76D7-415D-B847-2CAC206A4328"
    10 
    11 
    12 --Apple-Mail=_91F869CE-76D7-415D-B847-2CAC206A4328
    13 Content-Disposition: attachment;
    14 	filename=pbencrypt.sh
    15 Content-Type: application/octet-stream;
    16 	name="pbencrypt.sh"
    17 Content-Transfer-Encoding: 7bit
    18 
    19 echo recipient: $1
    20 pbpaste | gpg -a -u 0x6EC2B0C2 -r $1 -s -e | pbcopy
    21 
    22 
    23 --Apple-Mail=_91F869CE-76D7-415D-B847-2CAC206A4328
    24 Content-Transfer-Encoding: 7bit
    25 Content-Type: text/plain;
    26 	charset=us-ascii
    27 
    28 
    29 
    30 Hello, here is the script attached.
    31 --Apple-Mail=_91F869CE-76D7-415D-B847-2CAC206A4328--
    32 
    33 --Apple-Mail=_61F7F512-9AAD-4F60-9462-F35CCAC90ED1
    34 Content-Transfer-Encoding: 7bit
    35 Content-Disposition: attachment;
    36 	filename=signature.asc
    37 Content-Type: application/pgp-signature;
    38 	name=signature.asc
    39 Content-Description: Message signed with OpenPGP using GPGMail
    40 
    41 -----BEGIN PGP SIGNATURE-----
    42 
    43 iQIcBAEBCgAGBQJWESerAAoJENI21RduwrDCZDQQAMb9mBKrI67/+L5QeuMZBdod
    44 NnByIKAjs+D1CvJLXt7vzli9cLguXUgHQCxZ9Af6h5VqF6u6BHQ66thW4VKH1YjU
    45 xeutLIdFUqoQBXhqPRz4Uutd8UBLcUs9JJRPP9QFiThsICBjVLr/fDHMgQyBY9lY
    46 cfOTJAIz+E2wVc9EluSizpEKe7KwqaSe5JtHSFvr7UeL0OHr5MOz02hW9zZpDD+x
    47 z1bbTxZ3XlUvvW65+fueF5jJQlZtydHdcyft7ZYP5ejL85hm7htxtA5yyDQpdRaC
    48 AukRNYSV4A9InmlHujjENKPs/yIZq23pc1j0am2TpMcM6EpDt7B3tdXK+dxlLlfB
    49 6XaZVsH5M1Q6FYN+ZCP4B6USosm5n6keofAEMaoERbyaSH3ZUgjlHQ5KHsXxPyyw
    50 fQ5pEy4XfIT6YMsNsDqxLtgM6B4dQXlRUfNXjlCXPvzgWbzt7Vt7m2UaUvuFzzRY
    51 Fkq2ofL+jF3AS72BiBeImw/16JfbBYMDqKjPeFoOHrF1QZJD6nw9i5pahGtT/4IP
    52 9V/BCWakh201blLPMqXRyPk46+MWK1y0847CEMp72f/j+4ywNQlFxjdg0HwPgASv
    53 AVd8Kas3YEQuwGg+HC4p8QA6p2R9w6A9UucRRZXgTG9hvUu6NJ1RUJEMti6DoUOU
    54 EyqMl3l93rObwU28H+bl
    55 =lmU2
    56 -----END PGP SIGNATURE-----
    57 
    58 --Apple-Mail=_61F7F512-9AAD-4F60-9462-F35CCAC90ED1--
   
It's similar as the example we used in previous section **Signed Email**.  The boundary string used to separate the signed data and the signature is "Apple-Mail=\_61F7F512-9AAD-4F60-9462-F35CCAC90ED1" in line 2, it also appears on line 7, line 33,  and line 58. Thus, the email can be split as two parts: line 8 to 31 (tail blank line removed) is the data which was signed, line 41 to 6 is the signature itself. To verify the signature, save them as separate files and use the same command
as in previous section.

The last thing is how to extract the attachment, in this example, "pbencrypt.sh". The first part (line 8 to 31) itself consists of two parts which were separated with boundary string "Apple-Mail=\_91F869CE-76D7-415D-B847-2CAC206A4328" which can be found at line 9. Use this boundary string, we can split line 8 to 31 as two parts: line 15 to 21 is the attachment, line 24 to 30 is the message body. If the attachment file is not a text file, it will be encoded as base64, just copy the encoded
string as use some utility tools like `base64` to convert it back to binary file. 


