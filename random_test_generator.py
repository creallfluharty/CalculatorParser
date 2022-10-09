import random
import os


def get_random_derivation(productions, weights, symbol, depth=1):
    # This should totally be a generator, but meh
    if symbol not in productions:
        return [symbol]

    possible_productions = productions[symbol]
    weight_func = weights.get(symbol)

    if weight_func is None:
        random_production = random.choice(possible_productions)
    else:
        random_production, = random.choices(possible_productions, weight_func(depth), k=1)

    return [
        token
        for symbol in random_production
        for token in get_random_derivation(productions, weights, symbol, depth=depth + 1)
    ]


def main():
    # As gross as whitespace in productions is, it seemed cleaner than having a separate "unlexer" that would need
    # specific whitespace rules for different tokens.
    productions = {
        'program': [['stmt_list', '$$']],
        'stmt_list': [['stmt', 'stmt_list'], []],
        'stmt': [['id', ' ', ':=', ' ', 'expr', '\n'], ['read', ' ', 'id', '\n'], ['write', ' ', 'expr', '\n']],
        'expr': [['term', 'term_tail']],
        'term_tail': [[' ', 'add_op', ' ', 'term', 'term_tail'], []],
        'term': [['factor', 'factor_tail']],
        'factor_tail': [[' ', 'mult_op', ' ', 'factor', 'factor_tail'], []],
        'factor': [['(', 'expr', ')'], ['id'], ['number']],
        'add_op': [['+'], ['-']],
        'mult_op': [['*'], ['/']],

        # Scanner productions
        'id': [['letter', 'alphanumeric*']],
        'number': [['integer'], ['float']],
        'integer': [['digit', 'digit*']],
        'float': [['digit*', 'digit_decimal_enforcer', 'digit*']],
        'digit_decimal_enforcer': [['.', 'digit'], ['digit', '.']],

        'alphanumeric*': [['letter'], ['digit'], ['alphanumeric*'], []],
        'digit*': [['digit', 'digit*'], []],

        'letter': [[c] for c in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'],
        'digit': [[c] for c in '0123456789'],
    }

    # Just a quick hack to avoid deeply nested expressions
    production_weights = {
        'stmt_list': lambda d: (10/d, max(0, d-3)),
        'stmt': lambda d: (4/d, 1, 4/d),
        'term_tail': lambda d: (4/d, 1),
        'factor_tail': lambda d: (4/d, 1),
        'factor': lambda d: (4/d, 1, 1),
    }

    os.makedirs('tests', exist_ok=True)

    digits = 3
    for i in range(10 ** digits):
        derivation = get_random_derivation(productions, production_weights, 'program')
        f_name = f'tests/test{i:0>{digits}}.txt'
        with open(f_name, 'w') as f:
            f.write(''.join(derivation))

        print(f"Created {f_name}.")


if __name__ == '__main__':
    main()
