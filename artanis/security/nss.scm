;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2019
;;      "Mu Lei" known as "NalaGinrut" <NalaGinrut@gmail.com>
;;  Artanis is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License and GNU
;;  Lesser General Public License published by the Free Software
;;  Foundation, either version 3 of the License, or (at your option)
;;  any later version.

;;  Artanis is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License and GNU Lesser General Public License
;;  for more details.

;;  You should have received a copy of the GNU General Public License
;;  and GNU Lesser General Public License along with this program.
;;  If not, see <http://www.gnu.org/licenses/>.

(define-module (artanis security nss)
  #:use-module (artanis utils)
  #:use-module (artanis ffi)
  #:use-module (system foreign)
  #:use-module (rnrs)
  #:use-module (ice-9 match)
  #:export (nss:no-db-init
            nss:init
            nss:init-rw
            nss:is-initialized?
            nss:shutdown
            nss:init-context
            nss:base64-decode
            nss:base64-encode
            nss:hash
            nss:sha-224
            nss:sha-256
            nss:sha-384
            nss:sha-512
            nss:md5
            nss:sha-1
            nss:hash-it))

(define *nss-error-msg*
  "
Please visit for more information:
https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/SSL_functions/sslerr.html
")

(eval-when (eval load compile)
  (ffi-binding "libnss3"
    (define-c-function int NSS_NoDB_Init ('*))
    (define-c-function int NSS_Init ('*))
    (define-c-function int NSS_InitReadWrite ('*))
    (define-c-function int NSS_IsInitialized)
    (define-c-function int NSS_Initialize ('* '* '* '* uint32))
    (define-c-function int NSS_Shutdown)
    (define-c-function '* NSS_InitContext ('* '* '* '* '* uint32))
    (define-c-function '* NSSBase64_DecodeBuffer ('* '* '* unsigned-int))
    (define-c-function '* NSSBase64_EncodeItem ('* '* unsigned-int '*))
    (define-c-function int PK11_HashBuf (int '* '* uint32))
    ))

(define (no-check x) #f)
(define (<0 x) (< x 0))
(define (not-nullptr? x) (not (null-pointer? x)))
(define (->nss-boolean x)
  (match x
    (1 #t)
    (0 #f)
    (else (throw 'artanis-err 500 ->nss-boolean "Invalid value `~a'" x))))

(define-syntax-rule (gen-nss-api checker caster expr ...)
  (call-with-values (lambda () expr ...)
    (lambda (ret errno)
      (cond
       ((checker ret)
        (throw 'artanis-err 500 "NSS error: ~a" errno *nss-error-msg*))
       (else (caster ret))))))

(define-syntax-rule (gen-common-api expr ...)
  (gen-nss-api <0 identity expr ...))

(define-syntax-rule (path->pointer path)
  (if (pointer? path)
      path
      (string->pointer path)))

(define* (nss:no-db-init #:optional (config-dir %null-pointer))
  (gen-common-api (%NSS_NoDB_Init (path->pointer config-dir))))

(define* (nss:init #:optional (config-dir %null-pointer))
  (gen-common-api (%NSS_Init (path->pointer config-dir))))

(define* (nss:init-rw #:optional (config-dir %null-pointer))
  (gen-common-api (%NSS_InitReadWrite (path->pointer config-dir))))

(define (nss:is-initialized?)
  (gen-nss-api no-check ->nss-boolean (%NSS_IsInitialized)))

(define (nss:shutdown)
  (gen-common-api (%NSS_Shutdown)))

(define (nss:init-context config-dir cert-prefix key-prefix sec-mod-name flags)
  (gen-nss-api not-nullptr? identity
               (%NSS_InitContext (string->pointer config-dir)
                                 (string->pointer cert-prefix)
                                 (string->pointer key-prefix)
                                 (string->pointer sec-mod-name)
                                 %null-pointer flags)))

(define (nss:hash-it algo str/bv)
  (let ((in (cond
             ((string? str/bv) str/bv)
             (((@ (rnrs) bytevector?) str/bv)
              (utf8->string str/bv))
             (else (throw 'artanis-err 500 nss:hash-it
                          "need string or bytevector!" str/bv)))))
    (algo in)))

(define *SECItem* (list int uint64 unsigned-int))
(define* (make-sec-item #:optional (type 0) (data 0) (len 0))
  (make-c-struct *SECItem* (list type data len)))

(define (base64-decode b64-str)
  (let* ((ibuf (string->pointer b64-str))
         (len (string-utf8-length b64-str))
         (ret (%NSSBase64_DecodeBuffer %null-pointer %null-pointer ibuf len)))
    (cond
     ((eq? ret %null-pointer)
      (throw 'artanis-err 500 nss:base64-decode
             "Invalid string to be decode to Base64!"))
     (else
      (let ((item (parse-c-struct ret *SECItem*)))
        (pointer->string (make-pointer (cadr item)) (caddr item)))))))

(define (base64-encode str)
  (let* ((ibuf (pointer-address (string->pointer str)))
         (len (string-utf8-length str))
         (item (make-sec-item 0 ibuf len))
         (ret (%NSSBase64_EncodeItem %null-pointer %null-pointer
                                     0 item)))
    (cond
     ((eq? ret %null-pointer)
      (throw 'artanis-err 500 nss:base64-encode
             "Invalid string to be encoded to Base64!"))
     (else (pointer->string ret)))))

(define (nss:base64-encode str/bv)
  (nss:hash-it base64-encode str/bv))

(define (nss:base64-decode str/bv)
  (nss:hash-it base64-decode str/bv))

(define SEC_OID_MD5 3)
(define SEC_OID_SHA1 4)
;; NOTE: In NSS, sha-224 only supports by HMAC
;; TODO: Support HMAC
;;(define SEC_OID_HMAC_SHA224 295)
(define SEC_OID_SHA256 191)
(define SEC_OID_SHA384 192)
(define SEC_OID_SHA512 193)

(define SHA224_DIGEST_LENGTH 28)
(define SHA256_DIGEST_LENGTH 32)
(define SHA384_DIGEST_LENGTH 48)
(define SHA512_DIGEST_LENGTH 64)
(define SHA1_DIGEST_LENGTH 20)
(define MD5_DIGEST_LENGTH 16)

(define (pk11-haskbuf algo out in len algo-len)
  (gen-common-api (%PK11_HashBuf algo out in len))
  (format #f "~{~2,'0x~}" (bytevector->u8-list (pointer->bytevector out algo-len))))

(define (nss:hash algo algo-len str)
  (let ((out (bytevector->pointer (make-bytevector algo-len 0)))
        (in (string->pointer str)))
    (pk11-haskbuf algo out in (string-utf8-length str) algo-len)))

(define (nss:sha-512 str)
  (nss:hash SEC_OID_SHA512 SHA512_DIGEST_LENGTH str))

(define (nss:sha-384 str)
  (nss:hash SEC_OID_SHA384 SHA384_DIGEST_LENGTH str))

(define (nss:sha-256 str)
  (nss:hash SEC_OID_SHA256 SHA256_DIGEST_LENGTH str))

#;
(define (nss:sha-224 str)
(nss:hash SEC_OID_HMAC_SHA224 SHA224_DIGEST_LENGTH str))

(define (nss:sha-1 str)
  (nss:hash SEC_OID_SHA1 SHA1_DIGEST_LENGTH str))

(define (nss:md5 str)
  (nss:hash SEC_OID_MD5 MD5_DIGEST_LENGTH str))
