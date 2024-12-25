;;  -*-  indent-tabs-mode:nil; coding: utf-8 -*-
;;  Copyright (C) 2024
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

(define-module (artanis i18n json)
  #:use-module (artanis config)
  #:use-module (artanis i18n json)
  #:use-module (artanis i18n po)
  #:export (i18n-init
            current-lang
            :i18n))

(define i18n-getter (make-parameter #f))

(define current-lang (make-parameter #f))

(define* (:i18n key #:optional (lang (current-lang)))
  (cond
   ((not lang) key)
   ((i18n-getter)
    => (lambda (getter)
         (or (getter lang key)
             key)))
   (else key)))

(define (i18n-init)
  (let ((i18n-mode (get-conf '(session i18n))))
    (case i18n-mode
      ((json) (i18n-getter (i18n-json-init)))
      ((po) (i18n-getter (i18n-po-init)))
      (else (error "Unknown i18n mode" i18n-mode)))))
