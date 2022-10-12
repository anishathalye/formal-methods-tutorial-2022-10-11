#lang rosette/safe

(provide average-spec)

;; average of two 32-bit unsigned integers, without overflow
;;
;; spec: zero-extend to 33 bits and compute the average
(define (average-spec x y)
  (define t
    (bvudiv
     (bvadd
      (zero-extend x (bitvector 33))
      (zero-extend y (bitvector 33)))
     (bv 2 33)))
  (extract 31 0 t))

(define (buggy-impl x y)
  (bvudiv (bvadd x y) (bv 2 32)))

;; implementation, from Hacker's Delight
;;
;; (x & y) + ((x ^ y) >> 1)
(define (average-impl x y)
  (define t1 (bvand x y))
  (define t2 (bvlshr (bvxor x y) (bv 1 32)))
  (bvadd t1 t2))

;; verify that they're they same

(define-symbolic* x y (bitvector 32))

#|
(define model
  (verify (assert (equal? (average-spec x y)
                          (buggy-impl x y)))))
(printf "spec: ~a + ~a = ~a~n"
        (evaluate x model)
        (evaluate y model)
        (evaluate (average-spec x y) model))
(printf "impl: ~a + ~a = ~a~n"
        (evaluate x model)
        (evaluate y model)
        (evaluate (buggy-impl x y) model))
|#

#;(verify (assert (equal? (average-spec x y)
                        (average-impl x y))))
