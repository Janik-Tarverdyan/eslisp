#!/usr/bin/env lsc
test = (name, test-func) ->
  (require \tape) name, (t) ->
    test-func.call t  # Make `this` refer to tape's asserts
    t.end!            # Automatically end tests

esl = require \./index.ls

test "plain literal" ->
  esl "3"
    ..`@equals` "3;"

test "plain expression" ->
  esl "(+ 3 4 5)"
    ..`@equals` "3 + (4 + 5);"

test "func expression" ->
  esl "(lambda (x) (+ x 1))"
    ..`@equals` "(function (x) {\n    return x + 1;\n});"

test "assignment expression" ->
  esl "(:= f (lambda (x) (+ x 1)))"
    ..`@equals` "f = function (x) {\n    return x + 1;\n};"

test "variable declaration statement" ->
  esl "(= f (lambda (x) (+ x 1)))"
    ..`@equals` "var f = function (x) {\n    return x + 1;\n};"

test "empty statement" ->
  esl "()"
    ..`@equals` ";"

test "member expression" ->
  esl "(. console log)"
    ..`@equals` "console.log;"

test "call expression" ->
  esl "(f)"
    ..`@equals` "f();"

test "member, then call with arguments" ->
  esl '((. console log) "hi")'
    ..`@equals` "console.log('hi');"

test "func with member and call in it" ->
  esl "(lambda (x) ((. console log) x))"
    ..`@equals` "(function (x) {\n    return console.log(x);\n});"

test "if statement" ->
  esl '(if (+ 1 0) ((. console log) "yes") ((. console error) "no"))'
    ..`@equals` "if (1 + 0)\n    console.log(\'yes\');\nelse\n    console.error(\'no\');"

test "ternary expression" ->
  esl '(?: "something" 0 1)'
    ..`@equals` "'something' ? 0 : 1;"

test "multiple statements in program" ->
  esl '((. console log) "hello") ((. console log) "world")'
    ..`@equals` "console.log('hello');\nconsole.log('world');"

test "multiple statements in function" ->
  esl '(lambda (x) ((. console log) "hello") \
                   ((. console log) "world"))'
    ..`@equals` "(function (x) {\n    console.log(\'hello\');\n    return console.log(\'world\');\n});"

test "quoting a list produces array" ->
  esl "'(1 2 3)"
    ..`@equals` "[\n    1,\n    2,\n    3\n];"

test "quoting numbers produces numbers" ->
  esl "'(1)"
    ..`@equals` "[1];"

test "quoting strings produces strings" ->
  esl "'(\"hi\")"
    ..`@equals` "['hi'];"

test "quoting atoms produces an object representing it" ->
  esl "'(fun)"
    ..`@equals` "[{\n        \'type\': \'atom\',\n        \'text\': \'fun\'\n    }];"

test "simple quoting macro" ->
  esl "(macro random () '((. Math random)))
       (+ (random) (random))"
    ..`@equals` "Math.random() + Math.random();"

test "simple non-quoting macro" ->
  esl "(macro three () (+ 1 2))
       (three)"
    ..`@equals` "3;"