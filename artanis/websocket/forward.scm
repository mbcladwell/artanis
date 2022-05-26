;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2022
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

(define-module (artanis websocket forward)
  #:use-module (artanis utils)
  #:use-module ((rnrs) #:select (define-record-type make-bytevector))
  #:export (make-websocket-proxy
            websocket-proxy?
            websocket-proxy-address
            websocket-proxy-port
            websocket-proxy-socket
            websocket-proxy-mode
            make-proxy-to-service))

;; TODO: Add cert and security stuffs
;; TODO: Support "r", "w" and "rw" mode, the "w" and "rw" mode should be authenticated

(define-record-type websocket-proxy
  (fields
   address
   port
   socket
   mode))

(::define (make-proxy-to-service addr/ip port)
  (:anno: (string integer) -> ?port)
  (let* ((ai (car (getaddrinfo addr/ip (number->string port))))
         (s (socket (addrinfo:fam ai) (addrinfo:socktype ai) (addrinfo:protocol ai))))
    (catch #t
      (lambda ()
        (connect s (addrinfo:addr ai))
        (setvbuf s 'non-blocking)
        s)
      (lambda (k . e)
        (format (current-error-port) "~a: ~a~%" k e)
        #f))))
