#lang rosette/safe

(require
 (prefix-in impl: "fifo_impl.rkt")
 (prefix-in spec: "fifo_spec.rkt")
 rosutil)

(define MAX-CAPACITY 3)

(define (R impl spec)
  (define head (get-field impl 'head))
  (define tail (get-field impl 'tail))
  (define data (get-field impl 'data))
  (define spec-data (get-field spec 'data))
  (define spec-len (bitvector->natural (get-field spec 'len)))
  ;; finite loop bound to make this amenable to symbolic execution
  (&&
   (equal? (bitvector->natural (bvsub tail head)) spec-len)
   (let rec ([i 0]
             [ptr head])
     (cond
       [(equal? i MAX-CAPACITY) #t]
       [(bveq ptr tail) #t]
       [else
        (&&
         (bveq (vector-ref-bv data ptr)
               (extract (sub1 (* 32 (- MAX-CAPACITY i))) (* 32 (- MAX-CAPACITY i 1)) spec-data))
         (rec (add1 i) (bvadd ptr (bv 1 2))))]))))

(define i0 (impl:new-zeroed-fifo_impl_s))
(define s0 (spec:new-zeroed-fifo_spec_s))

;; initial states satisfy refinement relation

#;(verify (assert (R i0 s0)))

;; step preserves refinement relation and outputs match, given same input

(define-symbolic* data_in (bitvector 32))
(define-symbolic* rd resetn wr boolean?)
(define impl-input (impl:input data_in rd resetn wr))
(define spec-input (spec:input data_in rd resetn wr))

(define i1 (impl:new-symbolic-fifo_impl_s))
(define s1 (spec:new-symbolic-fifo_spec_s))

(define i2 (impl:step (impl:with-input i1 impl-input)))
(define s2 (spec:step (spec:with-input s1 spec-input)))

(define impl-output (impl:get-output i2))
(define spec-output (spec:get-output s2))

(define res
  (verify
   (begin
     (assume (R i1 s1))
     (assert (R i2 s2))
     (assert
      (&&
       (equal? (impl:output-data_out impl-output) (spec:output-data_out spec-output))
       (equal? (impl:output-empty impl-output) (spec:output-empty spec-output))
       (equal? (impl:output-full impl-output) (spec:output-full spec-output)))))))

#;res
