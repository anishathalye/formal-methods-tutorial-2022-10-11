#lang rosette/safe

(require "fifo_impl.rkt"
         rosutil)

(define s0 (new-zeroed-fifo_impl_s))

(define (step-with s i)
  (step (with-input s i)))

;; step with a partially symbolic input, e.g., symbolic data
(define i0 (input* 'resetn #t 'wr #t 'data_in (fresh-symbolic 'data (bitvector 32))))

#;i0

(define s1 (step-with s0 i0))

#;s1

;; step with fully symbolic input

(define i1 (new-symbolic-input))

#;i1

(define s2 (step-with s1 i1))

#;s2

;; step a fully symbolic state with a concrete input

(define s3 (new-symbolic-fifo_impl_s))

#;s3

(define s4 (step-with s3 (input* 'resetn #f)))

#;s4

;; step a fully symbolic state with a fully symbolic input

(define s5 (step-with s3 (new-symbolic-input)))

#;s5
