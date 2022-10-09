#lang racket

(define (match-terminal expected-token-type token-list)
  (define actual-token (first token-list))
  (match-define (list actual-token-type actual-token-content _) actual-token)
  (if (equal? expected-token-type actual-token-type)
      (list (list actual-token-type actual-token-content) (rest token-list))
      (raise-unexpected-token-error (list expected-token-type) actual-token)))

(define (raise-unexpected-token-error expected-tokens actual-token)
  (match-define (list actual-token-type actual-token-content actual-token-line-number) actual-token)
  (error (format "Syntax error found on line ~a. Expected one of {~a} but got ~s."
                 actual-token-line-number
                 (string-join (map symbol->string expected-tokens) ", ")
                 actual-token-content)))

(define (match-production symbol production token-list)
  (define (matcher production token-list)
    (if (empty? production) ; Note: no need to worry about running out of tokens, because the $$ token will cause an error anyway if we see it early.
        (list '() token-list)
        (match-let ([(list subtree rest-token-list) ((first production) token-list)])
          (match-let ([(list result final-token-list) (matcher (rest production) rest-token-list)])
            (list (cons subtree result) final-token-list)))))
  (match-define (list branches final-token-list) (matcher production token-list))
  `((,symbol ,@branches) ,final-token-list))

(define (program token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id read write $$)
     (match-production 'program (list statement-list (curry match-terminal '$$)) token-list)]
    [else (raise-unexpected-token-error '(id read write $$) lookahead-token)]))

(define (statement-list token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id read write)
     (match-production 'stmt_list (list statement statement-list) token-list)]
    [($$) (list '(stmt_list ε) token-list)]
    [else (raise-unexpected-token-error '(id read write $$) lookahead-token)]))

(define (statement token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id)
     (match-production 'stmt (list (curry match-terminal 'id) (curry match-terminal ':=) expression) token-list)]
    [(read)
     (match-production 'stmt (list (curry match-terminal 'read) (curry match-terminal 'id)) token-list)]
    [(write)
     (match-production 'stmt (list (curry match-terminal 'write) expression) token-list)]
    [else (raise-unexpected-token-error '(id read write) lookahead-token)]))

(define (expression token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id number \()
     (match-production 'expr (list term term-tail) token-list)]
    [else (raise-unexpected-token-error '(id number \() lookahead-token)]))

(define (term-tail token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(+ -)
     (match-production 'term_tail (list addition-operation term term-tail) token-list)]
    [(\) id read write $$) (list '(term_tail ε) token-list)]
    [else (raise-unexpected-token-error '(+ - \) id read write $$) lookahead-token)]))

(define (term token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id number \()
     (match-production 'term (list factor factor-tail) token-list)]
    [else (raise-unexpected-token-error '(id number \() lookahead-token)]))

(define (factor-tail token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(* /)
     (match-production 'factor_tail (list multiplication-operation factor factor-tail) token-list)]
    [(+ - \) id read write $$) (list '(factor_tail ε) token-list)]
    [else (raise-unexpected-token-error '(* / + - \) id read write $$) lookahead-token)]))

(define (factor token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(id)
     (match-production 'factor (list (curry match-terminal 'id)) token-list)]
    [(number)
     (match-production 'factor (list (curry match-terminal 'number)) token-list)]
    [(\()
     (match-production 'factor (list (curry match-terminal '\() expression (curry match-terminal '\))) token-list)]
    [else (raise-unexpected-token-error '(id number \() lookahead-token)]))

(define (addition-operation token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(+)
     (match-production 'add_op (list (curry match-terminal '+)) token-list)]
    [(-)
     (match-production 'add_op (list (curry match-terminal '-)) token-list)]
    [else (raise-unexpected-token-error '(+ -) lookahead-token)]))

(define (multiplication-operation token-list)
  (define lookahead-token (first token-list))
  (define lookahead-token-type (first lookahead-token))
  (case lookahead-token-type
    [(*)
     (match-production 'mult_op (list (curry match-terminal '*)) token-list)]
    [(/)
     (match-production 'mult_op (list (curry match-terminal '/)) token-list)]
    [else (raise-unexpected-token-error '(* /) lookahead-token)]))

(provide program)