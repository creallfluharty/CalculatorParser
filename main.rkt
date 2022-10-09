#lang racket

(require "lexer.rkt")
(require "parser.rkt")

(define (parse path)
  (displayln (format "Parsing ~s" (path->string path)))
  (define tokens (tokenize (open-input-file path)))
  (match-define (list parse-tree _) (program tokens)) ; Note: Scanner guarantees that there will be no tokens after $$ which must be matched by program
  (displayln "Accepted")
  (displayln "Parse tree is as follows:")
  (pretty-print parse-tree))

(provide parse)


(for/list ([file-path (directory-list "provided-tests" #:build? #t)])
  (with-handlers ([exn:fail? (lambda (err) (displayln (exn-message err)))])
    (parse file-path)))