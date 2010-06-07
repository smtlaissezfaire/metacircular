#!/usr/bin/env mzscheme
#lang scheme/base

(require (planet schematics/schemeunit:3)
         "sicp.ss")

; test the framework
(check-equal? #t #t "true is true")

; true and false
(check-equal? (eval '#t '()) #t "#t should eval to true")
(check-equal? (eval '#f '()) #f "#f should eval to true")

; test numbers
(check-equal? (eval '1 '()) 1 "evaluating a number evaluates to itself")
(check-equal? (eval '2 '()) 2 "evaluating 2 = the number 2")


; test symbol usage
(check-equal? (eval ''foo '())
              'foo
              "quoted symbols work")
(check-equal? (eval ''bar '())
              'bar
              "a different quoted symbol works")
(check-equal? (eval (quote (quote foo)) '())
              'foo
              "quoted symbols with quote work")

; test cond
(check-equal? (eval '(cond) '())
              '()
              "cond with no clauses should be the empty list")

(check-equal? (eval '(cond (#t #t))
                    '())
              #t
              "cond with one clause that is true should be true")

(check-equal? (eval '(cond (#t #f))
                    '())
              #f
              "cond with one clause that is true should return the correct conditional body")

(check-equal? (eval '(cond (#f #f) (#t #t))
                    '())
              #t
              "it should return the value of the first clause that matches")

(check-equal? (eval '(cond (#f #f) (else #t))
                    '())
              #t
              "it should match an else branch when nothing else succeeds")

; lambda internal representation
(check-equal? (eval '(lambda (x) x)
                    '())
              (list 'closure '((x) x) '())
              "it should have the internal structure with 'closure, the formal params + body, and the env")


; bound variables
(check-equal? (eval 'foo
                    '((foo . #t)))
              #t
              "it should have a bound variable")

(check-equal? (eval 'foo
                    '((foo . #f)))
              #f
              "it should use the correct value for the bound variable")

(check-equal? (eval 'bar
                    '((bar . #f)))
              #f
              "it should use the correct bound variable for the bound variable")

(check-equal? (eval 'foo
                    '((bar . #f)
                      (foo . #t)))
              #t
              "it shouldn't have to be the first on the stack")

(check-equal? (eval 'foo
                    '((bar . #f)
                      (foo . (quote foo))))
              'foo
              "it should use the correct value for the variable when not on the top of the stack")


; apply

(check-equal? (eval '((lambda () #t))
                    '())
              #t
              "it should return the value of calling the function")

(check-equal? (eval '((lambda () #f))
                   '())
             #f
             "it should return the correct value of the function")

(check-equal? (eval '((lambda () (cond (#t #t))))
                    '())
              #t
              "it should eval the body of the function")

(check-equal? (eval '((lambda () x))
                    '((x . #t)))
              #t
              "it should eval the body of the function with variables from the outer scope")

(check-equal? (eval '((lambda (x) x) #t)
                    '())
              #t
              "it should eval the body of the function with variables from the inner scope (passed as params)")

(check-equal? (eval '((lambda (y) y) #t)
                    '())
              #t
              "it should eval the body of the function with the correct variable")

(check-equal? (eval '((lambda (x) x) #f)
                    '())
              #f
              "it should eval the body of the function with the correct values")

(check-equal? (eval '((lambda (x y) y) 10 20)
                    '())
              20
              "it should evaluate multiple arguments")

; todo - implement macros:
; (check-equal? (eval '((let ((x 10))
;                         (lambda ()
;                           x)))
;               10)
;               "it should use a variable in scope with let")
