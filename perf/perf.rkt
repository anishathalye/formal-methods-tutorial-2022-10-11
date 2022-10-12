#lang rosette/safe

(require rosutil)

(define-symbolic* x y (bitvector 32))

;; how do you expect this to be represented?

(define t0 (bvand x (bv #xffff0000 32)))

#;t0

;; what about this one?
;;
;; rosette rewrite rules; compare with z3py

(define t1 (bvand
            (bvand x (bv #xffff0000 32))
            (bv #x0000ffff 32)))

#;t1

;; not "complete"

(define t2 (extract 1 0 (bvand x (bv #xffff0000 32))))

#;t2

#;(concretize t2)
