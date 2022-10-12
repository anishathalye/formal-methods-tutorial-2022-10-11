#lang rosette/safe

(require "fifo_impl.rkt")

(define s0 (new-zeroed-fifo_impl_s))

#;s0

(define (step-with s i)
  (step (with-input s i)))

(define s1 (step-with s0 (input* 'resetn #t 'wr #t 'data_in (bv #x1337 32))))

#;s1

(define s2 (step-with s1 (input* 'resetn #t 'wr #t 'data_in (bv #x1234 32))))

#;s2

#;(output-data_out (get-output s2))
(define s3 (step-with s2 (input* 'resetn #t 'rd #t)))

#;s3
