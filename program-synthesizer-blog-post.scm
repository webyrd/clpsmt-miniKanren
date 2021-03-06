(load "mk.scm")
(load "z3-driver.scm")
;;(load "cvc4-driver.scm")
(load "test-check.scm")
(load "full-interp-extended.scm")


;; Attempt to use miniKanren + SMT to solve synthesis problems described in the blog post:

;; Building a Program Synthesizer
;; James Bornholt
;; 10 July 2018
;;
;; https://homes.cs.washington.edu/~bornholt/post/building-synthesizer.html
;;
;; "Build a program synthesis tool, to generate programs from specifications, in 20 lines of code using Rosette."
;;
;; Code from the blog post is on GitHub?:
;;
;; https://gist.github.com/jamesbornholt/b51339fb8b348b53bfe8a5c66af66efe



;; Challenge 1: Find an integer whose absolute value is 5

;; Code from the blog post:

#|
#lang rosette/safe

; Compute the absolute value of `x`.
(define (absv x)
  (if (< x 0) (- x) x))

; Define a symbolic variable called y of type integer.
(define-symbolic y integer?)

; Solve a constraint saying |y| = 5.
(solve
  (assert (= (absv y) 5)))
|#

(test "primitive-positive"
  (run* (q)
    (numbero q)
    (z/assert `(= (+ 2 5) ,q)))
  '(7))

(test "primitive-sub-pos"
  (run* (q)
    (numbero q)
    (z/assert `(= (- 8 3) ,q)))
  '(5))

(test "primitive-negative"
  (run* (q)
    (numbero q)
    (z/assert `(= (- 2 5) ,q)))
  '(-3))

(test "positive-evalo"
  (run* (q) (evalo `(+ 2 5) q))
  '(7))

(test "sub-evalo-pos"
  (run* (q) (evalo `(- 8 3) q))
  '(5))

(test "negative-evalo"
  (run* (q) (evalo `(- 2 5) q))
  '(-3))

#!eof

(test "evalo-simple-let-a"
  (run* (q)
    (evalo '(let ((foo (+ 1 2))) (* foo foo)) q))
  '(9))

(test "evalo-symbolic-execution-a"
  (run 1 (q)
    (fresh (alpha beta gamma)
      (== (list alpha beta gamma) q)
      (evalo `(let ((a ',alpha))
                (let ((b ',beta))
                  (let ((c ',gamma))
                    (let ((x (if (!= a 0)
                                 -2
                                 0)))
                      (let ((y (if (and (< b 5) (= a 0) (!= c 0))
                                   1
                                   0)))
                        (let ((z (if (< b 5)
                                     2
                                     0)))
                          (if (!= (+ x (+ y z)) 3)
                              'good
                              'bad)))))))
             'bad)))  
  '((0 4 1)))

(test "many-1"
  (run* (q)
    (fresh (x y)
      (evalo `(+ (* ',x ',y) (* ',x ',y)) 6)
      (== q (list x y))))
  '((3 1) (1 3) (-1 -3) (-3 -1)))
