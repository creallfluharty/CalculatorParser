#lang racket

(require parser-tools/lex)
(require (prefix-in re: parser-tools/lex-sre))

(define (tokenize port [line-number 1])
  (define lex
    (lexer
     [":=" (cons `(:= ,lexeme ,line-number) (tokenize input-port line-number))]
     ["+" (cons `(+ ,lexeme ,line-number) (tokenize input-port line-number))]
     ["-" (cons `(- ,lexeme ,line-number) (tokenize input-port line-number))]
     ["*" (cons `(* ,lexeme ,line-number) (tokenize input-port line-number))]
     ["/" (cons `(/ ,lexeme ,line-number) (tokenize input-port line-number))]
     ["(" (cons `(\( ,lexeme ,line-number) (tokenize input-port line-number))]
     [")" (cons `(\) ,lexeme ,line-number) (tokenize input-port line-number))]
     [(re:: alphabetic (re:* alphabetic numeric))
      (cons (cond
              [(equal? lexeme "read") `(read ,lexeme ,line-number)]
              [(equal? lexeme "write") `(write ,lexeme ,line-number)]
              [else `(id ,lexeme ,line-number)])
            (tokenize input-port line-number))]
     [(re:or (re:: numeric (re:* numeric)) (re:: (re:* numeric) (re:or (re:: #\. numeric) (re:: numeric #\.)) (re:* numeric)))
      (cons `(number ,lexeme ,line-number) (tokenize input-port line-number))]
     [(re:or "\r\n" "\n") (tokenize input-port (+ line-number 1))]
     [(re:or #\space #\tab) (tokenize input-port line-number)]
     ["$$" `(($$ ,lexeme ,line-number))] ; Note: This will ignore any tokens following the EOF pseudo-token, (of which there should be none anyway).
     [(eof) `(($$ ,lexeme ,line-number))] ; Note: This is what the textbook prescribes, but not what the assignment does.
     [any-char
      (begin
        (displayln (format "error scanning: ~a" lexeme))
        (tokenize input-port line-number))]))
  (lex port))

(provide tokenize)