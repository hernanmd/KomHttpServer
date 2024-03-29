Extension { #name : #MIMEDocument }

{ #category : #'*KomHttpServer' }
MIMEDocument class >> contentTypeGif [
	^'image/gif'
]

{ #category : #'*KomHttpServer' }
MIMEDocument class >> contentTypeTextCSS [
	^'text/css'
]

{ #category : #'*KomHttpServer' }
MIMEDocument class >> defaultMIMEdatabase [
	| d |
	(d := Dictionary new)
	at: 'html' put: 'text/html';
	at: 'htm' put: 'text/html';
	at: 'xml' put: 'text/xml';
	at: 'txt' put: 'text/plain';
	at: 'c' put: 'text/plain';
	at: 'gif' put: 'image/gif';
	at: 'jpg' put: 'image/jpeg';
	at: 'jpeg' put: 'image/jpeg';
	at: 'png' put: 'image/png';
	at: 'xbm' put: 'image/x-xbitmap';
	at: 'mid' put: 'audio/midi';
	at: 'doc' put: 'application/ms-word-document'.
	^d
]

{ #category : #'*KomHttpServer' }
MIMEDocument class >> extendedMIMEdatabase [
	| d |
	(d := self defaultMIMEdatabase)
	at: 'sts' put: 'application/x-squeak-source';
	at: 'pr' put: 'application/x-squeak-project';
	at: 'hqx' put: 'application/mac-binhex40';
	at: 'doc' put: 'application/msword';
	at: 'xls' put: 'application/x-excel';
	at: 'ppt' put: 'application/mspowerpoint';
	at: 'ppz' put: 'application/mspowerpoint';
	at: 'pot' put: 'application/mspowerpoint';
	at: 'pps' put: 'application/mspowerpoint';
	at: 'cpt' put: 'application/mac-compactpro';
	at: 'pdf' put: 'application/pdf';
	at: 'ps' put: 'application/postscript';
	at: 'ai' put: 'application/postscript';
	at: 'eps' put: 'application/postscript';
	at: 'rtf' put: 'text/rtf';
	at: 'bin' put: 'application/octet-stream';
	at: 'dms' put: 'application/octet-stream';
	at: 'lha' put: 'application/octet-stream';
	at: 'lzh' put: 'application/octet-stream';
	at: 'exe' put: 'application/octet-stream';
	at: 'class' put: 'application/octet-stream';
	at: 'zip' put: 'application/zip';
	at: 'gtar' put: 'application/x-gtar';
	at: 'swf' put: 'application/x-shockwave-flash';
	at: 'sit' put: 'application/x-stuffit';
	at: 'tar' put: 'application/x-tar';
	at: 'au' put: 'audio/basic';
	at: 'snd' put: 'audio/basic';
	at: 'mid' put: 'audio/midi';
	at: 'midi' put: 'audio/midi';
	at: 'mpga' put: 'audio/mpeg';
	at: 'mp2' put: 'audio/mpeg';
	at: 'mp3' put: 'audio/mpeg';
	at: 'aiff' put: 'audio/x-aiff';
	at: 'aif' put: 'audio/x-aiff';
	at: 'aifc' put: 'audio/x-aiff';
	at: 'rm' put: 'audio/x-pn-realaudio';
	at: 'ram' put: 'audio/x-pn-realaudio';
	at: 'rpm' put: 'audio/x-pn-realaudio-plugin';
	at: 'ra' put: 'audio/x-realaudio';
	at: 'wav' put: 'audio/x-wav';
	at: 'css' put: 'text/css';
	at: 'mpeg' put: 'video/mpeg';
	at: 'mpg' put: 'video/mpeg';
	at: 'mpe' put: 'video/mpeg';
	at: 'qt' put: 'video/quicktime';
	at: 'mov' put: 'video/quicktime';
	at: 'avi' put: 'video/x-msvideo';
	at: 'movie' put: 'video/x-sgi-movie';
	at: 'xul' put: 'application/vnd.mozilla.xul+xml'.
	^d
]

{ #category : #'*KomHttpServer' }
MIMEDocument class >> initialize [
	"MIMEDocument initialize"

	self resetMIMEdatabase
]

{ #category : #'*KomHttpServer' }
MIMEDocument >> mimeType [

	^self type
]
