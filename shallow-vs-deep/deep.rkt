#lang rosette/safe

(require rosette/lib/destruct
         (only-in "shallow.rkt" average-spec))

(struct machine
  (pc ; integer
   regs) ; 4 32-byte words
  #:mutable
  #:transparent)

(define m0 (machine 0 (vector (bv 0 32) (bv 0 32) (bv 0 32) (bv 0 32))))

;; concrete program counter, but symbolic registers
(define (new-symbolic-machine)
  (define-symbolic* r0 r1 r2 r3 (bitvector 32))
  (machine 0 (vector r0 r1 r2 r3)))

(struct instruction () #:transparent)
(struct DIVI instruction (rd rs imm32) #:transparent)
(struct ADD instruction (rd rs1 rs2) #:transparent)
(struct AND instruction (rd rs1 rs2) #:transparent)
(struct XOR instruction (rd rs1 rs2) #:transparent)
(struct RSH instruction (rd rs1 rs2) #:transparent)
(struct LDI instruction (rd imm32) #:transparent)
(define R0 (bv 0 2))
(define R1 (bv 1 2))
(define R2 (bv 2 2))
(define R3 (bv 3 2))

(define (execute! m insn)
  (define regs (machine-regs m))
  (destruct insn
            [(DIVI rd rs imm32)
             (vector-set!-bv regs rd (bvudiv (vector-ref-bv regs rs) imm32))]
            [(ADD rd rs1 rs2)
             (vector-set!-bv regs rd (bvadd (vector-ref-bv regs rs1) (vector-ref-bv regs rs2)))]
            [(AND rd rs1 rs2)
             (vector-set!-bv regs rd (bvand (vector-ref-bv regs rs1) (vector-ref-bv regs rs2)))]
            [(XOR rd rs1 rs2)
             (vector-set!-bv regs rd (bvxor (vector-ref-bv regs rs1) (vector-ref-bv regs rs2)))]
            [(RSH rd rs1 rs2)
             (vector-set!-bv regs rd (bvlshr (vector-ref-bv regs rs1) (vector-ref-bv regs rs2)))]
            [(LDI rd imm32)
             (vector-set!-bv regs rd imm32)])
  (set-machine-pc! m (add1 (machine-pc m))))

;; a program is a vector of instructions
(define (run! m prog)
  (define pc (machine-pc m))
  (cond
    [(or (< pc 0) (>= pc (vector-length prog))) m]
    [else
     (define insn (vector-ref prog (machine-pc m)))
     (execute! m insn)
     (run! m prog)]))

;; takes arguments in r0 and r1
;; leaves result in r0
;; might use r2 and r3 as scratch space
(define average-prog
  (vector
   (AND R2 R0 R1)
   (XOR R3 R0 R1)
   (LDI R1 (bv 1 32))
   (RSH R3 R3 R1)
   (ADD R0 R2 R3)))

(define buggy-prog
  (vector
   (ADD R0 R0 R1)
   (DIVI R0 R0 (bv 1 32))))

#|
(define m (machine 0 (vector (bv 7 32) (bv 13 32) (bv 0 32) (bv 0 32))))

(run! m average-prog)
|#

(define m (new-symbolic-machine))
(define x (vector-ref (machine-regs m) 0))
(define y (vector-ref (machine-regs m) 1))
(define spec-result (average-spec x y))

(run! m average-prog)
#;(run! m buggy-prog)
(define res
  (verify (assert (equal? (vector-ref (machine-regs m) 0)
                          spec-result))))
res

#;(evaluate (list x y) res)
