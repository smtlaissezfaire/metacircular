#lang scheme/base

; primitives to be defined in initial env:
;   number?
;   symbol?
;   quote
;   lambda
;   car
;   cdr
;   cons

(define eval
  (lambda (expr env)
    (cond
     ((eq? expr #t) #t)
     ((eq? expr #f) #f)
     ((number? expr)
      expr)
     ((symbol? expr)
      (lookup-symbol expr env))
     ((eq? (car expr) 'quote)
      (cadr expr))
     ((eq? (car expr) 'cond)
      (evcond (cdr expr) env))
     ((eq? (car expr) 'lambda)
      (list 'closure (cdr expr) env))
     (else
      (let ((fun (eval (car expr) env))
            (args (cdr expr)))
        (apply fun args))))))

; internal functions are represented as
;
;   '(closure
;     ((formal-params) body)
;     env)
(define apply
  (lambda (internal-fun args)
    (let* ((fun (car (cdr internal-fun)))
           (formal-params (car fun))
           (body (car (cdr fun)))
           (env (car (cdr (cdr internal-fun)))))
      (eval body (bind formal-params args env)))))

; symbols are stored as a stack, with each
; key-value being a pair, with the most recent
; scopes at the head of the list
;
;   i.e.:
;
; (let ((x 10))
;   (let ((y 20))
;     (let ((a x)
;           (b y)))))
;
; scope:
;  '((b . y)
;    (a . x)
;    (y . 20)
;    (x . 10))
;
; empty scopes are not stored on the stack
;
; (bind '(x . y) '(a . b) '((a . 10) (b . 20)))
(define empty?
  (lambda (lst)
    (eq? lst '())))

(define bind
  (lambda (vars values env)
    (let ((empty-vars (empty? vars))
          (empty-values (empty? values)))
      (cond
       ((and empty-vars empty-values) env)
       (else
        (bind (cdr vars)
              (cdr values)
              (cons-pair (car vars) (car values) env)))))))

(define cons-pair
  (lambda (key value lst)
    (cons
     (cons key value)
     lst)))

(define evcond
  (lambda (lst env)
    (cond
     ((eq? lst '()) '())
     (else
      (let* ((branch1 (car lst))
             (branch2 (cdr lst))
             (condition (car branch1))
             (target (car (cdr branch1))))
        (cond
         ((eq? condition #t) target)
         ((eq? condition 'else) target)
         (else
          (evcond branch2 env))))))))

(define lookup-symbol
  (lambda (expr env)
    (cond
     ((eq? env '())
      (raise "unbound symbol"))
     (else
      (let ((first-pair (car env))
            (other-pairs (cdr env)))
        (let ((variable (car first-pair))
              (value    (cdr first-pair)))
          (cond
           ((eq? variable expr)
            (eval value env))
           (else
            (lookup-symbol expr other-pairs)))))))))


(provide eval)