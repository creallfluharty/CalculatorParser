## About
This project implements a parser for the calculator language described in Chapter 3 of the Fourth Edition of Michael L. Scott's *Programming Language Pragmatics*. It's is adapted primarily from the pseudocode included in figure 2.17.

Disclaimer: This is my first project using Racket, viewer discretion is advised.

## Usage Instructions

`main.rkt` provides a `parse` function which accepts the path of a file to parse. See [Tests](Tests) for usage examples.

## Tests
Adding the following code

```racket
(for/list ([file-path (directory-list "provided-tests" #:build? #t)])
  (with-handlers ([exn:fail? (lambda (err) (displayln (exn-message err)))])
    (parse file-path)))
```

to `main.rkt` produces the following on my Windows 11 machine (formatted for readability):

```
Parsing "provided-tests\\input01.txt"
Accepted
Parse tree is as follows:
'(program
  (stmt_list
   (stmt
    (id "a")
    (:= ":=")
    (expr
     (term
      (factor
       (|(| "(")
       (expr
        (term (factor (number "3")) (factor_tail ε))
        (term_tail
         (add_op (+ "+"))
         (term (factor (number "2")) (factor_tail ε))
         (term_tail ε)))
       (|)| ")"))
      (factor_tail (mult_op (* "*")) (factor (number "5")) (factor_tail ε)))
     (term_tail ε)))
   (stmt_list
    (stmt
     (id "b")
     (:= ":=")
     (expr
      (term (factor (id "a")) (factor_tail ε))
      (term_tail
       (add_op (+ "+"))
       (term
        (factor (number "6"))
        (factor_tail (mult_op (* "*")) (factor (number "7")) (factor_tail ε)))
       (term_tail
        (add_op (+ "+"))
        (term (factor (number "3")) (factor_tail ε))
        (term_tail ε)))))
    (stmt_list
     (stmt
      (write "write")
      (expr
       (term
        (factor
         (|(| "(")
         (expr
          (term (factor (id "a")) (factor_tail ε))
          (term_tail
           (add_op (+ "+"))
           (term (factor (id "b")) (factor_tail ε))
           (term_tail ε)))
         (|)| ")"))
        (factor_tail
         (mult_op (* "*"))
         (factor
          (|(| "(")
          (expr
           (term (factor (id "a")) (factor_tail ε))
           (term_tail
            (add_op (- "-"))
            (term (factor (id "b")) (factor_tail ε))
            (term_tail ε)))
          (|)| ")"))
         (factor_tail ε)))
       (term_tail ε)))
     (stmt_list ε))))
  ($$ "$$"))

Parsing "provided-tests\\input02.txt"
Accepted
Parse tree is as follows:
'(program
  (stmt_list
   (stmt
    (id "a")
    (:= ":=")
    (expr
     (term
      (factor
       (|(| "(")
       (expr
        (term (factor (number "3")) (factor_tail ε))
        (term_tail
         (add_op (+ "+"))
         (term (factor (number "2")) (factor_tail ε))
         (term_tail ε)))
       (|)| ")"))
      (factor_tail (mult_op (* "*")) (factor (id "b")) (factor_tail ε)))
     (term_tail ε)))
   (stmt_list
    (stmt
     (id "b")
     (:= ":=")
     (expr
      (term (factor (id "a")) (factor_tail ε))
      (term_tail
       (add_op (+ "+"))
       (term
        (factor (number "6"))
        (factor_tail (mult_op (* "*")) (factor (number "7")) (factor_tail ε)))
       (term_tail
        (add_op (+ "+"))
        (term
         (factor (id "c"))
         (factor_tail (mult_op (* "*")) (factor (id "d")) (factor_tail ε)))
        (term_tail ε)))))
    (stmt_list
     (stmt
      (write "write")
      (expr
       (term
        (factor
         (|(| "(")
         (expr
          (term (factor (id "a")) (factor_tail ε))
          (term_tail
           (add_op (+ "+"))
           (term (factor (id "b")) (factor_tail ε))
           (term_tail ε)))
         (|)| ")"))
        (factor_tail
         (mult_op (* "*"))
         (factor
          (|(| "(")
          (expr
           (term (factor (id "a")) (factor_tail ε))
           (term_tail
            (add_op (- "-"))
            (term (factor (id "b")) (factor_tail ε))
            (term_tail ε)))
          (|)| ")"))
         (factor_tail ε)))
       (term_tail ε)))
     (stmt_list ε))))
  ($$ "$$"))

Parsing "provided-tests\\input03.txt"
Syntax error found on line 3. Expected one of {id, read, write, $$} but got ")".

Parsing "provided-tests\\input04.txt"
Syntax error found on line 4. Expected one of {)} but got "$$".

Parsing "provided-tests\\input05.txt"
Syntax error found on line 1. Expected one of {id, number, (} but got "*".

Parsing "provided-tests\\textbook_pg_75_example.txt"
Accepted
Parse tree is as follows:
'(program
  (stmt_list
   (stmt (read "read") (id "A"))
   (stmt_list
    (stmt (read "read") (id "B"))
    (stmt_list
     (stmt
      (id "sum")
      (:= ":=")
      (expr
       (term (factor (id "A")) (factor_tail ε))
       (term_tail
        (add_op (+ "+"))
        (term (factor (id "B")) (factor_tail ε))
        (term_tail ε))))
     (stmt_list
      (stmt
       (write "write")
       (expr (term (factor (id "sum")) (factor_tail ε)) (term_tail ε)))
      (stmt_list
       (stmt
        (write "write")
        (expr
         (term
          (factor (id "sum"))
          (factor_tail
           (mult_op (/ "/"))
           (factor (number "2"))
           (factor_tail ε)))
         (term_tail ε)))
       (stmt_list ε))))))
  ($$ #<eof>))
```

## Resources
In addition to the textbook, I found the following resources helpful for wrapping my head around recursive-descent parsing:
- https://stackoverflow.com/a/20317336/11411686
- http://ll1academy.cs.ucla.edu/tutorial

And, of course, I used the excellent [Racket documentation](https://docs.racket-lang.org) extensively.
